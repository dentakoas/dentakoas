import { NextResponse } from "next/server";
import db from "@/lib/db";
import { Role } from "@/config/enum";
import { Prisma } from "@prisma/client";
import { getUserById } from "@/helpers/user";

export async function GET(
  req: Request,
  props: { params: Promise<{ userId: string }> }
) {
  const params = await props.params;
  const { searchParams } = new URL(req.url);
  const userId = searchParams.get('userId') || params.userId;

  let profile: any;

  console.log('Received userId', userId);

  if (!userId) {
    console.log('User ID is required');
    return NextResponse.json({ error: 'User ID is required' }, { status: 400 });
  }

  try {
    const existingUser = await getUserById(userId, undefined, {
      id: true,
      email: true,
      password: true,
      role: true,
    });

    const isOauth =
      existingUser?.password === null ||
      existingUser?.password === undefined ||
      existingUser?.password === '';

    console.log('Existing user', existingUser);

    if (!existingUser) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    // Check user role and respond with the appropriate profile
    if (existingUser.role == Role.Koas) {
      profile = await db.koasProfile.findUnique({
        where: { userId },
      });

      if (!profile) {
        return NextResponse.json(
          { error: 'Profile not found' },
          { status: 404 }
        );
      }

      const totalReviews = await db.review.count({
        where: {
          koasId: userId,
        },
      });

      const patientCount = await db.appointment.count({
        where: {
          koasId: userId,
          status: 'Completed',
        },
      });

      const averageRating = await db.review.aggregate({
        _avg: {
          rating: true,
        },
        where: {
          koasId: userId,
        },
      });

      // Remove createdAt and updateAt from the profile object
      const { createdAt, updateAt, ...profileWithoutDates } = profile;

      profile = {
        ...profileWithoutDates,
        stats: {
          totalReviews,
          averageRating: parseFloat(
            (averageRating._avg.rating || 0.0).toFixed(1)
          ),
          patientCount,
        },
        createdAt,
        updateAt,
      };
    } else if (existingUser.role == Role.Pasien) {
      profile = await db.pasienProfile.findUnique({
        where: { userId },
      });
    } else if (existingUser.role == Role.Fasilitator) {
      profile = await db.fasilitatorProfile.findUnique({
        where: { userId },
      });
    } else if (existingUser.role == Role.Admin) {
      profile = await db.user.findUnique({
        where: { id: userId },
      });
    } else if (existingUser.role == null) {
      return NextResponse.json(existingUser, { status: 200 });
    }

    if (!profile) {
      console.log('Existing role : ' + existingUser.role);
      console.log('Profile not found : ' + profile);
      return NextResponse.json({ error: 'Profile not found' }, { status: 404 });
    }

    const filteredProfile = (() => {
      switch (existingUser.role) {
        case Role.Fasilitator:
          return { FasilitatorProfile: profile };
        case Role.Koas:
          return { KoasProfile: profile };
        case Role.Pasien:
          return { PasienProfile: profile };
        default:
          return { message: 'No profile available for this role' };
      }
    })();

    const user = {
      ...existingUser,
      ...filteredProfile,
    };

    return NextResponse.json(user, { status: 200 });
  } catch (error) {
    if (error instanceof Error) {
      console.log(error.stack);
      console.error('Failed to create content interaction:', error);
    }
  }
}

