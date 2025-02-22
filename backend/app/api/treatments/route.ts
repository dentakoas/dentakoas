import db from "@/lib/db";
import { Prisma } from "@prisma/client";
import { NextResponse } from "next/server";

export async function GET(req: Request) {
  try {
    const treatments = await db.treatmentType.findMany({
      orderBy: {
        name: "asc",
      },
      select: {
        id: true,
        name: true,
        alias: true,
        image: true,
        createdAt: true,
      },
    });

    return NextResponse.json(
      {
        treatments,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error("Error fetching Treatment", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}

export async function POST(req: Request) {
  const body = await req.json();
  const { name } = body;

  try {
    const treatments = await db.treatmentType.create({
      data: {
        name,
      } as Prisma.TreatmentTypeCreateInput,
    });

    return NextResponse.json(
      {
        status: "Success",
        message: "Treatment created successfully",
        data: { treatments },
      },
      { status: 201 }
    );
  } catch (error) {
    console.error("Error fetching Treatment", error);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}
