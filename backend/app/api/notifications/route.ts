import db from "@/lib/db";
import { NextResponse } from "next/server";

export async function GET(req: Request) {
  try {
    const notifications = await db.notification.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        sender: true,
        recipient: true,
      },
    });

    if (!notifications) {
      return NextResponse.json(
        { error: "Notifications not found" },
        { status: 404 }
      );
    }

    return NextResponse.json(
      {
        notifications,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error fetching notifications:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { userId, title, message } = body;

    const newNotification = await db.notification.create({
      data: {
        userId,
        title,
        message,
        createdAt: new Date(),
      },
    });

    return NextResponse.json(
      {
        status: "Success",
        message: "Notification created successfully",
        data: newNotification,
      },
      { status: 201 }
    );
  } catch (error) {
    if (error instanceof Error) {
      console.error('Error creating notification:', error.stack);
    } else {
      console.error('Error creating notification:', error);
    }
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}

export async function DELETE(req: Request) {
  try {
    await db.notification.deleteMany();

    return NextResponse.json(
      {
        status: "Success",
        message: "All notifications deleted successfully",
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error deleting all notifications", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}

export async function PATCH(req: Request) {
  try {
    const body = await req.json();
    const { id, title, message } = body;

    const updatedNotification = await db.notification.update({
      where: { id },
      data: {
        title,
        message,
      },
    });

    return NextResponse.json(
      {
        status: "Success",
        message: "Notification updated successfully",
        data: updatedNotification,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error updating notification:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}
