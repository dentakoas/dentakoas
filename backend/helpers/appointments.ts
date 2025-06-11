import db from "@/lib/db";
import { getCurrentTime, getToday } from "@/utils/dateTime";
 

export async function updateExpiredAppointments() {
  try {
    const today = getToday();
    const currentTime = getCurrentTime();

    console.log("Today's date:", today);
    console.log("Current time:", currentTime);

    // Cari semua appointment dengan status "Pending" yang tanggalnya sudah lewat
    const expiredAppointments = await db.appointment.findMany({
      where: {
        status: "Pending",
        date: {
          lt: today, // Tanggal appointment kurang dari hari ini
        },
      },
    });

    // console.log("Expired appointments:", expiredAppointments);
    expiredAppointments.forEach((appointment) => {
      console.log(`Expired appointment date: ${appointment.date}`);
    });

    if (expiredAppointments.length === 0) {
      console.log("No expired appointments found.");
      return;
    }

    console.log("Processing expired appointments:", expiredAppointments.length);

    const updateResults = await db.appointment.updateMany({
      where: {
        id: { in: expiredAppointments.map((appointment) => appointment.id) },
      },
      data: {
        status: "Rejected",
      },
    });

    // Kirim notifikasi
    const sendNotification = await db.notification.createMany({
      data: expiredAppointments.map((appointment) => ({
        title: "Appointment Expired",
        message: `Your appointment on ${appointment.date} has expired and automatically rejected.`,
        userId: appointment.pasienId,
        appointmentId: appointment.id,
      })),
    });

    console.log(
      `${updateResults.count} expired appointments updated to "Rejected". ${sendNotification.count} notifications sent.`
    );

    // // Update status appointment menjadi "Rejected"
    // await db.$transaction(async (prisma) => {
    //   // Update status appointment menjadi "Rejected"

    // });

    // return NextResponse.json({
    //   status: "Success",
    //   message: "Expired appointments updated successfully",
    // });
  } catch (error) {
    console.error("Error updating expired appointments:", error);
  }
}

export async function updateOngoingAppointments() {
  try {
    const today = getToday();
    const currentTime = getCurrentTime();

    // Cari semua appointment dengan status "Confirmed", tanggal sama dengan hari ini, dan waktu sama dengan startTime
    const ongoingAppointments = await db.appointment.findMany({
      where: {
        status: "Confirmed",
        OR: [
          {
            date: {
              equals: today,
            },
            timeslot: {
              startTime: {
                equals: currentTime,
              },
            },
          },
          {
            date: {
              lt: today,
            },
          },
        ],
      },
      include: {
        schedule: {
          include: {
            timeslot: true, // Sertakan timeslot untuk verifikasi jika diperlukan
          },
        },
      },
    });

    console.log("Ongoing appointments:", ongoingAppointments);

    if (ongoingAppointments.length === 0) {
      console.log(
        "No appointments ongoing matching today's date and current time."
      );
      return;
    }

    console.log("Processing appointments:", ongoingAppointments.length);

    // Gunakan transaksi untuk atomisitas
    // await db.$transaction(async (prisma) => {

    // Update status appointment menjadi "Ongoing"
    const updateResults = await db.appointment.updateMany({
      where: {
        id: { in: ongoingAppointments.map((appointment) => appointment.id) },
      },
      data: {
        status: "Ongoing",
      },
    });

    // Kirim notifikasi
    const sendNotification = await db.notification.createMany({
      data: ongoingAppointments.map((appointment) => ({
        title: "Appointment Ongoing",
        message: `Your appointment on ${appointment.date} at ${appointment.schedule.timeslot[0].startTime} is now ongoing.`,
        userId: appointment.pasienId,
        appointmentId: appointment.id,
      })),
    });

    console.log(
      `${updateResults.count} appointments updated to "Ongoing". ${sendNotification.count} notifications sent.`
    );
    // });

    // return NextResponse.json({
    //   status: "Success",
    //   message: "Ongoing appointments updated successfully",
    // });
  } catch (error) {
    if (error instanceof Error) {
      console.log("Error: ", error.stack);
    }
  }
}

export async function updateCompletedAppointments() {
  try {
    const today = getToday();
    const currentTime = getCurrentTime();

    // Cari semua appointment dengan status "Ongoing", tanggal sama dengan hari ini, dan waktu sama dengan endTime
    const completedAppointments = await db.appointment.findMany({
      where: {
        status: "Ongoing",
        OR: [
          {
            date: {
              equals: today,
            },
            timeslot: {
              endTime: {
                equals: currentTime,
              },
            },
          },
          {
            date: {
              lt: today,
            },
          },
        ],
      },
      include: {
        schedule: {
          include: {
            timeslot: true, // Sertakan timeslot untuk verifikasi jika diperlukan
          },
        },
      },
    });

    console.log("Completed appointments:", completedAppointments);

    if (completedAppointments.length === 0) {
      console.log(
        "No appointments completed matching today's date and current time."
      );
      return;
    }

    console.log("Processing appointments:", completedAppointments.length);

    // Gunakan transaksi untuk atomisitas
    // await db.$transaction(async (prisma) => {
    // Update status appointment menjadi "Completed"
    const updateResults = await db.appointment.updateMany({
      where: {
        id: {
          in: completedAppointments.map((appointment) => appointment.id),
        },
      },
      data: {
        status: "Completed",
      },
    });

    // Kirim notifikasi
    const sendNotification = await db.notification.createMany({
      data: completedAppointments.map((appointment) => ({
        title: "Appointment Completed",
        message: `Your appointment on ${appointment.date} at ${appointment.schedule.timeslot[0].endTime} has been completed.`,
        userId: appointment.pasienId,
        appointmentId: appointment.id,
      })),
    });

    console.log(
      `${updateResults.count} appointments updated to "Completed". ${sendNotification.count} notifications sent.`
    );
    // });

    // return NextResponse.json({
    //   status: "Success",
    //   message: "Completed appointments updated successfully",
    // });
  } catch (error) {
    if (error instanceof Error) {
      console.log("Error: ", error.stack);
    }
  }
}