export async function PATCH(
  req: Request,
  props: { params: Promise<{ userId: string }> }
) {
  const params = await props.params;
  const { searchParams } = new URL(req.url);
  const userId = searchParams.get('userId') || params.userId;
  const body = await req.json();

  const {
    koasNumber,
    age,
    gender,
    departement,
    university,
    bio,
    whatsappLink,
    status,
  } = body;

  console.log('Received body', body);
  console.log('Received userId', userId);

  if (typeof age === 'string') {
    body.age = parseInt(age, 10);
  }

  let profile;

  if (!userId) {
    return NextResponse.json({ error: 'User ID is required' }, { status: 400 });
  }

  try {
    const existingUser = await getUserById(userId, undefined, {
      id: true,
      givenName: true,
      familyName: true,
      role: true,
    });

    if (!existingUser) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    // Create the profile based on the user role
    if (existingUser.role === Role.Koas) {
      const existingKoas = await db.koasProfile.findUnique({
        where: { userId },
      });

      // Check if status is changing from a previous value
      if (status && existingKoas?.status !== status) {
        // Status has changed, create appropriate notification
        if (status === 'Approved') {
          await db.notification.create({
            data: {
              userId: userId,
              title: 'Profile Approved',
              message:
                'Congratulations! Your profile has been approved. You can now create posts and appointments.',
              status: 'Unread',
            },
          });
        } else if (status === 'Rejected') {
          await db.notification.create({
            data: {
              userId: userId,
              title: 'Profile Rejected',
              message:
                'Your profile was not approved. Please update your information and try again.',
              status: 'Unread',
            },
          });
        }
      }

      profile = await db.koasProfile.update({
        where: { userId },
        data: {
          koasNumber: koasNumber ?? existingKoas?.koasNumber,
          age: age ?? existingKoas?.age,
          gender: gender ?? existingKoas?.gender,
          departement: departement ?? existingKoas?.departement,
          university: university ?? existingKoas?.university,
          bio: bio ?? existingKoas?.bio,
          whatsappLink: whatsappLink ?? existingKoas?.whatsappLink,
          status: status ?? existingKoas?.status,
          user: { connect: { id: userId } },
        } as Prisma.KoasProfileUpdateInput,
      });

      // If university has changed, notify appropriate fasilitators
      if (university && existingKoas?.university !== university) {
        const fasilitators = await db.fasilitatorProfile.findMany({
          where: { university: university },
          include: { user: true },
        });

        for (const fasilitator of fasilitators) {
          await db.notification.create({
            data: {
              senderId: existingUser.id,
              userId: fasilitator.user.id,
              koasId: profile.id,
              title: 'Koas Registration Pending Approval',
              message: `${existingUser.givenName || ''} ${
                existingUser.familyName || ''
              } has updated their Koas profile and needs approval.`,
              createdAt: new Date(),
            },
          });
        }
      }
    } else if (existingUser.role === Role.Pasien) {
      const existingPasien = await db.pasienProfile.findUnique({
        where: { userId },
      });

      profile = await db.pasienProfile.update({
        where: { userId },
        data: {
          age: age ?? existingPasien?.age,
          gender: gender ?? existingPasien?.gender,
          bio: bio ?? existingPasien?.bio,
          user: { connect: { id: userId } },
        } as Prisma.PasienProfileUpdateInput,
      });
    } else if (existingUser.role === Role.Fasilitator) {
      const existingFasilitator = await db.fasilitatorProfile.findUnique({
        where: { userId },
      });
      profile = await db.fasilitatorProfile.update({
        where: { userId },
        data: {
          university: university ?? existingFasilitator?.university,
          user: { connect: { id: userId } },
        } as Prisma.FasilitatorProfileUpdateInput,
      });
    } else {
      return NextResponse.json({ error: 'Invalid user role' }, { status: 400 });
    }

    const user = {
      ...existingUser,
      profile,
    };

    return NextResponse.json(
      {
        status: 'Success',
        message: 'Profile updated successfully',
        data: { user },
      },
      { status: 201 }
    );
  } catch (error) {
    if (error instanceof Error) {
      console.log(error.stack);
      console.error('Failed to create content interaction:', error);
    }
  }
}

export async function DELETE(
  req: Request,
  props: { params: Promise<{ userId: string }> }
) {
  const params = await props.params;
  const { searchParams } = new URL(req.url);
  const userId = params.userId;
  let profile;

  const reset = searchParams.get('reset') === 'true';

  if (!userId) {
    return NextResponse.json({ error: 'User ID is required' }, { status: 400 });
  }

  try {
    // Fetch the user to check the role
    const existingUser = await getUserById(userId, undefined, {
      id: true,
      role: true,
    });

    if (!existingUser) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    if (reset) {
      if (existingUser.role === Role.Koas) {
        profile = await db.koasProfile.update({
          where: { userId },
          data: {
            koasNumber: null,
            age: null,
            gender: null,
            departement: null,
            university: { disconnect: true },
            bio: null,
            whatsappLink: null,
            status: 'Pending',
            createdAt: new Date(),
            updateAt: new Date(),
          } as Prisma.KoasProfileUpdateInput,
        });
      } else if (existingUser.role === Role.Pasien) {
        profile = await db.pasienProfile.update({
          where: { userId },
          data: {
            age: null,
            gender: null,
            bio: null,
            createdAt: new Date(),
            updateAt: new Date(),
          } as Prisma.PasienProfileUpdateInput,
        });
      }
    }

    if (!reset) {
      // Delete the profile based on the user role
      if (existingUser.role === Role.Koas) {
        profile = await db.koasProfile.delete({
          where: { userId },
        });
      } else if (existingUser.role === Role.Pasien) {
        profile = await db.pasienProfile.delete({
          where: { userId },
        });
      } else {
        return NextResponse.json(
          { error: 'Invalid user role' },
          { status: 400 }
        );
      }
    }

    const user = {
      ...existingUser,
      profile,
    };

    return NextResponse.json(
      {
        status: 'Success',
        message: reset
          ? 'Profile reset successfully'
          : 'Profile delete successfully',
        data: { user },
      },
      { status: 200 }
    );
  } catch (error) {
    if (error instanceof Error) {
      console.log(error.stack);
      console.error('Failed to create content interaction:', error);
    }
  }
}

