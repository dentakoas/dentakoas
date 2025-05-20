import { NextResponse } from "next/server";
import db from "@/lib/db";
import { StatusAppointment } from "@prisma/client";

export async function GET(req: Request) {
  try {
    // Mengambil semua appointment dengan semua relasi yang terkait
    const appointments = await db.appointment.findMany({
      include: {
        pasien: {
          include: {
            user: true, // Mengambil semua field dari user yang terkait dengan pasien
          },
        },
        koas: {
          include: {
            user: true, // Mengambil semua field dari user yang terkait dengan koas
          },
        },
        schedule: {
          include: {
            post: {
              include: {
                treatment: true, // Mengambil semua field dari treatment
                Review: true, // Mengambil semua field dari review
              },
            },
            timeslot: true, // Mengambil semua field dari timeslot
          },
        },
      },
    });

    // Hitung jumlah peserta "Confirmed" untuk setiap timeslot
    const updatedAppointments = appointments.map((appointment) => {
      const { schedule, timeslotId, date, status } = appointment;

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

      return {
        ...appointment,
        schedule: {
          ...schedule,
          timeslot: {
            ...relatedTimeslot,
            currentParticipants,
          },
        },
      };
    });

    return NextResponse.json(
      {
        appointments: updatedAppointments,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error getting appointments:", error);

    return NextResponse.json(
      { status: "Error", message: "Internal Server Error" },
      { status: 500 }
    );
  }
}


export async function POST(req: Request) {
  const body = await req.json();
  const { scheduleId, pasienId, koasId, timeslotId, date } = body;

  console.log("Creating appointment with data:", body);

  if (!scheduleId || !pasienId || !koasId || !timeslotId || !date) {
    return NextResponse.json(
      { error: "Missing required fields" },
      { status: 400 }
    );
  }

  try {
    // Cek apakah schedule, pasien, dan koas valid
    const schedule = await db.schedule.findUnique({
      where: { id: scheduleId },
      include: {
        post: true, // Mengambil data post terkait untuk validasi requiredParticipant
        timeslot: true, // Mengambil semua timeslot terkait schedule
      },
    });
    const pasien = await db.pasienProfile.findUnique({
      where: { id: pasienId },
    });
    const koas = await db.koasProfile.findUnique({
      where: { id: koasId },
    });

    console.log('Schedule, pasien, and koas found:', {
      schedule,
      pasien,
      koas,
    });

    if (!schedule || !pasien || !koas) {
      console.log("Invalid schedule, pasien or koas");
      return NextResponse.json(
        { error: "Invalid schedule, pasien or koas" },
        { status: 404 }
      );
    }

    if (
      new Date(date) < new Date(schedule.dateStart) ||
      new Date(date) > new Date(schedule.dateEnd)
    ) {
      console.log("Date is not within the schedule range");
      return NextResponse.json(
        { error: "Date is not within the schedule range" },
        { status: 400 }
      );
    }

    // Cek apakah timeslotId yang dipilih ada dalam schedule
    const selectedTimeslot = schedule.timeslot.find(
      (slot) => slot.id === timeslotId
    );

    if (!selectedTimeslot) {
      console.log("Timeslot not found for the given schedule");
      return NextResponse.json(
        { error: "Timeslot not found for the given schedule" },
        { status: 404 }
      );
    }

    if (!selectedTimeslot.isAvailable) {
      console.log("Timeslot is fully booked or unavailable");
      return NextResponse.json(
        { error: "Timeslot is fully booked or unavailable." },
        { status: 400 }
      );
    }

    // Membuat appointment baru
    const appointment = await db.appointment.create({
      data: {
        pasien: {
          connect: { id: pasienId },
        },
        koas: {
          connect: { id: koasId },
        },
        schedule: {
          connect: { id: scheduleId },
        },
        timeslot: {
          connect: { id: timeslotId },
        },
        date: date,
        status: "Pending", // Status awal adalah pending
      },
    });

    const appointments = {
      ...appointment,
      date: appointment.date.split("T")[0], // Jika disimpan sebagai string ISO dengan waktu
    };
    

    console.log("Appointment created successfully:", appointments);

    return NextResponse.json(
      {
        appointments,
      },
      { status: 201 }
    );
  } catch (error) {
    console.error("Error creating appointment:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}


export async function DELETE(req: Request) {
  try {
    await db.appointment.deleteMany({});

    return NextResponse.json(
      {
        status: "Success",
        message: "All appointments deleted successfully",
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error deleting all appointments", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}
