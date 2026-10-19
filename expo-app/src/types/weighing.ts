import {
  formatCellWeight,
  formatCurrency,
  formatWeight,
  moneyToVietnameseWords,
} from '../utils/formatters';

export type SessionType = 'pig';
export type TareMode = 'kgPerUnit' | 'fixedTotalKg';

export interface WeighingEntry {
  id: string;
  weight: number;
  headCount: number;
  timestamp: string;
}

export interface WeighingSession {
  id: string;
  title: string;
  type: SessionType;
  seasonId: string;
  partnerName: string;
  partnerPhone: string;
  createdAt: string;
  rowsPerColumn: 5 | 10;
  entries: WeighingEntry[];
  tareMode: TareMode;
  tareValue: number;
  roundTareToHalfKg: boolean;
  impurityPercent: number;
  impurityFixedKg: number;
  pricePerKg: number;
  depositAmount: number;
  extraCostAmount: number;
  isPaid: boolean;
  note: string;
}

export interface PartnerContact {
  id: string;
  name: string;
  phone: string;
  role: string;
  address: string;
  note: string;
}

export interface SeasonBatch {
  id: string;
  name: string;
  createdAt: string;
}

export interface SessionMetrics {
  totalEntriesCount: number;
  totalHeadCount: number;
  grossWeight: number;
  tareWeight: number;
  impurityWeight: number;
  netWeight: number;
  averageWeight: number;
  totalAmount: number;
  remainingAmount: number;
  columnCount: number;
}

export function computeSessionMetrics(session: WeighingSession): SessionMetrics {
  const totalEntriesCount = session.entries.length;
  const totalHeadCount = session.entries.reduce(
    (sum, item) => sum + (item.headCount || 1),
    0
  );
  const grossWeight = session.entries.reduce(
    (sum, item) => sum + item.weight,
    0
  );

  let rawTare = 0;
  if (totalEntriesCount > 0 && session.tareValue > 0) {
    if (session.tareMode === 'kgPerUnit') {
      rawTare = totalEntriesCount * session.tareValue;
    } else {
      rawTare = session.tareValue;
    }
  }

  const tareWeight = session.roundTareToHalfKg
    ? Math.round(rawTare * 2) / 2
    : Math.round(rawTare * 100) / 100;

  const weightAfterTare = Math.max(0, grossWeight - tareWeight);
  const impurityByPercent = weightAfterTare * (session.impurityPercent / 100);
  const impurityWeight =
    Math.round((impurityByPercent + session.impurityFixedKg) * 100) / 100;

  const netWeight = Math.max(0, weightAfterTare - impurityWeight);
  const averageWeight =
    totalHeadCount > 0 ? netWeight / totalHeadCount : 0;

  const totalAmount = netWeight * session.pricePerKg;
  const remainingAmount =
    totalAmount - session.depositAmount - session.extraCostAmount;

  const columnCount = Math.max(
    1,
    Math.ceil(totalEntriesCount / session.rowsPerColumn)
  );

  return {
    totalEntriesCount,
    totalHeadCount,
    grossWeight,
    tareWeight,
    impurityWeight,
    netWeight,
    averageWeight,
    totalAmount,
    remainingAmount,
    columnCount,
  };
}

export function getColumnEntries(
  session: WeighingSession,
  colIndex: number
): WeighingEntry[] {
  const start = colIndex * session.rowsPerColumn;
  return session.entries.slice(start, start + session.rowsPerColumn);
}

export function getColumnSubtotal(
  session: WeighingSession,
  colIndex: number
): number {
  return getColumnEntries(session, colIndex).reduce(
    (sum, item) => sum + item.weight,
    0
  );
}

