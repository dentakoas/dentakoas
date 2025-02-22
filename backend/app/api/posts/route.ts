import { NextResponse } from "next/server";
import db from "@/lib/db";
import { parseSearchParamsPost } from "@/helpers/post";
import { Prisma } from "@prisma/client";
import { StatusKoas } from "@/config/enum";
import { genSchedules, genTimeSlots } from "@/utils/dateTime";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const queStr = parseSearchParamsPost(searchParams);

  try {
    const posts = await db.post.findMany({
      where: {
        ...queStr,
      } as Prisma.PostWhereInput,
      include: {
        user: {
          include: {
            KoasProfile: true,
          },
        },
        Schedule: {
          select: {
            id: true,
            dateStart: true,
            dateEnd: true,
            timeslot: {
              select: {
                id: true,
                startTime: true,
                endTime: true,
                maxParticipants: true,
                currentParticipants: true,
                isAvailable: true,
              },
            },
          },
        },
        treatment: {
          select: {
            id: true,
            name: true,
            alias: true,
          },
        },
        _count: {
          select: { likes: true }, // Menghitung jumlah likes untuk setiap post
        },
      },
    });

    // Proses untuk menambahkan totalCurrentParticipants
    const postsWithLikeCountAndTotalParticipants = posts.map(
      ({ _count, Schedule, ...post }) => {
        const scheduleWithTotalParticipants = Schedule.map((schedule) => {
          const totalCurrentParticipants = schedule.timeslot.reduce(
            (acc, timeslot) => acc + (timeslot.currentParticipants || 0),
            0
          );
          return {
            ...schedule,
            totalCurrentParticipants, // Tambahkan totalCurrentParticipants ke setiap schedule
          };
        });

        return {
          ...post,
          likes: _count.likes, // Tambahkan jumlah likes
          Schedule: scheduleWithTotalParticipants, // Update Schedule dengan totalCurrentParticipants
        };
      }
    );

    return NextResponse.json(
      {
        posts: postsWithLikeCountAndTotalParticipants,
      },
      { status: 200 }
    );
  } catch (error) {
    if (error instanceof Error) {
      console.log(error.stack);
      console.error("Failed to fetch post", error);
    }
  }
}

export async function POST(req: Request) {
  const body = await req.json();
  const {
    userId,
    koasId,
    treatmentId,
    title,
    desc,
    images,
    patientRequirement,
    requiredParticipant,
    dateRangeStart,
    dateRangeEnd,
    published,
    status,
    koasStartTime, // Waktu mulai koas
    koasEndTime, // Waktu selesai koas
  } = body;

  try {
    if (!userId || !koasId || !treatmentId || !title || !desc) {
      return NextResponse.json(
        { error: "Missing required fields" },
        { status: 400 }
      );
    }

    const koasProfile = await db.koasProfile.findUnique({
      where: { id: koasId },
      select: {
        status: true,
      },
    });

    if (!koasProfile) {
      return NextResponse.json(
        { error: "Koas Profile not found" },
        { status: 404 }
      );
    }

    if (koasProfile.status !== StatusKoas.Approved) {
      return NextResponse.json(
        { error: "Don't have access to post before status approved" },
        { status: 400 }
      );
    }

    // Membuat Post terlebih dahulu
    const post = await db.post.create({
      data: {
        title,
        desc,
        images,
        patientRequirement,
        requiredParticipant,
        status,
        published,
        user: { connect: { id: String(userId) } },
        koas: { connect: { id: String(koasId) } },
        treatment: { connect: { id: String(treatmentId) } },
      } as Prisma.PostCreateInput,
    });

    // // Generate jadwal berdasarkan dateRangeStart hingga dateRangeEnd
    // const scheduleDates = genSchedules(
    //   new Date(dateRangeStart),
    //   new Date(dateRangeEnd)
    // );

    // // Create schedules first using createMany
    // const schedulesData = scheduleDates.map((scheduleDate) => ({
    //   date: scheduleDate,
    //   postId: post.id,
    // }));

    // await db.schedule.createMany({
    //   data: schedulesData,
    // });

    return NextResponse.json(
      {
        post,
      },
      { status: 201 }
    );
  } catch (error) {
    if (error instanceof Error) {
      console.log("Error: ", error.stack);
    }
  }
}


export async function DELETE() {
  try {
    const post = await db.post.deleteMany({});

    return NextResponse.json(
      {
        post,
      },
      { status: 200 }
    );
  } catch (error) {
    if (error instanceof Error) {
      console.log("Error: ", error.stack);
    }
  }
}
