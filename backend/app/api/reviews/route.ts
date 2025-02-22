import { ReviewQueryString } from "@/config/types";
import { parseSearchParams } from "@/helpers/review";
import db from "@/lib/db";
import { NextResponse } from "next/server";

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const query: ReviewQueryString = parseSearchParams(searchParams);

  try {
    const reviews = await db.review.findMany({
      where: {
        ...query,
      },
      orderBy: {
        createdAt: "desc",
      },
      include: {
        user: true,
        KoasProfile: true,
        post: true,
      },
    });

    return NextResponse.json(
      {
        reviews,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error fetching reviews", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}

export async function POST(req: Request) {
  const body = await req.json();
  const { postId, pasienId, koasId, rating, comment } = body;

  console.log("Received Body:", body);

  if (!postId || !pasienId || !koasId || rating === undefined) {
    console.error("Missing required fields");
    return NextResponse.json(
      {
        error: "postId, pasienId, koasId, rating and comment are required",
      },
      { status: 400 }
    );
  }

  try {
    const review = await db.review.create({
      data: {
        postId,
        pasienId,
        koasId,
        rating,
        comment,
      },
    });

    return NextResponse.json(
      {
        review,
      },
      { status: 201 }
    );
  } catch (error) {
    if (error instanceof Error) {
      console.log("Error: ", error.stack);
    }
  }
}

export async function DELETE(req: Request) {
  try {
    await db.review.deleteMany({});

    return NextResponse.json(
      { message: "Review deleted successfully" },
      { status: 200 }
    );
  } catch (error) {
    if (error instanceof Error) {
      console.log(error.stack);
    }
  }
}