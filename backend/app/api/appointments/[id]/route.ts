import db from "@/lib/db";
import { getFieldById } from "@/utils/common";
import { NextResponse } from "next/server";

export async function PATCH(
  req: Request,
  props: { params: Promise<{ id: string }> }
) {
  const params = await props.params;
  const { searchParams } = new URL(req.url);
  const id = searchParams.get('id') || params.id;

  const body = await req.json();
  const { status, scheduleId, pasienId, koasId, timeslotId } = body;

  console.log('Updating appointment with data:', body);
  console.log('Appointment ID:', id);

  try {
    // First, check if the appointment exists
    const existingAppointment = await db.appointment.findUnique({
      where: { id },
    });

    if (!existingAppointment) {
      console.error(`Appointment with ID ${id} not found in the database`);
      return NextResponse.json(
        { error: 'Appointment not found' },
        { status: 404 }
      );
    }

    console.log('Found existing appointment:', existingAppointment);

    // Use the data from the existing appointment if not provided in the body
    const effectiveScheduleId = scheduleId || existingAppointment.scheduleId;
    const effectivePasienId = pasienId || existingAppointment.pasienId;
    const effectiveKoasId = koasId || existingAppointment.koasId;
    const effectiveTimeslotId = timeslotId || existingAppointment.timeslotId;

    console.log('Using effective IDs:', {
      scheduleId: effectiveScheduleId,
      pasienId: effectivePasienId,
      koasId: effectiveKoasId,
      timeslotId: effectiveTimeslotId,
    });

    // Update the appointment status directly without additional checks to simplify
    const appointment = await db.appointment.update({
      where: { id },
      data: { status },
      include: {
        schedule: {
          include: {
            post: true,
            timeslot: {
              where: { id: effectiveTimeslotId },
            },
          },
        },
      },
    });

    console.log('Updated appointment successfully with status:', status);

    // Handle timeslot participant count updates based on status change
    if (status === 'Canceled' || status === 'Rejected') {
      // If canceling, decrease participant count
      if (existingAppointment.status === 'Confirmed') {
        // Only decrement if it was previously confirmed
        const timeslot = await db.timeslot.findUnique({
          where: { id: effectiveTimeslotId },
        });

        if (timeslot) {
          console.log('Updating timeslot participant count for cancellation');
          await db.timeslot.update({
            where: { id: effectiveTimeslotId },
            data: {
              currentParticipants: Math.max(
                0,
                timeslot.currentParticipants - 1
              ),
              isAvailable: true,
            },
          });
        }
      }
    } else if (
      status === 'Confirmed' &&
      existingAppointment.status !== 'Confirmed'
    ) {
      // If confirming a previously unconfirmed appointment
      const timeslot = await db.timeslot.findUnique({
        where: { id: effectiveTimeslotId },
      });

      if (timeslot) {
        if (!timeslot.isAvailable) {
          console.error(
            'Cannot confirm appointment: timeslot is not available'
          );
          // Rollback the status change
          await db.appointment.update({
            where: { id },
            data: { status: existingAppointment.status },
          });

          return NextResponse.json(
            { error: 'Timeslot is fully booked or unavailable.' },
            { status: 400 }
          );
        }

        console.log('Updating timeslot participant count for confirmation');
        const updatedTimeslot = await db.timeslot.update({
          where: { id: effectiveTimeslotId },
          data: {
            currentParticipants: timeslot.currentParticipants + 1,
          },
        });

        if (
          updatedTimeslot.maxParticipants !== null &&
          updatedTimeslot.currentParticipants >= updatedTimeslot.maxParticipants
        ) {
          await db.timeslot.update({
            where: { id: effectiveTimeslotId },
            data: { isAvailable: false },
          });
        }
      }
    }

    // Check if post requirements are met and update post status accordingly
    const schedule = await db.schedule.findUnique({
      where: { id: effectiveScheduleId },
      include: { post: true },
    });

    if (schedule && schedule.post) {
      const totalParticipants = await db.appointment.count({
        where: {
          scheduleId: effectiveScheduleId,
          status: 'Confirmed',
        },
      });

      console.log(
        'Total confirmed participants:',
        totalParticipants,
        'Required:',
        schedule.post.requiredParticipant
      );

      if (totalParticipants >= schedule.post.requiredParticipant) {
        await db.post.update({
          where: { id: schedule.post.id },
          data: { status: 'Closed' },
        });

        // Reject all pending appointments
        await db.appointment.updateMany({
          where: {
            scheduleId: effectiveScheduleId,
            status: 'Pending',
          },
          data: { status: 'Rejected' },
        });
      } else {
        await db.post.update({
          where: { id: schedule.post.id },
          data: { status: 'Open' },
        });
      }
    }

    return NextResponse.json(
      {
        status: 'Success',
        message: 'Appointment updated successfully',
        data: { appointment },
      },
      { status: 200 }
    );
  } catch (error) {
    console.error('Error updating appointment:', error);
    return NextResponse.json(
      { error: 'Internal Server Error', details: (error as Error).message },
      { status: 500 }
    );
  }
}

export async function PUT(
  req: Request,
  props: { params: Promise<{ id: string }> }
) {
  const params = await props.params;
  const { searchParams } = new URL(req.url);
  const id = searchParams.get('id') || params.id;

  const body = await req.json();
  const { scheduleId, pasienId, koasId, timeslotId, status, date } = body;

  try {
  } catch (error) {
    console.error('Error updating appointment', error);
    return NextResponse.json(
      { error: 'Internal Server Error' },
      { status: 500 }
    );
  }
}

export async function DELETE(
  req: Request,
  props: { params: Promise<{ id: string }> }
) {
  const params = await props.params;
  const { searchParams } = new URL(req.url);
  const id = searchParams.get('id') || params.id;

  try {
    if (!id) {
      return NextResponse.json(
        { error: 'Appoid is required' },
        { status: 400 }
      );
    }

    await db.appointment.delete({
      where: { id: id },
    });

    return NextResponse.json(
      { message: 'Appointment deleted successfully' },
      { status: 200 }
    );
  } catch (error) {
    console.error('Error deleting appointment', error);
    return NextResponse.json(
      { error: 'Internal Server Error' },
      { status: 500 }
    );
  }
}

export async function GET(
  req: Request,
  props: { params: Promise<{ id: string }> }
) {
  const params = await props.params;
  const { searchParams } = new URL(req.url);
  const id = searchParams.get('id') || params.id;

  try {
    if (!id) {
      return NextResponse.json(
        { error: 'Appointment ID is required' },
        { status: 400 }
      );
    }

    const appointment = await db.appointment.findUnique({
      where: { id },
      include: {
        pasien: {
          include: {
            user: true,
          },
        },
        koas: {
          include: {
            user: true,
          },
        },
        schedule: {
          include: {
            post: {
              include: {
                treatment: true,
                Review: true,
              },
            },
            timeslot: true,
          },
        },
      },
    });

    if (!appointment) {
      return NextResponse.json(
        { error: 'Appointment not found' },
        { status: 404 }
      );
    }

    return NextResponse.json(
      {
        status: 'Success',
        message: 'Appointment retrieved successfully',
        data: appointment,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error('Error retrieving appointment', error);
    return NextResponse.json(
      { error: 'Internal Server Error' },
      { status: 500 }
    );
  }
}
