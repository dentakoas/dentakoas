/*
  Warnings:

  - You are about to drop the column `created_at` on the `notifications` table. All the data in the column will be lost.
  - You are about to drop the column `is_read` on the `notifications` table. All the data in the column will be lost.
  - You are about to drop the column `user_id` on the `notifications` table. All the data in the column will be lost.
  - The values [Close] on the enum `posts_status` will be removed. If these variants are still used in the database, this will fail.
  - You are about to alter the column `rating` on the `reviews` table. The data in that column could be lost. The data in that column will be cast from `Int` to `Decimal(65,30)`.
  - You are about to drop the column `identifier` on the `verificationrequest` table. All the data in the column will be lost.
  - You are about to drop the `appointment` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `koas-profile` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `pasien-profile` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `treatment-types` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[email,token]` on the table `verificationrequest` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `title` to the `notifications` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `notifications` table without a default value. This is not possible if the table is not empty.
  - Made the column `required_participant` on table `posts` required. This step will fail if there are existing NULL values in that column.
  - Added the required column `email` to the `verificationrequest` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE `appointments` DROP FOREIGN KEY `Appointment_koas_id_fkey`;

-- DropForeignKey
ALTER TABLE `appointments` DROP FOREIGN KEY `Appointment_pasien_id_fkey`;

-- DropForeignKey
ALTER TABLE `appointments` DROP FOREIGN KEY `Appointment_schedule_id_fkey`;

-- DropForeignKey
ALTER TABLE `koas-profile` DROP FOREIGN KEY `koas-profile_user_id_fkey`;

-- DropForeignKey
ALTER TABLE `likes` DROP FOREIGN KEY `likes_post_id_fkey`;

-- DropForeignKey
ALTER TABLE `likes` DROP FOREIGN KEY `likes_user_id_fkey`;

-- DropForeignKey
ALTER TABLE `notifications` DROP FOREIGN KEY `notifications_user_id_fkey`;

-- DropForeignKey
ALTER TABLE `pasien-profile` DROP FOREIGN KEY `pasien-profile_user_id_fkey`;

-- DropForeignKey
ALTER TABLE `posts` DROP FOREIGN KEY `posts_koas_id_fkey`;

-- DropForeignKey
ALTER TABLE `posts` DROP FOREIGN KEY `posts_user_id_fkey`;

-- DropForeignKey
ALTER TABLE `reviews` DROP FOREIGN KEY `reviews_post_id_fkey`;

-- DropForeignKey
ALTER TABLE `reviews` DROP FOREIGN KEY `reviews_user_id_fkey`;

-- DropForeignKey
ALTER TABLE `schedules` DROP FOREIGN KEY `schedules_post_id_fkey`;

-- DropForeignKey
ALTER TABLE `timeslots` DROP FOREIGN KEY `timeslots_schedule_id_fkey`;

-- DropIndex
DROP INDEX `VerificationRequest_identifier_token_key` ON `verificationrequest`;

-- AlterTable
ALTER TABLE `notifications` DROP COLUMN `created_at`,
    DROP COLUMN `is_read`,
    DROP COLUMN `user_id`,
    ADD COLUMN `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    ADD COLUMN `koasId` VARCHAR(191) NULL,
    ADD COLUMN `senderId` VARCHAR(191) NULL,
    ADD COLUMN `status` ENUM('Unread', 'Read') NOT NULL DEFAULT 'Unread',
    ADD COLUMN `title` VARCHAR(191) NOT NULL,
    ADD COLUMN `updatedAt` DATETIME(3) NOT NULL,
    ADD COLUMN `userId` VARCHAR(191) NULL;

-- AlterTable
ALTER TABLE `posts` ADD COLUMN `images` JSON NULL,
    MODIFY `desc` VARCHAR(500) NOT NULL,
    MODIFY `status` ENUM('Pending', 'Open', 'Closed') NOT NULL DEFAULT 'Pending',
    MODIFY `required_participant` INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE `reviews` ADD COLUMN `koas_id` VARCHAR(191) NULL,
    MODIFY `rating` DECIMAL(65, 30) NOT NULL DEFAULT 0.000000000000000000000000000000,
    MODIFY `comment` VARCHAR(500) NULL;

-- AlterTable
ALTER TABLE `users` MODIFY `role` ENUM('Admin', 'Koas', 'Pasien', 'Fasilitator') NULL;

-- AlterTable
ALTER TABLE `verificationrequest` DROP COLUMN `identifier`,
    ADD COLUMN `email` VARCHAR(191) NOT NULL;

-- DropTable
DROP TABLE `appointments`;

-- DropTable
DROP TABLE `koas-profile`;

-- DropTable
DROP TABLE `pasien-profile`;

-- DropTable
DROP TABLE `treatment-types`;

-- CreateTable
CREATE TABLE `otps` (
    `id` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `otp` VARCHAR(191) NOT NULL,
    `expires` DATETIME(3) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `otps_otp_key`(`otp`),
    UNIQUE INDEX `otps_email_otp_key`(`email`, `otp`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `koas_profile` (
    `id` VARCHAR(191) NOT NULL,
    `user_id` VARCHAR(191) NOT NULL,
    `koas_number` VARCHAR(191) NULL,
    `age` VARCHAR(191) NULL,
    `gender` VARCHAR(191) NULL,
    `departement` VARCHAR(191) NULL,
    `university` VARCHAR(191) NULL,
    `bio` VARCHAR(191) NULL,
    `whatsapp_link` VARCHAR(191) NULL,
    `status` ENUM('Rejected', 'Pending', 'Approved') NOT NULL DEFAULT 'Pending',
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,
    `universityId` VARCHAR(191) NULL,
    `experience` INTEGER NULL DEFAULT 0,

    UNIQUE INDEX `koas_profile_user_id_key`(`user_id`),
    UNIQUE INDEX `koas_profile_koas_number_key`(`koas_number`),
    INDEX `koas-profile_universityId_fkey`(`universityId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `pasien_profile` (
    `id` VARCHAR(191) NOT NULL,
    `user_id` VARCHAR(191) NOT NULL,
    `age` VARCHAR(191) NULL,
    `gender` VARCHAR(191) NULL,
    `bio` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    UNIQUE INDEX `pasien_profile_user_id_key`(`user_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `fasilitator_profile` (
    `id` VARCHAR(191) NOT NULL,
    `user_id` VARCHAR(191) NOT NULL,
    `university` VARCHAR(191) NULL,

    UNIQUE INDEX `fasilitator_profile_user_id_key`(`user_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `universities` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `alias` VARCHAR(191) NOT NULL,
    `location` VARCHAR(191) NOT NULL,
    `latitude` DOUBLE NULL,
    `longitude` DOUBLE NULL,
    `image` VARCHAR(191) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `treatment_types` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,
    `alias` VARCHAR(191) NOT NULL,
    `image` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `appointments` (
    `id` VARCHAR(191) NOT NULL,
    `pasien_id` VARCHAR(191) NOT NULL,
    `koas_id` VARCHAR(191) NOT NULL,
    `schedule_id` VARCHAR(191) NOT NULL,
    `timeslot_id` VARCHAR(191) NOT NULL,
    `date` VARCHAR(191) NOT NULL,
    `status` ENUM('Canceled', 'Rejected', 'Pending', 'Confirmed', 'Ongoing', 'Completed') NOT NULL DEFAULT 'Pending',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `appointment_koas_id_fkey`(`koas_id`),
    INDEX `appointment_pasien_id_fkey`(`pasien_id`),
    INDEX `appointment_schedule_id_fkey`(`schedule_id`),
    INDEX `appointment_timeslot_id_fkey`(`timeslot_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateIndex
CREATE INDEX `notifications_koasId_fkey` ON `notifications`(`koasId`);

-- CreateIndex
CREATE INDEX `notifications_senderId_fkey` ON `notifications`(`senderId`);

-- CreateIndex
CREATE INDEX `notifications_userId_fkey` ON `notifications`(`userId`);

-- CreateIndex
CREATE INDEX `koas_id` ON `reviews`(`koas_id`);

-- CreateIndex
CREATE UNIQUE INDEX `VerificationRequest_email_token_key` ON `verificationrequest`(`email`, `token`);

-- AddForeignKey
ALTER TABLE `koas_profile` ADD CONSTRAINT `koas_profile_universityId_fkey` FOREIGN KEY (`universityId`) REFERENCES `universities`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `koas_profile` ADD CONSTRAINT `koas_profile_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `pasien_profile` ADD CONSTRAINT `pasien_profile_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `fasilitator_profile` ADD CONSTRAINT `fasilitator_profile_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `posts` ADD CONSTRAINT `posts_koas_id_fkey` FOREIGN KEY (`koas_id`) REFERENCES `koas_profile`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `posts` ADD CONSTRAINT `posts_treatment_id_fkey` FOREIGN KEY (`treatment_id`) REFERENCES `treatment_types`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `posts` ADD CONSTRAINT `posts_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `likes` ADD CONSTRAINT `likes_post_id_fkey` FOREIGN KEY (`post_id`) REFERENCES `posts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `likes` ADD CONSTRAINT `likes_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `notifications` ADD CONSTRAINT `notifications_koasId_fkey` FOREIGN KEY (`koasId`) REFERENCES `koas_profile`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `notifications` ADD CONSTRAINT `notifications_senderId_fkey` FOREIGN KEY (`senderId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `notifications` ADD CONSTRAINT `notifications_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `schedules` ADD CONSTRAINT `schedules_post_id_fkey` FOREIGN KEY (`post_id`) REFERENCES `posts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `timeslots` ADD CONSTRAINT `timeslots_schedule_id_fkey` FOREIGN KEY (`schedule_id`) REFERENCES `schedules`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `reviews` ADD CONSTRAINT `reviews_koas_id_fkey` FOREIGN KEY (`koas_id`) REFERENCES `koas_profile`(`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `reviews` ADD CONSTRAINT `reviews_post_id_fkey` FOREIGN KEY (`post_id`) REFERENCES `posts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `reviews` ADD CONSTRAINT `reviews_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `appointments` ADD CONSTRAINT `appointments_koas_id_fkey` FOREIGN KEY (`koas_id`) REFERENCES `koas_profile`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `appointments` ADD CONSTRAINT `appointments_pasien_id_fkey` FOREIGN KEY (`pasien_id`) REFERENCES `pasien_profile`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `appointments` ADD CONSTRAINT `appointments_schedule_id_fkey` FOREIGN KEY (`schedule_id`) REFERENCES `schedules`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `appointments` ADD CONSTRAINT `appointments_timeslot_id_fkey` FOREIGN KEY (`timeslot_id`) REFERENCES `timeslots`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- RenameIndex
ALTER TABLE `reviews` RENAME INDEX `user_id` TO `pasien_Id`;
