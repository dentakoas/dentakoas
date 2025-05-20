import { PrismaClient, StatusNotification } from '@prisma/client';

export const seedNotifications = async (prisma: PrismaClient, users: any) => {
  // Clean up existing data
  await prisma.notification.deleteMany({});

  const allUsers = [
    ...users.koasUsers,
    ...users.pasienUsers,
    ...users.fasilitators,
    users.admin,
  ];

  const notifications = [];

  // Create welcome notifications for all users
  for (const user of allUsers) {
    let message = `Welcome to DentaKoas, ${user.givenName || user.name || ''}!`;
    let title = 'Welcome to DentaKoas';

    // Add role-specific messages
    if (user.role === 'Koas') {
      message +=
        ' Your journey to becoming a professional dentist starts here.';
    } else if (user.role === 'Pasien') {
      message += ' Find the best dental treatments here.';
    } else if (user.role === 'Fasilitator') {
      message += ' You can now manage and approve Koas profiles.';
    } else if (user.role === 'Admin') {
      message += ' You have full administrative access.';
    }

    const notification = await prisma.notification.create({
      data: {
        userId: user.id,
        title: title,
        message: message,
        status:
          Math.random() > 0.5
            ? StatusNotification.Read
            : StatusNotification.Unread,
      },
    });

    notifications.push(notification);
  }

  // Create system notifications for Koas
  const koasUsers = users.koasUsers;
  for (const koas of koasUsers) {
    if (koas.KoasProfile.status === 'Approved') {
      const notification = await prisma.notification.create({
        data: {
          userId: koas.id,
          title: 'Profile Approved',
          message:
            'Congratulations! Your profile has been approved. You can now create posts and appointments.',
          status: StatusNotification.Unread,
        },
      });
      notifications.push(notification);
    } else if (koas.KoasProfile.status === 'Pending') {
      const notification = await prisma.notification.create({
        data: {
          userId: koas.id,
          title: 'Profile Under Review',
          message:
            "Your profile is being reviewed by our facilitators. You'll be notified once it's approved.",
          status: StatusNotification.Unread,
        },
      });
      notifications.push(notification);
    }
  }

  // Create notifications for facilitators about pending Koas
  const pendingKoas = await prisma.koasProfile.findMany({
    where: { status: 'Pending' },
    include: { user: true },
  });

  const fasilitators = users.fasilitators;
  for (const fasilitator of fasilitators) {
    for (const koas of pendingKoas) {
      const notification = await prisma.notification.create({
        data: {
          userId: fasilitator.id,
          senderId: koas.user.id,
          koasId: koas.id,
          title: 'New Koas Registration',
          message: `${
            koas.user.givenName || koas.user.name || 'A new Koas'
          } has registered and is pending approval.`,
          status: StatusNotification.Unread,
        },
      });
      notifications.push(notification);
    }
  }

  // Create appointment notifications
  const appointments = await prisma.appointment.findMany({
    include: {
      pasien: { include: { user: true } },
      koas: { include: { user: true } },
    },
  });

  for (const appointment of appointments) {
    // Notification for koas
    if (appointment.status === 'Pending') {
      const notification = await prisma.notification.create({
        data: {
          userId: appointment.koas.user.id,
          senderId: appointment.pasien.user.id,
          title: 'New Appointment Request',
          message: `${
            appointment.pasien.user.givenName ||
            appointment.pasien.user.name ||
            'A patient'
          } has requested an appointment on ${appointment.date}.`,
          status: StatusNotification.Unread,
        },
      });
      notifications.push(notification);
    }

    // Notification for pasien
    if (appointment.status === 'Confirmed') {
      const notification = await prisma.notification.create({
        data: {
          userId: appointment.pasien.user.id,
          senderId: appointment.koas.user.id,
          title: 'Appointment Confirmed',
          message: `Your appointment with ${
            appointment.koas.user.givenName ||
            appointment.koas.user.name ||
            'the dentist'
          } on ${appointment.date} has been confirmed.`,
          status: StatusNotification.Unread,
        },
      });
      notifications.push(notification);
    }
  }

  return notifications;
};
