import {
  Role,
  StatusKoas,
  StatusPost,
  StatusAppointment,
  StatusNotification,
} from '@prisma/client';

// User seeding interfaces
export interface UserSeedResult {
  admin: any;
  fasilitatorCount: number;
  koasCount: number;
  pasienCount: number;
}

export interface FirebaseCreateData {
  email: string;
  password: string;
  displayName: string;
  photoURL?: string;
}

export interface KoasData {
  id: string;
  koasNumber: string;
  entryYear: number;
  gender?: string; // Add gender field for avatar generation
  phone?: string | null;
}

// Treatment interfaces
export interface TreatmentSeedData {
  id?: string;
  name: string;
  alias: string;
  image?: string | null;
  createdAt?: Date;
  updateAt?: Date;
}

// Post interfaces
export interface PostWithRelations {
  id: string;
  userId: string;
  koasId: string;
  treatmentId: string;
  title: string;
  desc: string;
  images: any; // Use any for Prisma JSON fields
  patientRequirement: any; // Use any for Prisma JSON fields
  requiredParticipant: number;
  status: StatusPost;
  published: boolean;
  createdAt: Date;
  updateAt: Date;
  user?: {
    id: string;
    givenName?: string | null;
    familyName?: string | null;
    name?: string | null;
    email?: string | null;
    KoasProfile?: any;
  };
  koas?: {
    id: string;
    userId: string;
    user?: {
      id: string;
      name?: string | null;
      givenName?: string | null;
    };
  };
  treatment?: {
    id: string;
    name: string;
    alias: string;
  };
  likes?: number;
  Schedule?: ScheduleWithRelations[];
}

// Schedule interfaces
export interface TimeslotData {
  id: string;
  scheduleId: string;
  startTime: string;
  endTime: string;
  maxParticipants: number | null;
  currentParticipants: number;
  isAvailable: boolean;
}

export interface ScheduleWithRelations {
  id: string;
  postId: string;
  dateStart: Date;
  dateEnd: Date;
  createdAt?: Date;
  updateAt?: Date;
  timeslot: TimeslotData[];
  post?: PostWithRelations;
  totalCurrentParticipants?: number;
}

export interface SlotUsage {
  [key: string]: {
    used: number;
    max: number;
  };
}

// PasienProfile with user relation
export interface PasienProfileWithUser {
  id: string;
  userId: string;
  age?: string | null;
  gender?: string | null;
  bio?: string | null;
  createdAt: Date;
  updateAt: Date;
  user: {
    id: string;
    name?: string | null;
    email?: string | null;
    image?: string | null;
    givenName?: string | null;
    familyName?: string | null;
  };
}

// KoasProfile with user relation
export interface KoasProfileWithUser {
  id: string;
  userId: string;
  koasNumber?: string | null;
  age?: string | null;
  gender?: string | null;
  departement?: string | null;
  university?: string | null;
  bio?: string | null;
  whatsappLink?: string | null;
  status: StatusKoas;
  createdAt: Date;
  updateAt: Date;
  experience?: number | null;
  user: {
    id: string;
    name?: string | null;
    email?: string | null;
    image?: string | null;
    givenName?: string | null;
    familyName?: string | null;
  };
}

// Notification interface
export interface NotificationData {
  id: string;
  userId?: string | null;
  senderId?: string | null;
  koasId?: string | null;
  title: string;
  message: string;
  status: StatusNotification;
  createdAt: Date;
  updatedAt: Date;
}

// Likes
export interface LikeData {
  id: string;
  postId: string;
  userId: string;
  createdAt: Date;
}

// Appointments
export interface AppointmentData {
  id: string;
  pasienId: string;
  koasId: string;
  scheduleId: string;
  timeslotId: string;
  date: string;
  status: StatusAppointment;
  createdAt: Date;
  updatedAt: Date;
}

// Reviews
export interface ReviewData {
  id: string;
  postId: string;
  userId: string; // Changed from pasienId to userId to match schema
  koasId?: string | null;
  rating: number | string; // Prisma accepts Decimal as string or number
  comment?: string | null;
  createdAt: Date;
}
