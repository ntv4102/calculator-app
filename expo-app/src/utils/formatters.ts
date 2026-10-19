export function formatCurrency(amount: number, showSymbol = true): string {
  const rounded = Math.round(amount);
  const formatted = rounded.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  return showSymbol ? `${formatted} đ` : formatted;
}

export function formatThousandsInput(raw: string | number): string {
  const clean = String(raw).replace(/\D/g, '');
  if (!clean) return '';
  return clean.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

export function formatWeight(weight: number, showUnit = false): string {
  const rounded = Math.round(weight * 100) / 100;
  const parts = rounded.toString().split('.');
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  const formatted = parts.join(',');
  return showUnit ? `${formatted} kg` : formatted;
}

export function formatCellWeight(weight: number): string {
  if (Math.abs(weight - Math.round(weight)) < 0.001) {
    return Math.round(weight).toString();
  }
  return weight.toFixed(1);
}

export function parseFastWeight(
  rawInput: string,
  autoOneDecimal: boolean
): number | null {
  const cleaned = rawInput.trim().replace(',', '.');
  if (!cleaned) return null;

  if (cleaned.includes('.')) {
    const val = parseFloat(cleaned);
    return isNaN(val) ? null : val;
  }

  const val = parseFloat(cleaned);
  if (isNaN(val)) return null;

  if (autoOneDecimal && cleaned.length >= 3) {
    return val / 10.0;
  }
  return val;
}

export function formatTareInput(
  raw: string
): { formattedText: string; numericValue: number } {
  const clean = raw.trim().replace(',', '.');
  if (!clean) {
    return { formattedText: '', numericValue: 0 };
  }

  // Nếu người dùng gõ dấu chấm hoặc phẩy thập phân (VD: 24.5, 0.15 hoặc 24.)
  if (clean.includes('.')) {
    const parts = clean.split('.');
    const integerPart = parts[0].replace(/\D/g, '');
    const decimalPart = parts.slice(1).join('').replace(/\D/g, '').slice(0, 2);
    const hasTrailingDot = clean.endsWith('.') && parts.length === 2 && parts[1] === '';
    const formatted = hasTrailingDot
      ? `${integerPart}.`
      : (decimalPart ? `${integerPart}.${decimalPart}` : integerPart);
    const num = parseFloat(formatted) || 0;
    return { formattedText: formatted, numericValue: num };
  }

  const digits = clean.replace(/\D/g, '');
  if (!digits) {
    return { formattedText: '', numericValue: 0 };
  }

  // Tự động nhận diện số lẻ khi gõ từ 3 chữ số trở lên (245 = 24.5, 255 = 25.5, 120 = 12.0)
  if (digits.length >= 3) {
    const formatted = `${digits.slice(0, -1)}.${digits.slice(-1)}`;
    const num = parseFloat(formatted) || 0;
    return { formattedText: formatted, numericValue: num };
  }

  // 1 hoặc 2 chữ số (VD: 8, 10, 12, 15, 20) = giữ nguyên số kg
  const num = parseFloat(digits) || 0;
  return { formattedText: digits, numericValue: num };
}

export function weightToSpeechText(weight: number): string {
  const intPart = Math.floor(weight);
  const decimalPart = Math.round((weight - intPart) * 10);

  if (decimalPart === 0) {
    return `${intPart} ký`;
  }
  return `${intPart} phẩy ${decimalPart} ký`;
}

export function moneyToVietnameseWords(amount: number): string {
  const num = Math.abs(Math.round(amount));
  if (num === 0) return 'Không đồng';

  const digits = [
    'không',
    'một',
    'hai',
    'ba',
    'bốn',
    'năm',
    'sáu',
    'bảy',
    'tám',
    'chín',
  ];
  const units = ['', 'nghìn', 'triệu', 'tỷ', 'nghìn tỷ'];

  function readThreeDigits(n: number, showZeroHundred: boolean): string {
    const hundred = Math.floor(n / 100);
    const ten = Math.floor((n % 100) / 10);
    const unit = n % 10;
    const parts: string[] = [];

    if (hundred > 0 || showZeroHundred) {
      parts.push(`${digits[hundred]} trăm`);
    }

    if (ten > 1) {
      parts.push(`${digits[ten]} mươi`);
      if (unit === 1) parts.push('mốt');
      else if (unit === 4) parts.push('tư');
      else if (unit === 5) parts.push('lăm');
      else if (unit > 0) parts.push(digits[unit]);
    } else if (ten === 1) {
      parts.push('mười');
      if (unit === 5) parts.push('lăm');
      else if (unit > 0) parts.push(digits[unit]);
    } else if (ten === 0 && unit > 0) {
      if (hundred > 0 || showZeroHundred) {
        parts.push('lẻ');
      }
      parts.push(digits[unit]);
    }

    return parts.join(' ');
  }

  let temp = num;
  const groups: number[] = [];
  while (temp > 0) {
    groups.push(temp % 1000);
    temp = Math.floor(temp / 1000);
  }

  const resultParts: string[] = [];
  for (let i = groups.length - 1; i >= 0; i--) {
    if (groups[i] > 0) {
      const showZeroHundred = i < groups.length - 1;
      const groupText = readThreeDigits(groups[i], showZeroHundred);
      resultParts.push(units[i] ? `${groupText} ${units[i]}` : groupText);
    }
  }

  const sentence = resultParts.join(' ').trim();
  if (!sentence) return 'Không đồng';
  const capitalized = sentence.charAt(0).toUpperCase() + sentence.slice(1);
  return `${amount < 0 ? 'Âm ' : ''}${capitalized} đồng`;
}