export async function POST(
  req: Request,
  props: { params: Promise<{ userId: string }> }
) {
  const params = await props.params;
  const userId = params.userId;
  const body = await req.json();

  const {
    koasNumber,
    departement,
    bio,
    whatsappLink,
    university,
    age,
    gender,
  } = body;
  let profile: any;

  if (!userId) {
    return NextResponse.json({ error: 'User ID is required' }, { status: 400 });
  }

  try {
    const existingUser = await getUserById(userId, undefined, {
      id: true,
      role: true,
      name: true,
      givenName: true,
      familyName: true,
    });

    if (!existingUser) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    // Create the profile based on the user role
    if (existingUser.role === Role.Koas) {
      profile = await db.koasProfile.create({
        data: {
          user: { connect: { id: userId } },
          koasNumber: koasNumber,
          age: age,
          gender: gender,
          departement: departement,
          university: university, // Relasi ke universitas
          bio: bio,
          whatsappLink: whatsappLink,
        } as Prisma.KoasProfileCreateInput,
      });

      // Send welcome notification to the Koas
      await db.notification.create({
        data: {
          koasId: profile.id,
          senderId: null,
          userId: userId,
          title: 'Welcome to DentaKoas!',
          message: `Hello ${
            existingUser.name || existingUser.givenName || ''
          }! Welcome to DentaKoas. Your profile has been created and is pending approval.`,
          status: 'Unread',
        },
      });

      // Send pending approval notification to the Koas
      await db.notification.create({
        data: {
          koasId: profile.id,
          senderId: null,
          userId: userId,
          title: 'Profile Pending Approval',
          message:
            "Your profile is currently under review. You'll be notified once approved.",
          status: 'Unread',
        },
      });

      // Send notification to all Fasilitators
      const fasilitators = await db.user.findMany({
        where: { role: 'Fasilitator' },
        select: { id: true },
      });

      // Create notifications for each fasilitator
      if (fasilitators.length > 0) {
        await db.notification.createMany({
          data: fasilitators.map((fasilitator) => ({
            senderId: userId,
            userId: fasilitator.id,
            koasId: profile.id,
            title: 'New Koas Registration',
            message: `${
              existingUser.givenName || existingUser.name || 'A new Koas'
            } has registered and is pending approval.`,
            status: 'Unread',
          })),
        });
      }
    } else if (existingUser.role === Role.Pasien) {
      profile = await db.pasienProfile.create({
        data: {
          user: { connect: { id: userId } },
          age: age,
          gender: gender,
          bio: bio,
        } as Prisma.PasienProfileCreateInput,
      });

      // Send welcome notification to the Pasien
      await db.notification.create({
        data: {
          userId: userId,
          title: 'Welcome to DentaKoas!',
          message: `Hello ${
            existingUser.name || existingUser.givenName || ''
          }! Welcome to DentaKoas. You can now search for dental treatments.`,
          status: 'Unread',
        },
      });
    } else if (existingUser.role === Role.Fasilitator) {
      profile = await db.fasilitatorProfile.create({
        data: {
          user: { connect: { id: userId } },
          university: university,
        } as Prisma.FasilitatorProfileCreateInput,
      });

      // Send welcome notification to the Fasilitator
      await db.notification.create({
        data: {
          userId: userId,
          title: 'Welcome to DentaKoas!',
          message: `Hello ${
            existingUser.name || existingUser.givenName || ''
          }! Welcome to DentaKoas. You can now manage and approve Koas profiles.`,
          status: 'Unread',
        },
      });
    } else if (existingUser.role === Role.Admin) {
      // Send welcome notification to the Admin
      await db.notification.create({
        data: {
          userId: userId,
          title: 'Welcome to DentaKoas!',
          message: `Hello Admin! Welcome to DentaKoas administrative panel.`,
          status: 'Unread',
        },
      });

      return NextResponse.json({ error: 'Invalid user role' }, { status: 400 });
    } else {
      return NextResponse.json({ error: 'Invalid user role' }, { status: 400 });
    }

    const user = {
      ...existingUser,
      profile,
    };

    return NextResponse.json(
      {
        status: 'Success',
        message: 'Profile created successfully',
        data: { user },
      },
      { status: 201 }
    );
  } catch (error) {
    if (error instanceof Error) {
      console.log(error.stack);
      console.error('Failed to create profile:', error);
      return NextResponse.json(
        { error: 'Failed to create profile' },
        { status: 500 }
      );
    }
  }
}
