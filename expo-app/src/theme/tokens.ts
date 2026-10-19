import { Platform, StyleSheet } from 'react-native';

export const space = {
  xxs: 2,
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 48,
} as const;

export const radius = {
  sm: 8,
  md: 12,
  lg: 16,
  pill: 9999,
} as const;

export const MIN_TOUCH_TARGET = 48;

export interface ThemePalette {
  isDark: boolean;
  background: string;
  surface: string;
  surfaceSubtle: string;
  elevated: string;
  text: string;
  textMuted: string;
  border: string;
  borderStrong: string;
  accentRice: string;
  accentRiceSoft: string;
  accentPig: string;
  accentPigSoft: string;
  onAccent: string;
  danger: string;
  dangerSoft: string;
  success: string;
  successSoft: string;
  warning: string;
  warningSoft: string;
}

export const lightPalette: ThemePalette = {
  isDark: false,
  background: '#F8FAFC',
  surface: '#FFFFFF',
  surfaceSubtle: '#F1F5F9',
  elevated: '#FFFFFF',
  text: '#0F172A',
  textMuted: '#64748B',
  border: '#E2E8F0',
  borderStrong: '#CBD5E1',
  accentRice: '#00B074',
  accentRiceSoft: '#E8F8F2',
  accentPig: '#00B074',
  accentPigSoft: '#E8F8F2',
  onAccent: '#FFFFFF',
  danger: '#EF4444',
  dangerSoft: '#FEE2E2',
  success: '#00B074',
  successSoft: '#E8F8F2',
  warning: '#D97706',
  warningSoft: '#FEF3C7',
};

export const darkPalette: ThemePalette = {
  isDark: true,
  background: '#0E1210',
  surface: '#171D1A',
  surfaceSubtle: '#212925',
  elevated: '#232C27',
  text: '#F1F5F3',
  textMuted: '#A3B1AA',
  border: '#2E3833',
  borderStrong: '#4B5952',
  accentRice: '#4ADE80',
  accentRiceSoft: '#132A1E',
  accentPig: '#F87171',
  accentPigSoft: '#2C1517',
  onAccent: '#09130D',
  danger: '#F87171',
  dangerSoft: '#2D1618',
  success: '#4ADE80',
  successSoft: '#132A1E',
  warning: '#FBBF24',
  warningSoft: '#2B2111',
};

const baseFont = Platform.select({
  ios: { fontFamily: 'System' },
  android: { fontFamily: 'sans-serif' },
  default: {},
});

export const typeScale = StyleSheet.create({
  title: {
    fontSize: 20,
    lineHeight: 26,
    fontWeight: '700',
    ...baseFont,
  },
  sectionTitle: {
    fontSize: 15,
    lineHeight: 20,
    fontWeight: '700',
    ...baseFont,
  },
  body: {
    fontSize: 15,
    lineHeight: 22,
    fontWeight: '400',
    ...baseFont,
  },
  caption: {
    fontSize: 12,
    lineHeight: 16,
    fontWeight: '500',
    ...baseFont,
  },
  tabularDisplay: {
    fontSize: 26,
    lineHeight: 32,
    fontWeight: '700',
    fontVariant: ['tabular-nums'],
    ...baseFont,
  },
  tabularMetric: {
    fontSize: 15,
    lineHeight: 20,
    fontWeight: '700',
    fontVariant: ['tabular-nums'],
    ...baseFont,
  },
  tabularCell: {
    fontSize: 16,
    lineHeight: 20,
    fontWeight: '700',
    fontVariant: ['tabular-nums'],
    ...baseFont,
  },
});