export function buildReceiptText(session: WeighingSession): string {
  const m = computeSessionMetrics(session);
  const lines: string[] = [];

  lines.push('📋 PHIẾU CÂN HEO / GIA SÚC');
  lines.push('━━━━━━━━━━━━━━━━━━━━━━━━');
  lines.push(`📌 Phiếu: ${session.title}`);
  lines.push(
    `👤 Khách hàng: ${session.partnerName}${
      session.partnerPhone ? ` (${session.partnerPhone})` : ''
    }`
  );
  lines.push(`🕒 Ngày cân: ${session.createdAt}`);
  lines.push('━━━━━━━━━━━━━━━━━━━━━━━━');

  for (let c = 0; c < m.columnCount; c++) {
    const entries = getColumnEntries(session, c);
    if (!entries.length) continue;
    const equation = entries
      .map((e) => formatCellWeight(e.weight))
      .join(' + ');
    const sub = getColumnSubtotal(session, c);
    lines.push(`Cột ${c + 1}: ${equation}`);
    lines.push(`           = ${formatWeight(sub, true)}`);
  }

  lines.push('━━━━━━━━━━━━━━━━━━━━━━━━');
  lines.push(
    `🐷 Tổng số lượt: ${m.totalEntriesCount} lượt (${m.totalHeadCount} con)`
  );
  lines.push(`⚖️ Tổng cân thô: ${formatWeight(m.grossWeight, true)}`);
  lines.push(`➖ Trừ bì và tạp chất: -${formatWeight(m.tareWeight + m.impurityWeight, true)}`);
  lines.push(`✅ SAU KHI TRỪ BÌ: ${formatWeight(m.netWeight, true)}`);
  lines.push('━━━━━━━━━━━━━━━━━━━━━━━━');
  lines.push(`💵 Giá bán: ${formatCurrency(session.pricePerKg)}/kg`);
  lines.push(`💰 Thành tiền: ${formatCurrency(m.totalAmount)}`);
  lines.push(
    session.depositAmount > 0
      ? `💳 Trừ tiền cọc: -${formatCurrency(session.depositAmount)}`
      : `💳 Trừ tiền cọc: 0 đ`
  );
  if (session.extraCostAmount > 0) {
    lines.push(`🚛 Chi phí phụ: -${formatCurrency(session.extraCostAmount)}`);
  }
  lines.push(`👉 TỔNG TIỀN: ${formatCurrency(m.remainingAmount)}`);
  lines.push(`(${moneyToVietnameseWords(m.remainingAmount)})`);
  lines.push('━━━━━━━━━━━━━━━━━━━━━━━━');
  lines.push(
    `🐷 Bình quân 1 con heo: ${formatWeight(m.averageWeight, true)}/con`
  );
  return lines.join('\n');
}

export const DEMO_SEASONS: SeasonBatch[] = [
  { id: 'season_1', name: 'Đợt Xuất Heo 2026', createdAt: '17/10/2026' },
];

export const DEMO_CONTACTS: PartnerContact[] = [
  {
    id: 'c1',
    name: 'Anh Long',
    phone: '0946876244',
    role: 'Chủ trại',
    address: '217 K4B',
    note: 'Khách mua heo thịt quen',
  },
];

export const DEMO_SESSIONS: WeighingSession[] = [
  {
    id: 'demo_pig_1',
    title: 'Xuất Heo Thịt',
    type: 'pig',
    seasonId: 'season_1',
    partnerName: 'Anh Long',
    partnerPhone: '0946876244',
    createdAt: '17/10/2026 06:30',
    rowsPerColumn: 5,
    entries: [
      115.5, 120.0, 118.5, 122.0, 116.0, 124.5, 119.0, 121.5, 117.0, 123.5,
    ].map((w, idx) => ({
      id: `p_${idx}`,
      weight: w,
      headCount: 1,
      timestamp: '06:30',
    })),
    tareMode: 'kgPerUnit',
    tareValue: 24.5,
    roundTareToHalfKg: false,
    impurityPercent: 0,
    impurityFixedKg: 0,
    pricePerKg: 65000,
    depositAmount: 5000000,
    extraCostAmount: 0,
    isPaid: true,
    note: 'Trừ bì lồng 24.5 kg, đã cọc 5.000.000 đ.',
  },
];
