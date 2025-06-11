import db from "@/lib/db";
import { NextResponse } from "next/server";
// Adjust based on your project structure

// CREATE Notification
export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { senderId, userId, koasId, title, message, status } = body;

    console.log("Received Body:", body);

    // Validate userId exists
    const user = await db.user.findUnique({ where: { id: userId } });
    if (!user) {
      return NextResponse.json(
        { error: "User not found" },
        { status: 404 }
      );
    }

    const newNotification = await db.notification.create({
      data: {
        senderId,
        userId,
        koasId,
        title,
        message,
        status,
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
    let errorMessage = "Internal Server Error";
    if (error instanceof Error) {
      console.log('Error: ', error.stack);
      errorMessage = error.message;
    }
    console.error('Error creating notification:', error);
    return NextResponse.json({ error: errorMessage }, { status: 500 });
  }
}

// READ Notifications
export async function GET(
  req: Request,
  props: { params: Promise<{ userId: string }> }
) {
  try {
    const params = await props.params;
    const { searchParams } = new URL(req.url);
    const userId = searchParams.get("userId") || params.userId;

    console.log("userId", userId);

    const notifications = await db.notification.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      include: {
        sender: true,
        recipient: true,
      },
    });

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

// UPDATE Notification
export async function PATCH(req: Request) {
  try {
    const body = await req.json();
    const { id, title, message, status } = body;

    const updatedNotification = await db.notification.update({
      where: { id },
      data: {
        title,
        message,
        status: status,
        updatedAt: new Date(),
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

// DELETE Notification
export async function DELETE(req: Request) {
  try {
    const url = new URL(req.url);
    const id = url.searchParams.get("id");

    if (!id) {
      return NextResponse.json(
        { error: "Notification ID is required" },
        { status: 400 }
      );
    }

    await db.notification.delete({ where: { id } });

    return NextResponse.json(
      {
        status: "Success",
        message: "Notification deleted successfully",
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error deleting notification:", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}
