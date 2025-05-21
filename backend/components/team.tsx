interface TeamMemberProps {
  name: string;
  role: string;
  image: string;
}

export function TeamMember({ name, role, image }: TeamMemberProps) {
  return (
    <div className="flex flex-col items-center text-center">
      <div className="overflow-hidden rounded-full h-32 w-32 bg-blue-50 mb-4">
        <img
          src={image}
          alt={name}
          className="h-full w-full object-cover"
        />
      </div>
      <h4 className="text-lg font-semibold text-gray-900">{name}</h4>
      <p className="text-gray-500">{role}</p>
    </div>
  );
}