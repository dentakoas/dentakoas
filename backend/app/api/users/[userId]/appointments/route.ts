import db from "@/lib/db";
import { NextResponse } from "next/server";

export async function GET(
  req: Request,
  props: { params: Promise<{ userId: string }> }
) {
  const params = await props.params;
  const { searchParams } = new URL(req.url);
  const userId = searchParams.get("userId") || params.userId;

  try {
    if (!userId) {
      return NextResponse.json(
        { error: "User userId is required" },
        { status: 400 }
      );
    }

    // Mengambil semua appointment untuk user tertentu dengan data terkait
    const appointments = await db.appointment.findMany({
      where: {
        OR: [{ pasien: { userId: userId } }, { koas: { userId: userId } }],
      },
      select: {
        id: true,
        pasienId: true,
        koasId: true,
        scheduleId: true,
        timeslotId: true,
        date: true,
        status: true, // Status digunakan untuk filter
        createdAt: true,
        updatedAt: true,
        pasien: {
          select: {
            id: true,
            age: true,
            gender: true,
            user: {
              select: {
                id: true,
                email: true,
                name: true,
                givenName: true,
                familyName: true,
                address: true,
                phone: true,
                image: true,
                createdAt: true,
              },
            },
          },
        },
        koas: {
          select: {
            id: true,
            userId: true,
            koasNumber: true,
            gender: true,
            age: true,
            university: true,
            departement: true,
            createdAt: true,
            user: {
              select: {
                id: true,
                email: true,
                name: true,
                givenName: true,
                familyName: true,
                address: true,
                phone: true,
                image: true,
              },
            },
          },
        },
        schedule: {
          select: {
            id: true,
            dateStart: true,
            dateEnd: true,
            createdAt: true,
            post: {
              select: {
                id: true,
                title: true,
                requiredParticipant: true,
                treatment: {
                  select: {
                    id: true,
                    name: true,
                    alias: true,
                  },
                },
                Review: {
                  select: {
                    id: true,
                    pasienId: true,
                    koasId: true,
                    rating: true,
                    comment: true,
                    createdAt: true,
                  },
                },
              },
            },
            timeslot: {
              select: {
                id: true,
                startTime: true,
                endTime: true,
                maxParticipants: true,
                currentParticipants: true, // Akan diperbarui
                isAvailable: true,
              },
            },
          },
        },
      },
    });

    // Menggabungkan data pasien dan user, serta koas dan user
    const updatedAppointments = appointments.map((appointment) => {
      const { pasien, koas, schedule, timeslotId, date, status } = appointment;

      // Gabungkan pasien dan user
      const mergedPasien = {
        id: pasien.id,
        userId: pasien.user.id,
        name: pasien.user.name,
        phone: pasien.user.phone,
        age: pasien.age,
        gender: pasien.gender,
      };

      // Gabungkan koas dan user
      const mergedKoas = {
        id: koas.id,
        userId: koas.user.id,
        name: koas.user.name,
        phone: koas.user.phone,
        koasNumber: koas.koasNumber,
      };

      // Hitung jumlah peserta "Confirmed" untuk timeslot tertentu
      const currentParticipants = appointments.filter(
        (a) =>
          a.schedule?.id === schedule?.id &&
          a.timeslotId === timeslotId &&
          a.date === date &&
          a.status === "Confirmed"
      ).length;

      const relatedTimeslot = schedule.timeslot.find(
        (slot) => slot.id === timeslotId
      );

      // Perbarui timeslot terkait
      // const updatedTimeslots = schedule.timeslot.map((timeslot) => ({
      //   ...timeslot,
      //   currentParticipants:
      //     timeslot.id === timeslotId
      //       ? currentParticipants // Update currentParticipants untuk timeslot tertentu
      //       : timeslot.currentParticipants,
      // }));

      // Kembalikan data appointment yang telah diperbarui
      return {
        ...appointment,
        // pasien: mergedPasien,
        // koas: mergedKoas,
        schedule: {
          ...schedule,
          timeslot: {
            ...relatedTimeslot,
            currentParticipants,
          },
        },
      };
    });

    // Mengembalikan data ke klien
    return NextResponse.json(
      {
        appointments: updatedAppointments, // Return updated appointments
      },
      { status: 200 }
    );
  } catch (error) {
    if (error instanceof Error) {
      console.error("Error fetching appointments", error);
    }

    // Mengembalikan respons error ke klien
    return NextResponse.json(
      { status: "Error", message: "Internal Server Error" },
      { status: 500 }
    );
  }
}
