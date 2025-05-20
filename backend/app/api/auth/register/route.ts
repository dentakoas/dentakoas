// ... existing imports ...

// Add this validation function for koasNumber/NIM
const validateKoasNumber = (value?: string): string | null => {
  if (!value || value.trim() === '') {
    return 'NIM is required.';
  }

  // Check if NIM consists of only digits
  if (!/^\d+$/.test(value)) {
    return 'NIM should contain only numbers.';
  }

  // Check if NIM has the correct length (12 digits based on example 231611101055)
  if (value.length !== 12) {
    return 'NIM should be 12 digits long.';
  }

  // Extract and validate components
  const yearPart = value.substring(0, 2);
  const facultyCode = value.substring(2, 4);
  const departmentCode = value.substring(4, 6);

  // Validate year part (should be 23 or 24)
  if (yearPart !== '23' && yearPart !== '24') {
    return 'Invalid entry year. Year should be 23 or 24.';
  }

  // Validate faculty code (must be 16 for medical faculty)
  if (facultyCode !== '16') {
    return 'Invalid faculty code in NIM. Faculty code should be 16 for Medicine.';
  }

  // Validate department code (must be 11 for a specific department)
  if (departmentCode !== '11') {
    return 'Invalid department code in NIM. Department code should be 11 for Medicine.';
  }

  return null;
};

// ... use this validation in your registration process ...
// For example:
// const koasNumberError = validateKoasNumber(koasNumber);
// if (koasNumberError) {
//   return NextResponse.json({ error: koasNumberError }, { status: 400 });
// }
