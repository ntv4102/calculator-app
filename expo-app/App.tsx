import React, { useEffect, useRef, useState } from 'react';
import {
  Animated,
  BackHandler,
  FlatList,
  Image,
  KeyboardAvoidingView,
  Modal,
  Platform,
  Pressable,
  SafeAreaView,
  ScrollView,
  Share,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Speech from 'expo-speech';
import * as Haptics from 'expo-haptics';
import { BlurView } from 'expo-blur';
import Svg, { Path, Rect, Circle, Defs, LinearGradient, Stop } from 'react-native-svg';
import {
  SafeAreaProvider,
  useSafeAreaInsets,
} from 'react-native-safe-area-context';

// ============================================================================
// ICONS FOR FLOATING DOCK (PHONG CÁCH THANH ĐIỀU HƯỚNG MẪU)
// ============================================================================
function TabDiaryIcon({
  color,
  size = 23,
  active = false,
}: {
  color: string;
  size?: number;
  active?: boolean;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Rect
        x="4"
        y="4"
        width="16"
        height="16"
        rx="4.5"
        stroke={color}
        strokeWidth={active ? 2.2 : 1.7}
      />
      <Path
        d="M8 2v4M16 2v4M4 9.5h16"
        stroke={color}
        strokeWidth={active ? 2.2 : 1.7}
        strokeLinecap="round"
      />
      <Path
        d="M8 14h5M8 17h8"
        stroke={color}
        strokeWidth={active ? 2 : 1.5}
        strokeLinecap="round"
      />
    </Svg>
  );
}

function TabTeamsIcon({
  color,
  size = 23,
  active = false,
}: {
  color: string;
  size?: number;
  active?: boolean;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle
        cx="9"
        cy="7"
        r="3.5"
        stroke={color}
        strokeWidth={active ? 2.2 : 1.7}
      />
      <Path
        d="M3 18.5v-.5a4.5 4.5 0 014.5-4.5h3a4.5 4.5 0 014.5 4.5v.5"
        stroke={color}
        strokeWidth={active ? 2.2 : 1.7}
        strokeLinecap="round"
      />
      <Path
        d="M15.5 4.5a3 3 0 010 5.5M18.5 18v-.5a3.8 3.8 0 00-2.8-3.6"
        stroke={color}
        strokeWidth={active ? 2.2 : 1.7}
        strokeLinecap="round"
      />
    </Svg>
  );
}

function TabScoreboardIcon({
  color,
  size = 23,
  active = false,
}: {
  color: string;
  size?: number;
  active?: boolean;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Rect
        x="4"
        y="4"
        width="16"
        height="16"
        rx="4.5"
        stroke={color}
        strokeWidth={active ? 2.2 : 1.7}
      />
      <Path
        d="M4 12h16M12 4v16"
        stroke={color}
        strokeWidth={active ? 2.2 : 1.7}
        strokeLinecap="round"
      />
    </Svg>
  );
}

function TabHistoryIcon({
  color,
  size = 23,
  active = false,
}: {
  color: string;
  size?: number;
  active?: boolean;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx="12" cy="12" r="9" stroke={color} strokeWidth={active ? 2.2 : 1.7} />
      <Path
        d="M12 7v5l3.5 2"
        stroke={color}
        strokeWidth={active ? 2.2 : 1.7}
        strokeLinecap="round"
      />
    </Svg>
  );
}

// ============================================================================
// WISECRYPTO MODERN FINTECH ICONS (DÀNH CHO TRANG CHỦ & PHIẾU CÂN)
// ============================================================================
function IconBell({
  color = '#111827',
  size = 20,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 01-3.46 0"
        stroke={color}
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

function IconSearch({
  color = '#64748B',
  size = 18,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx="11" cy="11" r="7" stroke={color} strokeWidth="1.9" />
      <Path
        d="M20 20l-3.5-3.5"
        stroke={color}
        strokeWidth="1.9"
        strokeLinecap="round"
      />
    </Svg>
  );
}

function IconPlus({
  color = '#FFFFFF',
  size = 18,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M12 5v14M5 12h14"
        stroke={color}
        strokeWidth="2.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

function IconPiggy({
  color = '#00B074',
  size = 22,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M19 11c0-3.866-3.582-7-8-7S3 7.134 3 11c0 2.21 1.173 4.195 3 5.44V19a1 1 0 001 1h2a1 1 0 001-1v-1h2v1a1 1 0 001 1h2a1 1 0 001-1v-2.56c1.827-1.245 3-3.23 3-5.44z"
        stroke={color}
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Circle cx="8.5" cy="10" r="1.2" fill={color} />
      <Path
        d="M21 11h-2M15 11a2 2 0 10-4 0 2 2 0 004 0z"
        stroke={color}
        strokeWidth="1.8"
      />
    </Svg>
  );
}

function IconScale({
  color = '#00B074',
  size = 18,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M12 3v18M6 8l6-2 6 2M6 8l-3 6h6L6 8zm12 0l-3 6h6l-3-6z"
        stroke={color}
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

function IconZalo({
  size = 18,
  color = '#0068FF',
}: {
  size?: number;
  color?: string;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M12 2C6.477 2 2 6.03 2 11c0 2.8 1.45 5.28 3.7 6.87L5 22l4.8-1.78c.7.18 1.44.28 2.2.28 5.523 0 10-4.03 10-9s-4.477-9-10-9z"
        fill={color}
      />
      <Path
        d="M9 8.5h6l-5.5 7h6"
        stroke="#FFFFFF"
        strokeWidth="2.2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

function IconBackArrow({
  color = '#1E293B',
  size = 20,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M19 12H5M12 19l-7-7 7-7"
        stroke={color}
        strokeWidth="2.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

function IconReceipt({
  color = '#00B074',
  size = 18,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M4 2v20l3-2 3 2 3-2 3 2 3-2 3 2V2l-3 2-3-2-3 2-3-2-3 2-3-2z"
        stroke={color}
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M8 8h8M8 12h8M8 16h5"
        stroke={color}
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </Svg>
  );
}

function IconTrash({
  color = '#EF4444',
  size = 17,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M3 6h18M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"
        stroke={color}
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M10 11v6M14 11v6"
        stroke={color}
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </Svg>
  );
}

function IconChart({
  color = '#FFFFFF',
  size = 16,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M18 20V10M12 20V4M6 20v-6"
        stroke={color}
        strokeWidth="2.2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

function IconClock({
  color = '#64748B',
  size = 14,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx="12" cy="12" r="9" stroke={color} strokeWidth="1.9" />
      <Path
        d="M12 7v5l3 2"
        stroke={color}
        strokeWidth="1.9"
        strokeLinecap="round"
      />
    </Svg>
  );
}

function IconHome({
  color = '#0F172A',
  size = 18,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M3 10.5L12 3l9 7.5V20a1.5 1.5 0 01-1.5 1.5h-5a1 1 0 01-1-1v-4a1.5 1.5 0 00-1.5-1.5h-2A1.5 1.5 0 009 16.5v4a1 1 0 01-1 1h-5A1.5 1.5 0 011.5 20V10.5z"
        stroke={color}
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

function IconSpeaker({
  color = '#00B074',
  size = 16,
  muted = false,
}: {
  color?: string;
  size?: number;
  muted?: boolean;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M11 5L6 9H2v6h4l5 4V5z"
        stroke={color}
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      {muted ? (
        <Path
          d="M22 9l-6 6M16 9l6 6"
          stroke={color}
          strokeWidth="1.9"
          strokeLinecap="round"
        />
      ) : (
        <Path
          d="M15.5 8.5a5 5 0 010 7M19 5a10 10 0 010 14"
          stroke={color}
          strokeWidth="1.9"
          strokeLinecap="round"
        />
      )}
    </Svg>
  );
}

function IconUser({
  color = '#64748B',
  size = 14,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx="12" cy="7" r="4" stroke={color} strokeWidth="1.8" />
      <Path
        d="M4 21v-1a7 7 0 0114 0v1"
        stroke={color}
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </Svg>
  );
}

function IconAlertTriangle({
  color = '#EF4444',
  size = 22,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0zM12 9v4M12 17h.01"
        stroke={color}
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

function IconCheck({
  color = '#00B074',
  size = 16,
}: {
  color?: string;
  size?: number;
}) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M20 6L9 17l-5-5"
        stroke={color}
        strokeWidth="2.4"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}
import {
  lightPalette,
  MIN_TOUCH_TARGET,
  radius,
  space,
  ThemePalette,
  typeScale,
} from './src/theme/tokens';
import {
  buildReceiptText,
  computeSessionMetrics,
  DEMO_CONTACTS,
  DEMO_SEASONS,
  DEMO_SESSIONS,
  getColumnEntries,
  getColumnSubtotal,
  PartnerContact,
  SeasonBatch,
  SessionType,
  WeighingEntry,
  WeighingSession,
} from './src/types/weighing';
import {
  formatCellWeight,
  formatCurrency,
  formatTareInput,
  formatThousandsInput,
  formatWeight,
  moneyToVietnameseWords,
  parseFastWeight,
  weightToSpeechText,
} from './src/utils/formatters';

type MainTab = 'sessions' | 'contacts' | 'stats';
type ActiveScreen = 'home' | 'weighing' | 'receipt';
type WeighingSubTab = 'grid' | 'calc';

const STORAGE_KEY_SESSIONS = '@can_heo_sessions_v4';
const STORAGE_KEY_CONTACTS = '@can_heo_contacts_v4';

// ============================================================================
// MOTION & ANIMATION HELPERS (Mobile-Design standard)
// ============================================================================
interface AnimatedModalProps {
  visible: boolean;
  onRequestClose: () => void;
  children: (closeModal: () => void) => React.ReactNode;
  avoidKeyboard?: boolean;
  alignTop?: boolean;
  paddingTop?: number;
}

function AnimatedModal({
  visible,
  onRequestClose,
  children,
  avoidKeyboard = true,
  alignTop = false,
  paddingTop = 48,
}: AnimatedModalProps) {
  const [isRendered, setIsRendered] = useState(visible);
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.92)).current;
  const translateYAnim = useRef(new Animated.Value(16)).current;
  const isClosingRef = useRef(false);

  const startOpenAnimation = () => {
    isClosingRef.current = false;
    fadeAnim.setValue(0);
    scaleAnim.setValue(0.92);
    translateYAnim.setValue(16);

    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 220,
        useNativeDriver: Platform.OS !== 'web',
      }),
      Animated.spring(scaleAnim, {
        toValue: 1,
        tension: 80,
        friction: 8,
        useNativeDriver: Platform.OS !== 'web',
      }),
      Animated.timing(translateYAnim, {
        toValue: 0,
        duration: 220,
        useNativeDriver: Platform.OS !== 'web',
      }),
    ]).start();
  };

  const closeWithAnimation = (onCompleted?: () => void) => {
    if (isClosingRef.current) return;
    isClosingRef.current = true;

    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 0,
        duration: 160,
        useNativeDriver: Platform.OS !== 'web',
      }),
      Animated.timing(scaleAnim, {
        toValue: 0.94,
        duration: 160,
        useNativeDriver: Platform.OS !== 'web',
      }),
      Animated.timing(translateYAnim, {
        toValue: 12,
        duration: 160,
        useNativeDriver: Platform.OS !== 'web',
      }),
    ]).start(() => {
      setIsRendered(false);
      isClosingRef.current = false;
      onRequestClose();
      onCompleted?.();
    });
  };

  useEffect(() => {
    if (visible) {
      setIsRendered(true);
      startOpenAnimation();
    } else if (isRendered && !isClosingRef.current) {
      closeWithAnimation();
    }
  }, [visible]);

  if (!isRendered) return null;

  const content = (
    <Animated.View
      style={{
        width: '100%',
        maxWidth: 440,
        opacity: fadeAnim,
        transform: [{ scale: scaleAnim }, { translateY: translateYAnim }],
      }}
    >
      {children(closeWithAnimation)}
    </Animated.View>
  );

  const insets = useSafeAreaInsets();
  const notchTopInset = Math.max(
    insets.top,
    Platform.OS === 'android' ? (StatusBar.currentHeight || 0) : 44
  );

  return (
    <Modal
      visible={isRendered}
      transparent
      animationType="none"
      statusBarTranslucent
      onRequestClose={() => closeWithAnimation()}
    >
      {/* Nền tối Backdrop tiêu chuẩn (HOÀN TOÀN KHÔNG DÙNG LÀM MỜ / BLUR) */}
      <Animated.View
        style={[
          StyleSheet.absoluteFill,
          {
            backgroundColor: 'rgba(0, 0, 0, 0.45)',
            opacity: fadeAnim,
          },
        ]}
      >
        <Pressable
          accessibilityLabel="Đóng popup"
          style={StyleSheet.absoluteFill}
          onPress={() => closeWithAnimation()}
        />
      </Animated.View>

      {/* Khung chứa Modal chống bị bàn phím che khuất */}
      <View style={{ flex: 1, marginTop: notchTopInset }}>
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : undefined}
          keyboardVerticalOffset={Platform.OS === 'ios' ? 12 : 0}
          style={{ flex: 1 }}
        >
          <ScrollView
            contentContainerStyle={{
              flexGrow: 1,
              justifyContent: alignTop ? 'flex-start' : 'center',
              alignItems: 'center',
              paddingTop: alignTop ? paddingTop : space.md,
              paddingBottom: Math.max(insets.bottom, 20) + 24,
              paddingHorizontal: space.md,
            }}
            keyboardShouldPersistTaps="handled"
            keyboardDismissMode="on-drag"
            showsVerticalScrollIndicator={false}
            bounces={false}
          >
            {content}
          </ScrollView>
        </KeyboardAvoidingView>
      </View>
    </Modal>
  );
}

function AnimatedTabContent({
  children,
}: {
  activeKey?: string;
  children: React.ReactNode;
}) {
  return <View style={{ flex: 1 }}>{children}</View>;
}

export default function App() {
  return (
    <SafeAreaProvider>
      <AppContent />
    </SafeAreaProvider>
  );
}

function AppContent() {
  const insets = useSafeAreaInsets();
  const c: ThemePalette = lightPalette;

  const [sessions, setSessions] = useState<WeighingSession[]>(DEMO_SESSIONS);
  const [contacts, setContacts] = useState<PartnerContact[]>(DEMO_CONTACTS);
  const [seasons] = useState<SeasonBatch[]>(DEMO_SEASONS);
  const [selectedSeasonId, setSelectedSeasonId] = useState<string>('all');

  // Tìm kiếm nhanh phiếu cân
  const [searchQuery, setSearchQuery] = useState<string>('');

  const [mainTab, setMainTab] = useState<MainTab>('sessions');
  const [activeScreen, setActiveScreen] = useState<ActiveScreen>('home');
  const [activeSessionId, setActiveSessionId] = useState<string>(
    DEMO_SESSIONS.find((s) => s.type === 'pig')?.id || DEMO_SESSIONS[0].id
  );
  const [weighingTab, setWeighingTab] = useState<WeighingSubTab>('grid');

  // Numpad & cài đặt nhập nhanh
  const [rawInput, setRawInput] = useState<string>('');
  const [autoOneDecimal, setAutoOneDecimal] = useState<boolean>(true);
  const [voiceEnabled, setVoiceEnabled] = useState<boolean>(true);
  const [pigHeadCountInput, setPigHeadCountInput] = useState<number>(1);
  const [tareInputText, setTareInputText] = useState<string>('');

  // Modal tạo phiếu cân heo mới
  const [showNewModal, setShowNewModal] = useState(false);
  const [newType, setNewType] = useState<SessionType>('pig');
  const [newTitle, setNewTitle] = useState('Xuất Heo Thịt');
  const [newPartnerName, setNewPartnerName] = useState('Anh Long');
  const [newPrice, setNewPrice] = useState('65.000');
  const [newRowsPerCol] = useState<5 | 10>(5);

  // Modal sửa mã cân
  const [editingEntry, setEditingEntry] = useState<{
    entry: WeighingEntry;
    orderNumber: number;
  } | null>(null);
  const [editWeightText, setEditWeightText] = useState('');

  // Modal thêm danh bạ
  const [showContactModal, setShowContactModal] = useState(false);
  const [contactName, setContactName] = useState('');
  const [contactPhone, setContactPhone] = useState('');
  const [contactRole, setContactRole] = useState('Chủ trại');
  const [contactAddress, setContactAddress] = useState('');

  // Modal xác nhận xoá phiếu
  const [deletingSession, setDeletingSession] = useState<WeighingSession | null>(
    null
  );

  // Thông báo trạng thái (Toast nhẹ cho Web & Mobile)
  const [toastMsg, setToastMsg] = useState<string | null>(null);
  const horizontalScrollRef = useRef<React.ComponentRef<typeof ScrollView>>(null);
  const activeSession =
    sessions.find((s) => s.id === activeSessionId) || sessions[0];

  useEffect(() => {
    (async () => {
      try {
        // Xóa sạch storage cũ nếu còn
        await AsyncStorage.removeItem('@can_lua_heo_sessions_v1').catch(() => {});
        await AsyncStorage.removeItem('@can_lua_heo_contacts_v1').catch(() => {});
        await AsyncStorage.removeItem('@can_lua_heo_sessions_v2').catch(() => {});
        await AsyncStorage.removeItem('@can_lua_heo_contacts_v2').catch(() => {});
        await AsyncStorage.removeItem('@can_heo_sessions_v3').catch(() => {});
        await AsyncStorage.removeItem('@can_heo_contacts_v3').catch(() => {});

        const savedSessions = await AsyncStorage.getItem(STORAGE_KEY_SESSIONS);
        if (savedSessions) {
          const parsed: WeighingSession[] = JSON.parse(savedSessions);
          setSessions(parsed);
        } else {
          await AsyncStorage.setItem(STORAGE_KEY_SESSIONS, JSON.stringify(DEMO_SESSIONS)).catch(() => {});
          setSessions(DEMO_SESSIONS);
        }
        const savedContacts = await AsyncStorage.getItem(STORAGE_KEY_CONTACTS);
        if (savedContacts) {
          const parsedContacts: PartnerContact[] = JSON.parse(savedContacts);
          setContacts(parsedContacts);
        } else {
          await AsyncStorage.setItem(STORAGE_KEY_CONTACTS, JSON.stringify(DEMO_CONTACTS)).catch(() => {});
          setContacts(DEMO_CONTACTS);
        }
      } catch {
        // Fallback dữ liệu mẫu
      }
    })();
  }, []);

  // Đồng bộ ô nhập trừ bì khi đổi phiếu cân
  useEffect(() => {
    if (activeSession) {
      setTareInputText(
        activeSession.tareValue > 0 ? String(activeSession.tareValue) : ''
      );
    }
  }, [activeSession?.id]);

  // Tự động cuộn sang cột đang nhập (ví dụ: Cột 3) để tránh bị khuất hoặc lệch UI
  useEffect(() => {
    if (activeScreen === 'weighing' && weighingTab === 'grid' && activeSession) {
      const activeCol = Math.floor(
        (activeSession.entries.length || 0) /
          (activeSession.rowsPerColumn || 5)
      );
      if (activeCol >= 2) {
        const timer1 = setTimeout(() => {
          horizontalScrollRef.current?.scrollToEnd({ animated: true });
        }, 150);
        const timer2 = setTimeout(() => {
          horizontalScrollRef.current?.scrollToEnd({ animated: true });
        }, 400);
        return () => {
          clearTimeout(timer1);
          clearTimeout(timer2);
        };
      }
    }
  }, [
    activeScreen,
    weighingTab,
    activeSessionId,
    activeSession?.entries.length,
  ]);

  useEffect(() => {
    if (Platform.OS === 'android') {
      try {
        (StatusBar as any).setBackgroundColor?.(c.surface, true);
      } catch {}
    }
  }, [c.surface]);

  useEffect(() => {
    const onBackPress = () => {
      if (activeScreen === 'receipt') {
        setActiveScreen('home');
        return true;
      }
      if (activeScreen === 'weighing') {
        setActiveScreen('home');
        return true;
      }
      return false;
    };
    const sub = BackHandler.addEventListener('hardwareBackPress', onBackPress);
    return () => sub.remove();
  }, [activeScreen]);

  const persistSessions = async (next: WeighingSession[]) => {
    setSessions(next);
    try {
      await AsyncStorage.setItem(STORAGE_KEY_SESSIONS, JSON.stringify(next));
    } catch {}
  };

  const showToast = (msg: string) => {
    setToastMsg(msg);
    setTimeout(() => {
      setToastMsg((prev) => (prev === msg ? null : prev));
    }, 2200);
  };

  const triggerHaptic = () => {
    if (Platform.OS !== 'web') {
      Haptics.selectionAsync().catch(() => {});
    }
  };

  const speakVietnameseWeight = (weight: number) => {
    if (!voiceEnabled) return;
    const text = weightToSpeechText(weight);
    try {
      Speech.stop();
      Speech.speak(text, { language: 'vi-VN', rate: 0.95 });
    } catch {}
  };

  const updateActiveSession = (
    updater: (prev: WeighingSession) => WeighingSession
  ) => {
    if (!activeSession) return;
    const next = sessions.map((s) =>
      s.id === activeSession.id ? updater(s) : s
    );
    persistSessions(next);
  };

  const handleKeyTap = (key: string) => {
    triggerHaptic();

    // Tự động cuộn sang cột đang nhập (Cột 3 trở lên) ngay khi người dùng bấm phím số
    if (activeSession) {
      const targetColIndex = Math.floor(
        activeSession.entries.length / activeSession.rowsPerColumn
      );
      if (targetColIndex >= 2) {
        horizontalScrollRef.current?.scrollToEnd({ animated: true });
      }
    }

    if (key === 'C') {
      setRawInput('');
      return;
    }
    if (key === 'BACK') {
      setRawInput((prev) => prev.slice(0, -1));
      return;
    }
    if (key === '.') {
      setRawInput((prev) =>
        prev.includes('.') ? prev : prev === '' ? '0.' : `${prev}.`
      );
      return;
    }
    setRawInput((prev) => (prev.length < 6 ? prev + key : prev));
  };

  const handleSubmitWeight = () => {
    if (!activeSession) return;
    const parsed = parseFastWeight(rawInput, autoOneDecimal);
    if (!parsed || parsed <= 0) {
      showToast('Vui lòng bấm số cân lớn hơn 0 kg');
      return;
    }

    if (Platform.OS !== 'web') {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(
        () => {}
      );
    }

    const now = new Date();
    const timeStr = `${String(now.getHours()).padStart(2, '0')}:${String(
      now.getMinutes()
    ).padStart(2, '0')}`;

    const newEntry: WeighingEntry = {
      id: `e_${Date.now()}_${Math.random().toString(36).slice(2, 6)}`,
      weight: parsed,
      headCount: pigHeadCountInput,
      timestamp: timeStr,
    };

    updateActiveSession((prev) => ({
      ...prev,
      entries: [...prev.entries, newEntry],
    }));

    setRawInput('');
    speakVietnameseWeight(parsed);

    setTimeout(() => {
      horizontalScrollRef.current?.scrollToEnd({ animated: true });
    }, 100);
  };

  const handleCreateSession = () => {
    const now = new Date();
    const dateStr = `${String(now.getDate()).padStart(2, '0')}/${String(
      now.getMonth() + 1
    ).padStart(2, '0')}/${now.getFullYear()} ${String(now.getHours()).padStart(
      2,
      '0'
    )}:${String(now.getMinutes()).padStart(2, '0')}`;

    const created: WeighingSession = {
      id: `s_${Date.now()}`,
      title: newTitle.trim() || 'Xuất Heo Thịt',
      type: 'pig',
      seasonId: selectedSeasonId === 'all' ? 'season_1' : selectedSeasonId,
      partnerName: newPartnerName.trim() || 'Anh Long',
      partnerPhone: '',
      createdAt: dateStr,
      rowsPerColumn: newRowsPerCol,
      entries: [],
      tareMode: 'kgPerUnit',
      tareValue: 24.5,
      roundTareToHalfKg: false,
      impurityPercent: 0,
      impurityFixedKg: 0,
      pricePerKg: parseFloat(newPrice.replace(/\./g, '')) || 65000,
      depositAmount: 0,
      extraCostAmount: 0,
      isPaid: true,
      note: '',
    };

    const next = [created, ...sessions];
    persistSessions(next);
    setActiveSessionId(created.id);
    setTareInputText(String(created.tareValue));
    setWeighingTab('grid');
    setShowNewModal(false);
    setActiveScreen('weighing');
  };

  const handleShareReceipt = async (session: WeighingSession) => {
    const text = buildReceiptText(session);
    if (Platform.OS === 'web' && typeof navigator !== 'undefined' && navigator.clipboard) {
      await navigator.clipboard.writeText(text);
      showToast('Đã sao chép phiếu cân! Mở Zalo và dán (Ctrl+V) để gửi.');
      return;
    }
    try {
      await Share.share({ message: text, title: `Phiếu cân - ${session.title}` });
    } catch {
      showToast('Đã tạo nội dung phiếu cân');
    }
  };

  const homeSummaryStats = React.useMemo(() => {
    let totalAmount = 0;
    let totalWeight = 0;
    let totalHeads = 0;
    let totalCount = 0;

    for (const s of sessions) {
      if (s.type === 'pig') {
        const m = computeSessionMetrics(s);
        totalAmount += m.totalAmount;
        totalWeight += m.netWeight;
        totalHeads += m.totalHeadCount;
        totalCount++;
      }
    }
    return {
      totalAmount,
      totalWeight,
      totalHeads,
      totalCount,
    };
  }, [sessions]);

  const filteredSessions = sessions.filter(
    (s) =>
      s.type === 'pig' &&
      (selectedSeasonId === 'all' || s.seasonId === selectedSeasonId)
  );


  return (
    <View
      style={[
        styles.safeRoot,
        {
          backgroundColor: c.background,
          paddingTop: Math.max(
            insets.top,
            Platform.OS === 'android' ? (StatusBar.currentHeight || 0) : 0
          ),
        },
      ]}
    >
      <StatusBar barStyle={c.isDark ? 'light-content' : 'dark-content'} />
      <View style={styles.responsiveWrapper}>
        {activeScreen === 'home' && (
          <>
            {/* Header chính phong cách Wisecrypto */}
            <View
              style={[
                styles.headerBar,
                { backgroundColor: c.surface, borderBottomColor: '#F1F5F9' },
              ]}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', flex: 1 }}>
                <View style={styles.avatarWrap}>
                  <Image
                    source={require('./assets/icon.png')}
                    style={styles.avatarImg}
                  />
                </View>
                <View style={{ marginLeft: space.md, flex: 1 }}>
                  <Text style={styles.greetingText}>Xin chào, Anh Vũ</Text>
                  <Text style={[styles.headerAppTitle, { color: c.text }]}>
                    Sổ Cân Heo VU
                  </Text>
                </View>
              </View>
            </View>

            {/* Nội dung theo Tab với hiệu ứng chuyển tab mượt mà */}
            <View style={{ flex: 1 }}>
              <AnimatedTabContent activeKey={mainTab}>
                {mainTab === 'sessions' &&
                  renderSessionsTab(c, filteredSessions)}
                {mainTab === 'contacts' && renderContactsTab(c)}
                {mainTab === 'stats' && renderStatsTab(c, filteredSessions)}
              </AnimatedTabContent>
            </View>

            {/* Thanh điều hướng dạng Dock Floating Island (Phong cách Frosted Glass như ảnh mẫu) */}
            <View style={styles.floatingNavContainer} pointerEvents="box-none">
              <View
                style={[
                  styles.floatingNavPill,
                  {
                    height: 56 + Math.max(insets.bottom, 12),
                  },
                ]}
              >
                {/* Lớp kính mờ Frosted Glass */}
                <BlurView
                  intensity={Platform.OS === 'ios' ? 45 : 75}
                  tint={c.isDark ? 'dark' : 'light'}
                  style={StyleSheet.absoluteFill}
                />
                <View
                  style={[
                    StyleSheet.absoluteFill,
                    {
                      backgroundColor: c.isDark
                        ? 'rgba(15, 23, 42, 0.92)'
                        : 'rgba(255, 255, 255, 0.95)',
                      borderTopWidth: 1,
                      borderTopColor: c.isDark
                        ? 'rgba(255, 255, 255, 0.12)'
                        : '#E2E8F0',
                      borderTopLeftRadius: 18,
                      borderTopRightRadius: 18,
                    },
                  ]}
                />

                {/* Hàng các nút Tab */}
                <View
                  style={[
                    styles.floatingNavRow,
                    {
                      paddingBottom: Math.max(insets.bottom, 6),
                    },
                  ]}
                >
                  {(
                    [
                      {
                        id: 'sessions',
                        label: 'Phiếu Cân',
                        IconComponent: TabDiaryIcon,
                      },
                      {
                        id: 'contacts',
                        label: 'Danh Bạ',
                        IconComponent: TabTeamsIcon,
                      },
                      {
                        id: 'stats',
                        label: 'Lịch Sử',
                        IconComponent: TabHistoryIcon,
                      },
                    ] as const
                  ).map((tab) => {
                    const selected = mainTab === tab.id;
                    const activeColor = '#00B074';
                    const inactiveColor = 'rgba(100, 116, 139, 0.72)';
                    const color = selected ? activeColor : inactiveColor;
                    const IconComp = tab.IconComponent;

                    return (
                      <Pressable
                        key={tab.id}
                        accessibilityRole="tab"
                        accessibilityState={{ selected }}
                        accessibilityLabel={tab.label}
                        onPress={() => {
                          if (mainTab !== tab.id) {
                            triggerHaptic();
                            setMainTab(tab.id);
                          }
                        }}
                        style={({ pressed }) => [
                          styles.floatingNavTab,
                          {
                            transform: [{ scale: pressed ? 0.92 : 1 }],
                          },
                        ]}
                      >
                        <IconComp color={color} size={23} active={selected} />
                        <Text
                          style={{
                            fontSize: 11,
                            marginTop: 3,
                            color,
                            fontWeight: selected ? '700' : '500',
                            letterSpacing: 0.2,
                          }}
                        >
                          {tab.label}
                        </Text>
                      </Pressable>
                    );
                  })}
                </View>
              </View>
            </View>
          </>
        )}

        {activeScreen === 'weighing' &&
          activeSession &&
          renderWeighingScreen(c, activeSession)}

        {activeScreen === 'receipt' &&
          activeSession &&
          renderReceiptScreen(c, activeSession)}

        {/* Toast thông báo */}
        {toastMsg && (
          <View
            accessibilityLiveRegion="polite"
            style={[styles.toastBanner, { backgroundColor: c.text }]}
          >
            <Text style={{ color: c.surface, fontWeight: '700', fontSize: 13 }}>
              {toastMsg}
            </Text>
          </View>
        )}

        {/* Modal Tạo phiếu cân mới */}
        {renderNewSessionModal(c)}
        {/* Modal Sửa/Xoá ô số cân */}
        {renderEditEntryModal(c)}
        {/* Modal Thêm Danh bạ */}
        {renderAddContactModal(c)}
        {/* Modal Xác nhận xoá phiếu cân */}
        {renderConfirmDeleteModal(c)}
      </View>
    </View>
  );

  // ============================================================================
  // THẺ PHIẾU CÂN CHUNG (CHIA SẺ CHO TRANG CHỦ & TRANG LỊCH SỬ)
  // ============================================================================
  function renderSessionCard(item: WeighingSession): React.ReactNode {
    const m = computeSessionMetrics(item);

    return (
      <Pressable
        key={item.id}
        accessibilityLabel={`Mở phiếu cân ${item.title}, khách hàng ${item.partnerName}`}
        onPress={() => {
          setActiveSessionId(item.id);
          setWeighingTab('grid');
          setActiveScreen('weighing');
        }}
        style={({ pressed }) => [
          styles.wisecryptoSessionCard,
          {
            backgroundColor: c.surface,
            borderColor: pressed ? '#00B074' : (c.isDark ? c.border : '#E2E8F0'),
            transform: [{ scale: pressed ? 0.99 : 1 }],
          },
        ]}
      >
        {/* Phần hàng đầu: Avatar icon badge + Thông tin khách & phiếu + Số tiền */}
        <View style={styles.cryptoCardTopRow}>
          {/* Icon tròn phong cách Wisecrypto asset */}
          <View style={styles.cryptoAssetIconCircle}>
            <IconPiggy color="#00B074" size={24} />
          </View>

          {/* Giữa: Tên khách hàng & Tên đợt cân & Ngày cân */}
          <View
            style={{ flex: 1, marginLeft: space.md, marginRight: space.xs }}
          >
            <Text
              numberOfLines={1}
              style={[
                typeScale.sectionTitle,
                { color: c.text, fontSize: 16, fontWeight: '800' },
              ]}
            >
              {item.partnerName}
            </Text>
            <Text
              numberOfLines={1}
              style={[
                typeScale.caption,
                { color: c.textMuted, marginTop: 3, fontWeight: '600', fontSize: 12.5 },
              ]}
            >
              {item.title}
            </Text>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 4 }}>
              <IconClock color={c.textMuted} size={11} />
              <Text
                numberOfLines={1}
                style={[
                  typeScale.caption,
                  { color: c.textMuted, fontSize: 11.5, fontWeight: '500' },
                ]}
              >
                {item.createdAt}
              </Text>
            </View>
          </View>

          {/* Phải: Số tiền có border màu nổi bật & Trọng lượng bình quân */}
          <View style={{ alignItems: 'flex-end' }}>
            <View
              style={[
                styles.cryptoAmountBadge,
                {
                  backgroundColor: '#E8F8F2',
                  borderColor: '#00B074',
                },
              ]}
            >
              <Text
                style={{
                  fontSize: 15.5,
                  fontWeight: '900',
                  color: '#00B074',
                  fontVariant: ['tabular-nums'],
                }}
              >
                {formatCurrency(m.totalAmount)}
              </Text>
            </View>
            <Text
              style={{
                fontSize: 11.5,
                fontWeight: '600',
                color: c.textMuted,
                marginTop: 4,
              }}
            >
              {m.totalHeadCount > 0
                ? `TB ${(m.netWeight / m.totalHeadCount).toFixed(1)} kg/con`
                : 'Đang cân'}
            </Text>
          </View>
        </View>

        {/* Dải thông số chi tiết: Số con • Khối lượng • Đơn giá */}
        <View
          style={[
            styles.cryptoSpecsStrip,
            { backgroundColor: '#F8FAFC', borderColor: '#F1F5F9' },
          ]}
        >
          <View style={styles.cryptoSpecItem}>
            <Text style={[styles.cryptoSpecLabel, { color: c.textMuted }]}>
              Số con
            </Text>
            <Text style={[styles.cryptoSpecValue, { color: c.text }]}>
              {m.totalHeadCount}c ({m.totalEntriesCount} lượt)
            </Text>
          </View>

          <View style={styles.cryptoSpecDivider} />

          <View style={styles.cryptoSpecItem}>
            <Text style={[styles.cryptoSpecLabel, { color: c.textMuted }]}>
              Khối lượng tịnh
            </Text>
            <Text style={[styles.cryptoSpecValue, { color: c.text }]}>
              {formatWeight(m.netWeight, true)}
            </Text>
          </View>

          <View style={styles.cryptoSpecDivider} />

          <View style={styles.cryptoSpecItem}>
            <Text style={[styles.cryptoSpecLabel, { color: c.textMuted }]}>
              Đơn giá
            </Text>
            <Text style={[styles.cryptoSpecValue, { color: c.text }]}>
              {formatCurrency(item.pricePerKg)}/kg
            </Text>
          </View>
        </View>

        {/* Hàng nút thao tác nhanh (Touch targets >= 48dp) */}
        <View style={styles.cryptoCardActionRow}>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel={`Xoá phiếu ${item.title}`}
            onPress={() => {
              setDeletingSession(item);
            }}
            style={styles.cryptoTrashBtn}
          >
            <IconTrash color={c.danger} size={17} />
            <Text
              style={{
                color: c.danger,
                fontWeight: '700',
                fontSize: 13,
                marginLeft: 4,
              }}
            >
              Xoá
            </Text>
          </Pressable>

          <View style={{ flexDirection: 'row', gap: space.sm }}>
            <Pressable
              accessibilityRole="button"
              accessibilityLabel="Xem phiếu in và gửi Zalo"
              onPress={() => {
                setActiveSessionId(item.id);
                setActiveScreen('receipt');
              }}
              style={[
                styles.cryptoSecondaryActionBtn,
                { borderColor: c.borderStrong, backgroundColor: c.surface },
              ]}
            >
              <IconZalo size={17} />
              <Text
                style={{
                  color: c.text,
                  fontWeight: '700',
                  fontSize: 13,
                  marginLeft: 5,
                }}
              >
                In / Zalo
              </Text>
            </Pressable>

            <Pressable
              accessibilityRole="button"
              accessibilityLabel="Mở bảng cân"
              onPress={() => {
                setActiveSessionId(item.id);
                setWeighingTab('grid');
                setActiveScreen('weighing');
              }}
              style={[
                styles.cryptoPrimaryActionBtn,
                { backgroundColor: '#E8F8F2' },
              ]}
            >
              <IconScale color="#00B074" size={16} />
              <Text
                style={{
                  color: '#00B074',
                  fontWeight: '800',
                  fontSize: 13,
                  marginLeft: 4,
                }}
              >
                Vào Cân
              </Text>
            </Pressable>
          </View>
        </View>
      </Pressable>
    );
  }

  // ============================================================================
  // TAB 1: TRANG CHỦ (CHỈ 1 PHIẾU CÂN GẦN NHẤT & HERO CARD)
  // ============================================================================
  function renderSessionsTab(
    c: ThemePalette,
    list: WeighingSession[]
  ): React.ReactNode {
    const latestSession = list.length > 0 ? list[0] : null;

    return (
      <ScrollView
        contentContainerStyle={{
          padding: space.lg,
          paddingBottom: 80 + Math.max(insets.bottom, 12) + 24,
        }}
        showsVerticalScrollIndicator={false}
      >
        {/* THẺ TỔNG TIỀN / HERO BALANCE CARD (PHONG CÁCH WISECRYPTO) */}
        <View style={styles.heroCryptoCard}>
          {/* Vòng tròn trang trí mờ tinh tế của Wisecrypto */}
          <View
            pointerEvents="none"
            style={{
              position: 'absolute',
              top: -40,
              right: -30,
              width: 180,
              height: 180,
              borderRadius: 90,
              backgroundColor: 'rgba(255, 255, 255, 0.08)',
            }}
          />
          <View
            pointerEvents="none"
            style={{
              position: 'absolute',
              top: 15,
              right: -10,
              width: 110,
              height: 110,
              borderRadius: 55,
              backgroundColor: 'rgba(255, 255, 255, 0.06)',
            }}
          />
          <View
            pointerEvents="none"
            style={{
              position: 'absolute',
              bottom: -50,
              left: -30,
              width: 140,
              height: 140,
              borderRadius: 70,
              backgroundColor: 'rgba(255, 255, 255, 0.05)',
            }}
          />

          {/* Dòng 1: Tiêu đề thẻ & Badge trạng thái */}
          <View style={styles.heroCardHeaderRow}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
              <View style={styles.heroCardIconPill}>
                <IconScale color="#FFFFFF" size={14} />
              </View>
              <Text style={styles.heroCardSubLabel}>TỔNG TIỀN ĐỢT CÂN</Text>
            </View>

            <View style={styles.heroStatusPill}>
              <Text style={styles.heroStatusPillText}>VND</Text>
            </View>
          </View>

          {/* Dòng 2: Số dư / Tổng tiền lớn nổi bật */}
          <View style={{ marginTop: space.sm }}>
            <Text style={styles.heroBalanceText}>
              {formatCurrency(homeSummaryStats.totalAmount)}
            </Text>
          </View>

          {/* Dòng 3: Dải thông số chi tiết (Tổng khối lượng, Số heo, TB/con) */}
          <View style={styles.heroMetricsStrip}>
            <View style={styles.heroMetricCol}>
              <Text style={styles.heroMetricLabel}>Khối lượng</Text>
              <Text style={styles.heroMetricVal}>
                {formatWeight(homeSummaryStats.totalWeight, true)}
              </Text>
            </View>
            <View style={styles.heroMetricDivider} />
            <View style={styles.heroMetricCol}>
              <Text style={styles.heroMetricLabel}>Tổng xuất</Text>
              <Text style={styles.heroMetricVal}>
                {homeSummaryStats.totalHeads} con
              </Text>
            </View>
            <View style={styles.heroMetricDivider} />
            <View style={styles.heroMetricCol}>
              <Text style={styles.heroMetricLabel}>TB / con</Text>
              <Text style={styles.heroMetricVal}>
                {homeSummaryStats.totalHeads > 0
                  ? `${(homeSummaryStats.totalWeight / homeSummaryStats.totalHeads).toFixed(1)} kg`
                  : '0 kg'}
              </Text>
            </View>
          </View>

          {/* Dòng 4: Hai nút hành động nhanh kiểu Wisecrypto */}
          <View style={styles.heroActionsRow}>
            <Pressable
              accessibilityRole="button"
              accessibilityLabel="Tạo phiếu cân heo mới"
              onPress={() => {
                triggerHaptic();
                setNewType('pig');
                setNewTitle('Xuất Heo Thịt');
                setNewPartnerName('Anh Long');
                setNewPrice('65.000');
                setShowNewModal(true);
              }}
              style={({ pressed }) => [
                styles.heroPrimaryBtn,
                {
                  transform: [{ scale: pressed ? 0.98 : 1 }],
                  opacity: pressed ? 0.92 : 1,
                },
              ]}
            >
              <View style={styles.heroBtnContent}>
                <IconPlus color="#00B074" size={17} />
                <Text style={styles.heroPrimaryBtnText}>Cân Heo Mới</Text>
              </View>
            </Pressable>

            <Pressable
              accessibilityRole="button"
              accessibilityLabel="Xem lịch sử phiếu cân"
              onPress={() => {
                triggerHaptic();
                setMainTab('stats');
              }}
              style={({ pressed }) => [
                styles.heroSecondaryBtn,
                {
                  transform: [{ scale: pressed ? 0.98 : 1 }],
                  opacity: pressed ? 0.88 : 1,
                },
              ]}
            >
              <View style={styles.heroBtnContent}>
                <IconClock color="#FFFFFF" size={16} />
                <Text style={styles.heroSecondaryBtnText}>Lịch Sử</Text>
              </View>
            </Pressable>
          </View>
        </View>

        {/* Tiêu đề danh sách: PHIẾU CÂN GẦN NHẤT */}
        <View
          style={[
            styles.sectionHeaderRow,
            {
              paddingTop: space.md,
              paddingBottom: space.md,
            },
          ]}
        >
          <Text
            style={[
              typeScale.caption,
              { color: c.textMuted, fontWeight: '800', letterSpacing: 0.5 },
            ]}
          >
            PHIẾU CÂN GẦN NHẤT
          </Text>
          {latestSession && (
            <Pressable
              accessibilityRole="button"
              accessibilityLabel={`Xem toàn bộ ${list.length} phiếu trong lịch sử`}
              onPress={() => {
                triggerHaptic();
                setMainTab('stats');
              }}
              hitSlop={10}
              style={{ paddingVertical: 4 }}
            >
              <Text
                style={{
                  color: '#00B074',
                  fontSize: 13,
                  fontWeight: '700',
                }}
              >
                Xem tất cả ({list.length})
              </Text>
            </Pressable>
          )}
        </View>

        {/* Chỉ 1 phiếu cân gần nhất được hiển thị trên Trang Chủ */}
        {latestSession ? (
          <View style={{ marginTop: space.sm }}>
            {renderSessionCard(latestSession)}

            {/* Nút to điều hướng sang Lịch Sử */}
            {list.length > 1 && (
              <Pressable
                accessibilityRole="button"
                accessibilityLabel={`Xem toàn bộ lịch sử cân (${list.length} phiếu)`}
                onPress={() => {
                  triggerHaptic();
                  setMainTab('stats');
                }}
                style={({ pressed }) => [
                  styles.viewAllHistoryBtn,
                  {
                    backgroundColor: c.surface,
                    borderColor: '#E2E8F0',
                    transform: [{ scale: pressed ? 0.98 : 1 }],
                  },
                ]}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                  <IconClock color="#00B074" size={18} />
                  <Text style={{ color: c.text, fontWeight: '700', fontSize: 13.5 }}>
                    Xem toàn bộ lịch sử cân ({list.length} phiếu)
                  </Text>
                </View>
              </Pressable>
            )}
          </View>
        ) : (
          <View
            style={[
              styles.emptyBox,
              { backgroundColor: c.surface, borderColor: c.border, marginTop: space.sm },
            ]}
          >
            <View style={styles.emptyIconCircle}>
              <IconPiggy color="#00B074" size={32} />
            </View>
            <Text
              style={[
                typeScale.sectionTitle,
                { color: c.text, marginTop: space.sm },
              ]}
            >
              Chưa có phiếu cân nào
            </Text>
            <Text
              style={[
                typeScale.body,
                { color: c.textMuted, textAlign: 'center', marginTop: 4 },
              ]}
            >
              Nhấn "Cân Heo Mới" ở thẻ phía trên để bắt đầu đợt cân đầu tiên.
            </Text>
          </View>
        )}
      </ScrollView>
    );
  }

  // ============================================================================
  // MÀN HÌNH BẢNG CÂN NHANH & TÍNH TIỀN (TRÁI TIM CỦA ỨNG DỤNG)
  // ============================================================================
  function renderWeighingScreen(
    c: ThemePalette,
    session: WeighingSession
  ): React.ReactNode {
    const m = computeSessionMetrics(session);
    const accent = c.accentPig;
    const soft = c.accentPigSoft;
    const previewWeight = parseFastWeight(rawInput, autoOneDecimal);
    const totalCols = Math.floor(m.totalEntriesCount / session.rowsPerColumn) + 1;

    return (
      <View style={{ flex: 1 }}>
        {/* AppBar màn hình cân */}
        <View
          style={[
            styles.headerBar,
            { backgroundColor: c.surface, borderBottomColor: c.border },
          ]}
        >
          <Pressable
            accessibilityRole="button"
            accessibilityLabel="Quay lại danh sách phiếu cân"
            hitSlop={8}
            onPress={() => setActiveScreen('home')}
            style={[styles.iconHitButton, { borderColor: c.border }]}
          >
            <IconBackArrow color={c.text} size={20} />
          </Pressable>
          <View style={{ flex: 1, marginLeft: space.sm }}>
            <Text
              numberOfLines={1}
              style={[typeScale.sectionTitle, { color: c.text }]}
            >
              {session.title}
            </Text>
            <Text style={[typeScale.caption, { color: c.textMuted }]}>
              Khách: {session.partnerName}
            </Text>
          </View>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel="Xem phiếu cân và gửi Zalo"
            onPress={() => setActiveScreen('receipt')}
            style={[styles.primaryActionBtn, { backgroundColor: accent }]}
          >
            <Text style={{ color: c.onAccent, fontWeight: '800', fontSize: 12 }}>
              Phiếu Zalo
            </Text>
          </Pressable>
        </View>

        {/* Thanh chuyển Tab: 1. Bảng Cân Nhanh | 2. Trừ Bì & Tính Tiền */}
        <View
          style={{
            flexDirection: 'row',
            backgroundColor: c.surface,
            borderBottomWidth: 1,
            borderBottomColor: c.border,
          }}
        >
          {(
            [
              { id: 'grid', label: '1. BẢNG CÂN NHANH' },
              { id: 'calc', label: '2. TRỪ BÌ & TÍNH TIỀN' },
            ] as const
          ).map((t) => {
            const active = weighingTab === t.id;
            return (
              <Pressable
                key={t.id}
                accessibilityRole="tab"
                accessibilityState={{ selected: active }}
                onPress={() => {
                  triggerHaptic();
                  setWeighingTab(t.id);
                }}
                style={[
                  styles.subTabBtn,
                  active && {
                    borderBottomColor: accent,
                    borderBottomWidth: 3,
                  },
                ]}
              >
                <Text
                  style={{
                    color: active ? accent : c.textMuted,
                    fontWeight: '800',
                    fontSize: 13,
                  }}
                >
                  {t.label}
                </Text>
              </Pressable>
            );
          })}
        </View>

        <AnimatedTabContent activeKey={weighingTab}>
          {weighingTab === 'grid' ? (
            <View style={{ flex: 1 }}>
            {/* Khu vực bảng chia cột (cuộn ngang, 5 dòng tự chia đều chiều cao không cần scroll dọc) */}
            <ScrollView
              ref={horizontalScrollRef}
              horizontal
              showsHorizontalScrollIndicator={false}
              onContentSizeChange={() => {
                const activeCol = Math.floor(
                  (session.entries.length || 0) / (session.rowsPerColumn || 5)
                );
                if (activeCol >= 2) {
                  horizontalScrollRef.current?.scrollToEnd({ animated: true });
                }
              }}
              contentContainerStyle={{
                paddingHorizontal: space.md,
                paddingVertical: space.sm,
                gap: space.sm,
                alignItems: 'stretch',
              }}
              style={{ flex: 1 }}
            >
              {Array.from({ length: totalCols }).map((_, colIdx) => {
                const colEntries = getColumnEntries(session, colIdx);
                const colSub = getColumnSubtotal(session, colIdx);
                const isCurrentCol = colIdx == totalCols - 1;
                const isFiveRows = session.rowsPerColumn === 5;

                const rowsContent = Array.from({
                  length: session.rowsPerColumn,
                }).map((__, rowIdx) => {
                  const globalIdx = colIdx * session.rowsPerColumn + rowIdx;
                  const entry = colEntries[rowIdx];
                  const isNextActive = globalIdx === m.totalEntriesCount;

                  return (
                    <Pressable
                      key={`cell_${globalIdx}`}
                      disabled={!entry}
                      accessibilityRole="button"
                      accessibilityLabel={
                        entry
                          ? `Mã cân số ${globalIdx + 1}, ${formatCellWeight(
                              entry.weight
                            )} kg. Chạm để sửa hoặc xoá.`
                          : `Ô trống số ${globalIdx + 1}`
                      }
                      onPress={() => {
                        if (!entry) return;
                        setEditingEntry({
                          entry,
                          orderNumber: globalIdx + 1,
                        });
                        setEditWeightText(formatCellWeight(entry.weight));
                      }}
                      style={[
                        styles.cellRow,
                        isFiveRows
                          ? { flex: 1, minHeight: 0 }
                          : { minHeight: 38 },
                        {
                          borderBottomColor: c.border,
                          backgroundColor: isNextActive ? soft : 'transparent',
                        },
                      ]}
                    >
                      <Text
                        style={[
                          typeScale.caption,
                          {
                            color: c.textMuted,
                            fontVariant: ['tabular-nums'],
                          },
                        ]}
                      >
                        #{globalIdx + 1}
                      </Text>
                      {entry ? (
                        <View
                          style={{
                            flexDirection: 'row',
                            alignItems: 'center',
                            gap: 4,
                          }}
                        >
                          <Text
                            style={[typeScale.tabularCell, { color: c.text }]}
                          >
                            {formatCellWeight(entry.weight)}
                          </Text>
                          <Text style={{ fontSize: 11, color: c.textMuted }}>
                            ✎
                          </Text>
                        </View>
                      ) : isNextActive ? (
                        <Text
                          style={{
                            fontSize: 13,
                            fontWeight: '800',
                            color: previewWeight ? accent : c.textMuted,
                            fontVariant: ['tabular-nums'],
                          }}
                        >
                          {previewWeight
                            ? `${formatCellWeight(previewWeight)} ✎`
                            : 'Chờ nhập...'}
                        </Text>
                      ) : (
                        <Text style={{ color: c.textMuted }}>—</Text>
                      )}
                    </Pressable>
                  );
                });

                return (
                  <View
                    key={`col_${colIdx}`}
                    style={[
                      styles.columnBox,
                      {
                        backgroundColor: c.surface,
                        borderColor: isCurrentCol ? accent : c.borderStrong,
                        borderWidth: isCurrentCol ? 2 : 1,
                      },
                    ]}
                  >
                    <View
                      style={[
                        styles.columnHeader,
                        {
                          backgroundColor: isCurrentCol
                            ? accent
                            : c.surfaceSubtle,
                        },
                      ]}
                    >
                      <Text
                        style={{
                          color: isCurrentCol ? c.onAccent : c.text,
                          fontWeight: '800',
                          fontSize: 12,
                        }}
                      >
                        CỘT {colIdx + 1}
                      </Text>
                    </View>

                    {isFiveRows ? (
                      <View style={{ flex: 1 }}>{rowsContent}</View>
                    ) : (
                      <ScrollView style={{ flex: 1 }}>{rowsContent}</ScrollView>
                    )}

                    <View
                      style={[
                        styles.columnFooter,
                        { backgroundColor: soft, borderTopColor: c.border },
                      ]}
                    >
                      <Text
                        style={[
                          typeScale.caption,
                          { color: c.textMuted, fontWeight: '700' },
                        ]}
                      >
                        Tổng:
                      </Text>
                      <Text style={[typeScale.tabularMetric, { color: accent }]}>
                        {formatCellWeight(colSub)} kg
                      </Text>
                    </View>
                  </View>
                );
              })}
            </ScrollView>

            {/* Bàn phím bấm nhanh 1 tay ngoài đồng */}
            <View
              style={[
                styles.numpadContainer,
                {
                  backgroundColor: c.surface,
                  borderTopColor: c.borderStrong,
                  paddingBottom: Math.max(insets.bottom, 10),
                },
              ]}
            >
              {/* Thanh chip tuỳ chọn nhanh */}
              <ScrollView
                horizontal
                showsHorizontalScrollIndicator={false}
                contentContainerStyle={{ gap: space.sm, marginBottom: 6 }}
              >
                <Pressable
                  accessibilityRole="button"
                  onPress={() => setAutoOneDecimal((v) => !v)}
                  style={[
                    styles.toggleChip,
                    {
                      backgroundColor: autoOneDecimal ? soft : c.surfaceSubtle,
                      borderColor: autoOneDecimal ? accent : c.borderStrong,
                    },
                  ]}
                >
                  <Text
                    style={{
                      fontSize: 12,
                      fontWeight: '700',
                      color: autoOneDecimal ? accent : c.text,
                    }}
                  >
                    {autoOneDecimal
                      ? '✓ Tự thêm 1 số lẻ (525 = 52.5)'
                      : 'Bấm dấu chấm thủ công'}
                  </Text>
                </Pressable>

                <Pressable
                  accessibilityRole="button"
                  onPress={() => setVoiceEnabled((v) => !v)}
                  style={[
                    styles.toggleChip,
                    {
                      backgroundColor: voiceEnabled ? soft : c.surfaceSubtle,
                      borderColor: voiceEnabled ? accent : c.borderStrong,
                    },
                  ]}
                >
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: 5 }}>
                    <IconSpeaker
                      color={voiceEnabled ? accent : c.textMuted}
                      size={15}
                      muted={!voiceEnabled}
                    />
                    <Text
                      style={{
                        fontSize: 12,
                        fontWeight: '700',
                        color: voiceEnabled ? accent : c.textMuted,
                      }}
                    >
                      {voiceEnabled ? 'Đọc tiếng Việt: BẬT' : 'Đọc số: TẮT'}
                    </Text>
                  </View>
                </Pressable>
              </ScrollView>

              {/* Màn hình hiển thị số đang gõ */}
              <View
                style={[
                  styles.inputPreviewBar,
                  {
                    backgroundColor: c.surfaceSubtle,
                    borderColor: rawInput ? accent : c.borderStrong,
                  },
                ]}
              >
                <View style={{ flex: 1 }}>
                  <Text
                    style={[
                      typeScale.caption,
                      { color: c.textMuted, fontWeight: '700' },
                    ]}
                  >
                    Mã #{m.totalEntriesCount + 1} • Cột {totalCols}
                  </Text>
                  <Text
                    numberOfLines={1}
                    style={{
                      fontSize: 12,
                      fontWeight: '700',
                      color: previewWeight ? accent : c.textMuted,
                    }}
                  >
                    {previewWeight
                      ? `Sẽ lưu: ${formatCellWeight(
                          previewWeight
                        )} kg (${weightToSpeechText(previewWeight)})`
                      : 'Bấm số cân bên dưới rồi nhấn LƯU'}
                  </Text>
                </View>
                <Text
                  style={[
                    typeScale.tabularDisplay,
                    { fontSize: 24, color: rawInput ? c.text : c.textMuted },
                  ]}
                >
                  {rawInput || '0.0'}
                </Text>
              </View>

              {/* Lưới phím số */}
              <View style={{ flexDirection: 'row', gap: space.sm }}>
                <View style={{ flex: 3, gap: 5 }}>
                  {[
                    ['7', '8', '9'],
                    ['4', '5', '6'],
                    ['1', '2', '3'],
                    ['C', '0', '.'],
                  ].map((row, rIdx) => (
                    <View
                      key={`r_${rIdx}`}
                      style={{ flexDirection: 'row', gap: 5 }}
                    >
                      {row.map((k) => {
                        const isClear = k === 'C';
                        return (
                          <Pressable
                            key={k}
                            accessibilityRole="button"
                            accessibilityLabel={
                              isClear ? 'Xoá toàn bộ số đang gõ' : `Phím số ${k}`
                            }
                            onPress={() => handleKeyTap(k)}
                            style={({ pressed }) => [
                              styles.numKey,
                              {
                                backgroundColor: isClear
                                  ? c.dangerSoft
                                  : pressed
                                  ? c.surfaceSubtle
                                  : c.surface,
                                borderColor: isClear
                                  ? c.danger
                                  : c.borderStrong,
                              },
                            ]}
                          >
                            <Text
                              style={[
                                typeScale.tabularDisplay,
                                {
                                  fontSize: 21,
                                  color: isClear ? c.danger : c.text,
                                },
                              ]}
                            >
                              {k}
                            </Text>
                          </Pressable>
                        );
                      })}
                    </View>
                  ))}
                </View>

                <View style={{ flex: 1.15, gap: 5 }}>
                  <Pressable
                    accessibilityRole="button"
                    accessibilityLabel="Xoá lùi 1 chữ số"
                    onPress={() => handleKeyTap('BACK')}
                    style={({ pressed }) => [
                      styles.sideActionKey,
                      {
                        height: 58,
                        backgroundColor: pressed
                          ? c.border
                          : c.surfaceSubtle,
                        borderColor: c.borderStrong,
                      },
                    ]}
                  >
                    <Text
                      style={{
                        color: c.text,
                        fontWeight: '800',
                        fontSize: 13,
                      }}
                    >
                      ⌫ XOÁ LÙI
                    </Text>
                  </Pressable>

                  <Pressable
                    accessibilityRole="button"
                    accessibilityLabel="Lưu mã cân"
                    onPress={handleSubmitWeight}
                    style={({ pressed }) => [
                      styles.sideActionKey,
                      {
                        height: 128,
                        backgroundColor: accent,
                        borderColor: accent,
                        opacity: pressed ? 0.88 : 1,
                      },
                    ]}
                  >
                    <Text
                      style={{
                        color: c.onAccent,
                        fontWeight: '900',
                        fontSize: 15,
                        textAlign: 'center',
                      }}
                    >
                      {previewWeight
                        ? `✓ LƯU\n${formatCellWeight(previewWeight)} kg`
                        : '✓ NHẬP\n(LƯU)'}
                    </Text>
                  </Pressable>
                </View>
              </View>
            </View>
          </View>
        ) : (
          renderCalculationSubTab(c, session, m, accent, soft)
        )}
        </AnimatedTabContent>
      </View>
    );
  }

  // ============================================================================
  // TAB PHỤ 2: TRỪ BÌ, TẠP CHẤT, ĐƠN GIÁ & TIỀN CỌC
  // ============================================================================
  function renderCalculationSubTab(
    c: ThemePalette,
    session: WeighingSession,
    m: ReturnType<typeof computeSessionMetrics>,
    accent: string,
    soft: string
  ): React.ReactNode {
    const tarePresets = [15, 20, 24.5, 25.5];
    const pricePresets = [60000, 65000, 70000];

    return (
      <ScrollView
        contentContainerStyle={{
          padding: space.lg,
          gap: space.md,
          paddingBottom: Math.max(insets.bottom + 24, 40),
        }}
      >
        {/* Khối 1: Quy tắc trừ bì */}
        <View
          style={[
            styles.sectionBox,
            { backgroundColor: c.surface, borderColor: c.border },
          ]}
        >
          <Text style={[typeScale.sectionTitle, { color: c.text }]}>
            1. QUY TẮC TRỪ BÌ LỒNG HEO
          </Text>

          <Text style={[typeScale.caption, { color: c.textMuted, marginTop: space.sm }]}>
            Số kg trừ bì trên mỗi lồng heo (kg/lồng):
          </Text>

          <View style={{ position: 'relative', justifyContent: 'center' }}>
            <TextInput
              value={
                tareInputText !== ''
                  ? tareInputText
                  : session.tareValue > 0
                  ? String(session.tareValue)
                  : ''
              }
              placeholder="0"
              placeholderTextColor={c.textMuted}
              keyboardType="decimal-pad"
              onChangeText={(val) => {
                const { formattedText, numericValue } = formatTareInput(val);
                setTareInputText(formattedText);
                updateActiveSession((prev) => ({ ...prev, tareValue: numericValue }));
              }}
              style={[
                styles.inputField,
                {
                  color: c.text,
                  borderColor: c.borderStrong,
                  backgroundColor: c.background,
                  paddingRight:
                    (tareInputText !== '' || session.tareValue > 0) ? 42 : 12,
                  fontWeight: '700',
                  fontSize: 18,
                },
              ]}
            />
            {(tareInputText !== '' || session.tareValue > 0) && (
              <Pressable
                accessibilityLabel="Xóa giá trị trừ bì"
                accessibilityRole="button"
                onPress={() => {
                  setTareInputText('');
                  updateActiveSession((prev) => ({ ...prev, tareValue: 0 }));
                }}
                hitSlop={10}
                style={{
                  position: 'absolute',
                  right: 12,
                  width: 24,
                  height: 24,
                  borderRadius: 12,
                  backgroundColor: c.surfaceSubtle,
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Text style={{ fontSize: 13, color: c.textMuted, fontWeight: '700' }}>✕</Text>
              </Pressable>
            )}
          </View>

          {/* Gợi ý định dạng nhanh số lẻ */}
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              backgroundColor: '#F0FDF4',
              borderColor: '#86EFAC',
              borderWidth: 1,
              borderRadius: 8,
              paddingHorizontal: 10,
              paddingVertical: 6,
            }}
          >
            <Text style={{ fontSize: 12, color: '#166534', fontWeight: '600' }}>
              💡 Gõ nhanh: 245 = 24.5 kg • 255 = 25.5 kg
            </Text>
          </View>

          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: space.sm }}>
            {tarePresets.map((preset) => (
              <Pressable
                key={String(preset)}
                accessibilityRole="button"
                onPress={() => {
                  setTareInputText(String(preset));
                  updateActiveSession((prev) => ({ ...prev, tareValue: preset }));
                }}
                style={[
                  styles.presetChip,
                  {
                    backgroundColor: c.surfaceSubtle,
                    borderColor: c.borderStrong,
                  },
                ]}
              >
                <Text style={{ color: c.text, fontWeight: '700', fontSize: 12 }}>
                  {preset} kg
                </Text>
              </Pressable>
            ))}
          </View>

          <View
            style={[
              styles.rowBetween,
              {
                backgroundColor: c.dangerSoft,
                borderColor: c.danger,
                borderWidth: 1.5,
                borderRadius: 10,
                paddingHorizontal: space.md,
                paddingVertical: 10,
                marginTop: space.sm,
              },
            ]}
          >
            <Text style={[typeScale.body, { color: c.text, fontWeight: '800' }]}>
              Số kg trừ bì tự động tính:
            </Text>
            <Text
              style={[
                typeScale.tabularMetric,
                { color: c.danger, fontWeight: '900', fontSize: 18 },
              ]}
            >
              - {formatWeight(m.tareWeight, true)}
            </Text>
          </View>
        </View>

        {/* Khối 2: Đơn giá & Tiền đặt cọc */}
        <View
          style={[
            styles.sectionBox,
            { backgroundColor: c.surface, borderColor: c.border },
          ]}
        >
          <Text style={[typeScale.sectionTitle, { color: c.text }]}>
            2. ĐƠN GIÁ & TIỀN ĐẶT CỌC
          </Text>

          <Text style={[typeScale.caption, { color: c.textMuted, marginTop: space.sm }]}>
            Đơn giá thu mua (VNĐ / 1 kg):
          </Text>
          <TextInput
            value={formatThousandsInput(session.pricePerKg || '')}
            placeholder="Ví dụ: 65.000"
            placeholderTextColor={c.textMuted}
            keyboardType="numeric"
            onChangeText={(val) => {
              const num = parseFloat(val.replace(/\D/g, '')) || 0;
              updateActiveSession((prev) => ({ ...prev, pricePerKg: num }));
            }}
            style={[
              styles.inputField,
              {
                color: c.text,
                borderColor: c.borderStrong,
                backgroundColor: c.background,
              },
            ]}
          />

          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: space.sm }}>
            {pricePresets.map((p) => (
              <Pressable
                key={String(p)}
                accessibilityRole="button"
                onPress={() =>
                  updateActiveSession((prev) => ({ ...prev, pricePerKg: p }))
                }
                style={[
                  styles.presetChip,
                  {
                    backgroundColor: c.surfaceSubtle,
                    borderColor: c.borderStrong,
                  },
                ]}
              >
                <Text style={{ color: c.text, fontWeight: '700', fontSize: 12 }}>
                  {formatCurrency(p, false)} đ
                </Text>
              </Pressable>
            ))}
          </View>

          <View style={{ flexDirection: 'row', gap: space.sm, marginTop: space.sm }}>
            <View style={{ flex: 1 }}>
              <Text style={[typeScale.caption, { color: c.textMuted }]}>
                Tiền đặt cọc trước (đ):
              </Text>
              <TextInput
                value={formatThousandsInput(session.depositAmount || '')}
                placeholder="0"
                placeholderTextColor={c.textMuted}
                keyboardType="numeric"
                onChangeText={(val) => {
                  const num = parseFloat(val.replace(/\D/g, '')) || 0;
                  updateActiveSession((prev) => ({
                    ...prev,
                    depositAmount: num,
                  }));
                }}
                style={[
                  styles.inputField,
                  {
                    color: c.text,
                    borderColor: c.borderStrong,
                    backgroundColor: c.background,
                  },
                ]}
              />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={[typeScale.caption, { color: c.textMuted }]}>
                Trừ tạp chất / độ ẩm (kg):
              </Text>
              <TextInput
                value={String(session.impurityFixedKg || '')}
                placeholder="0"
                placeholderTextColor={c.textMuted}
                keyboardType="numeric"
                onChangeText={(val) => {
                  const num = parseFloat(val.replace(',', '.')) || 0;
                  updateActiveSession((prev) => ({
                    ...prev,
                    impurityFixedKg: num,
                  }));
                }}
                style={[
                  styles.inputField,
                  {
                    color: c.text,
                    borderColor: c.borderStrong,
                    backgroundColor: c.background,
                  },
                ]}
              />
            </View>
          </View>
        </View>

        {/* Khối 3: Tổng kết thanh toán */}
        <View
          style={[
            styles.sectionBox,
            {
              backgroundColor: c.surface,
              borderColor: accent,
              borderWidth: 2,
            },
          ]}
        >
          <Text style={[typeScale.sectionTitle, { color: c.text }]}>
            TỔNG KẾT THANH TOÁN PHIẾU CÂN
          </Text>
          <View style={[styles.divider, { backgroundColor: c.border }]} />

          {/* 1. Tổng cân thô */}
          <View style={styles.receiptMetricRow}>
            <Text style={{ color: c.textMuted }}>Tổng cân thô:</Text>
            <Text style={[typeScale.tabularMetric, { color: c.text }]}>
              {formatWeight(m.grossWeight, true)}
            </Text>
          </View>

          {/* 2. Trừ bì và tạp chất */}
          <View style={styles.receiptMetricRow}>
            <Text style={{ color: c.textMuted }}>Trừ bì và tạp chất:</Text>
            <Text style={[typeScale.tabularMetric, { color: c.danger }]}>
              - {formatWeight(m.tareWeight + m.impurityWeight, true)}
            </Text>
          </View>

          {/* 3. Sau khi trừ bì */}
          <View style={styles.receiptMetricRow}>
            <Text style={{ color: c.text, fontWeight: '800' }}>
              SAU KHI TRỪ BÌ:
            </Text>
            <Text style={[typeScale.tabularMetric, { color: accent, fontWeight: '900' }]}>
              {formatWeight(m.netWeight, true)}
            </Text>
          </View>

          <View style={[styles.divider, { backgroundColor: c.border }]} />

          {/* 4. Giá bán */}
          <View style={styles.receiptMetricRow}>
            <Text style={{ color: c.textMuted }}>Giá bán:</Text>
            <Text style={[typeScale.tabularMetric, { color: c.text }]}>
              {formatCurrency(session.pricePerKg)} / kg
            </Text>
          </View>

          {/* 5. Thành tiền */}
          <View style={styles.receiptMetricRow}>
            <Text style={{ color: c.textMuted }}>Thành tiền:</Text>
            <Text style={[typeScale.tabularMetric, { color: c.text }]}>
              {formatCurrency(m.totalAmount)}
            </Text>
          </View>

          {/* 6. Trừ tiền cọc */}
          <View style={styles.receiptMetricRow}>
            <Text style={{ color: c.textMuted }}>Trừ tiền cọc:</Text>
            <Text
              style={[
                typeScale.tabularMetric,
                { color: session.depositAmount > 0 ? c.danger : c.textMuted },
              ]}
            >
              {session.depositAmount > 0
                ? `- ${formatCurrency(session.depositAmount)}`
                : '0 đ'}
            </Text>
          </View>

          {/* 7. Tổng tiền */}
          <View
            style={[
              styles.highlightTotalBox,
              {
                backgroundColor: soft,
                marginTop: space.md,
                paddingVertical: 14,
                paddingHorizontal: 14,
              },
            ]}
          >
            <View style={styles.rowBetween}>
              <Text style={{ color: c.text, fontWeight: '900', fontSize: 16 }}>
                TỔNG TIỀN:
              </Text>
              <Text
                style={[
                  typeScale.tabularDisplay,
                  { color: accent, fontSize: 22 },
                ]}
              >
                {formatCurrency(m.remainingAmount)}
              </Text>
            </View>
            <Text
              style={[
                typeScale.caption,
                { color: c.textMuted, fontStyle: 'italic', marginTop: 4 },
              ]}
            >
              Bằng chữ: {moneyToVietnameseWords(m.remainingAmount)}
            </Text>
          </View>

          {/* 8. Bình quân 1 con heo */}
          <View
            style={[
              styles.rowBetween,
              {
                backgroundColor: c.surfaceSubtle,
                paddingHorizontal: space.md,
                paddingVertical: 12,
                borderRadius: radius.sm,
                marginTop: space.md,
              },
            ]}
          >
            <Text style={{ color: c.text, fontWeight: '700', fontSize: 14 }}>
              Bình quân 1 con heo:
            </Text>
            <Text style={[typeScale.tabularMetric, { color: accent, fontWeight: '800', fontSize: 15 }]}>
              {formatWeight(m.averageWeight, true)} / con
            </Text>
          </View>

          <Pressable
            accessibilityRole="button"
            onPress={() => setActiveScreen('receipt')}
            style={[
              styles.fullWidthBtn,
              { backgroundColor: accent, marginTop: space.sm },
            ]}
          >
            <Text style={{ color: c.onAccent, fontWeight: '800', fontSize: 15 }}>
              XEM PHIẾU CÂN & GỬI ZALO
            </Text>
          </Pressable>
        </View>
      </ScrollView>
    );
  }

  // ============================================================================
  // MÀN HÌNH XEM TRƯỚC PHIẾU CÂN & CHIA SẺ ZALO
  // ============================================================================
  function renderReceiptScreen(
    c: ThemePalette,
    session: WeighingSession
  ): React.ReactNode {
    const m = computeSessionMetrics(session);
    const accent = c.accentPig;
    const soft = c.accentPigSoft;

    return (
      <View style={{ flex: 1 }}>
        <View
          style={[
            styles.headerBar,
            { backgroundColor: c.surface, borderBottomColor: c.border },
          ]}
        >
          <Pressable
            accessibilityRole="button"
            accessibilityLabel="Quay lại trang chủ"
            hitSlop={8}
            onPress={() => setActiveScreen('home')}
            style={[styles.iconHitButton, { borderColor: c.border }]}
          >
            <IconBackArrow color={c.text} size={20} />
          </Pressable>
          <Text
            style={[
              typeScale.sectionTitle,
              { color: c.text, flex: 1, marginLeft: space.sm },
            ]}
          >
            Phiếu Cân & Gửi Zalo
          </Text>
          <Pressable
            accessibilityRole="button"
            onPress={() => handleShareReceipt(session)}
            style={[styles.primaryActionBtn, { backgroundColor: accent }]}
          >
            <Text style={{ color: c.onAccent, fontWeight: '800', fontSize: 13 }}>
              Sao chép / Gửi Zalo
            </Text>
          </Pressable>
        </View>

        <ScrollView
          contentContainerStyle={{
            padding: space.lg,
            paddingBottom: Math.max(insets.bottom + 32, 48),
          }}
        >
          <View
            style={[
              styles.sectionBox,
              { backgroundColor: c.surface, borderColor: c.borderStrong },
            ]}
          >
            <View style={{ alignItems: 'center' }}>
              <View style={[styles.badge, { backgroundColor: soft }]}>
                <Text
                  style={{ color: accent, fontWeight: '900', fontSize: 13 }}
                >
                  PHIẾU CÂN HEO / GIA SÚC
                </Text>
              </View>
              <Text
                style={[
                  typeScale.title,
                  { color: c.text, marginTop: space.xs, textAlign: 'center' },
                ]}
              >
                {session.title}
              </Text>
              <Text
                style={[
                  typeScale.body,
                  {
                    color: c.text,
                    fontWeight: '700',
                    marginTop: space.xs,
                    textAlign: 'center',
                  },
                ]}
              >
                Khách hàng: {session.partnerName}
              </Text>
              <View
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 4,
                  marginTop: 3,
                }}
              >
                <IconClock color={c.textMuted} size={13} />
                <Text
                  style={[
                    typeScale.caption,
                    { color: c.textMuted },
                  ]}
                >
                  Ngày cân: {session.createdAt}
                </Text>
              </View>
            </View>

            <View style={[styles.divider, { backgroundColor: c.border }]} />

            <Text
              style={[
                typeScale.caption,
                { color: c.textMuted, fontWeight: '800', marginBottom: 6 },
              ]}
            >
              CHI TIẾT CÁC CỘT MÃ CÂN (kg):
            </Text>
            {Array.from({ length: m.columnCount }).map((_, colIdx) => {
              const entries = getColumnEntries(session, colIdx);
              const sub = getColumnSubtotal(session, colIdx);
              return (
                <View
                  key={`rc_${colIdx}`}
                  style={[
                    styles.receiptColRow,
                    {
                      flexDirection: 'column',
                      alignItems: 'stretch',
                      backgroundColor: c.surfaceSubtle,
                      borderColor: c.border,
                      borderWidth: 1,
                      borderRadius: radius.sm,
                      marginBottom: space.sm,
                      paddingVertical: 12,
                      paddingHorizontal: space.md,
                    },
                  ]}
                >
                  <ScrollView
                    horizontal
                    showsHorizontalScrollIndicator={false}
                    contentContainerStyle={{
                      flexDirection: 'row',
                      alignItems: 'center',
                    }}
                  >
                    <Text
                      style={{
                        fontWeight: '800',
                        color: c.text,
                        fontSize: 13,
                        marginRight: 6,
                      }}
                    >
                      Cột {colIdx + 1}:
                    </Text>
                    <Text
                      style={{
                        fontWeight: '800',
                        color: c.text,
                        fontSize: 13,
                        fontVariant: ['tabular-nums'],
                      }}
                    >
                      {entries
                        .map((e) => formatCellWeight(e.weight))
                        .join(' + ')}
                    </Text>
                  </ScrollView>
                  <View style={{ alignItems: 'flex-end', marginTop: 4 }}>
                    <Text
                      style={[
                        typeScale.tabularMetric,
                        {
                          color: accent,
                          fontWeight: '900',
                          fontSize: 14,
                        },
                      ]}
                    >
                      = {formatCellWeight(sub)} kg
                    </Text>
                  </View>
                </View>
              );
            })}

            <View style={[styles.divider, { backgroundColor: c.border }]} />

            <View style={styles.receiptMetricRow}>
              <Text style={{ color: c.textMuted }}>Tổng số lượt (con):</Text>
              <Text style={[typeScale.tabularMetric, { color: c.text }]}>
                {`${m.totalEntriesCount} lượt (${m.totalHeadCount} con)`}
              </Text>
            </View>

            {/* 1. Tổng cân thô */}
            <View style={styles.receiptMetricRow}>
              <Text style={{ color: c.textMuted }}>Tổng cân thô:</Text>
              <Text style={[typeScale.tabularMetric, { color: c.text }]}>
                {formatWeight(m.grossWeight, true)}
              </Text>
            </View>

            {/* 2. Trừ bì và tạp chất */}
            <View style={styles.receiptMetricRow}>
              <Text style={{ color: c.textMuted }}>Trừ bì và tạp chất:</Text>
              <Text style={[typeScale.tabularMetric, { color: c.danger }]}>
                - {formatWeight(m.tareWeight + m.impurityWeight, true)}
              </Text>
            </View>

            {/* 3. Sau khi trừ bì */}
            <View style={styles.receiptMetricRow}>
              <Text style={{ color: c.text, fontWeight: '800' }}>
                SAU KHI TRỪ BÌ:
              </Text>
              <Text style={[typeScale.tabularMetric, { color: accent, fontWeight: '900' }]}>
                {formatWeight(m.netWeight, true)}
              </Text>
            </View>

            <View style={[styles.divider, { backgroundColor: c.border }]} />

            {/* 4. Giá bán */}
            <View style={styles.receiptMetricRow}>
              <Text style={{ color: c.textMuted }}>Giá bán:</Text>
              <Text style={[typeScale.tabularMetric, { color: c.text }]}>
                {formatCurrency(session.pricePerKg)} / kg
              </Text>
            </View>

            {/* 5. Thành tiền */}
            <View style={styles.receiptMetricRow}>
              <Text style={{ color: c.textMuted }}>Thành tiền:</Text>
              <Text style={[typeScale.tabularMetric, { color: c.text }]}>
                {formatCurrency(m.totalAmount)}
              </Text>
            </View>

            {/* 6. Trừ tiền cọc */}
            <View style={styles.receiptMetricRow}>
              <Text style={{ color: c.textMuted }}>Trừ tiền cọc:</Text>
              <Text
                style={[
                  typeScale.tabularMetric,
                  { color: session.depositAmount > 0 ? c.danger : c.textMuted },
                ]}
              >
                {session.depositAmount > 0
                  ? `- ${formatCurrency(session.depositAmount)}`
                  : '0 đ'}
              </Text>
            </View>

            {/* 7. Tổng tiền */}
            <View
              style={[
                styles.highlightTotalBox,
                {
                  backgroundColor: soft,
                  marginTop: space.md,
                  paddingVertical: 14,
                  paddingHorizontal: 14,
                },
              ]}
            >
              <View style={styles.rowBetween}>
                <Text style={{ color: c.text, fontWeight: '900', fontSize: 16 }}>
                  TỔNG TIỀN:
                </Text>
                <Text
                  style={[
                    typeScale.tabularDisplay,
                    { color: accent, fontSize: 22 },
                  ]}
                >
                  {formatCurrency(m.remainingAmount)}
                </Text>
              </View>
              <Text
                style={[
                  typeScale.caption,
                  { color: c.textMuted, fontStyle: 'italic', marginTop: 4 },
                ]}
              >
                Bằng chữ: {moneyToVietnameseWords(m.remainingAmount)}
              </Text>
            </View>

            {/* 8. Bình quân 1 con heo */}
            <View
              style={[
                styles.rowBetween,
                {
                  backgroundColor: c.surfaceSubtle,
                  paddingHorizontal: space.md,
                  paddingVertical: 12,
                  borderRadius: radius.sm,
                  marginTop: space.md,
                },
              ]}
            >
              <Text style={{ color: c.text, fontWeight: '700', fontSize: 14 }}>
                Bình quân 1 con heo:
              </Text>
              <Text style={[typeScale.tabularMetric, { color: accent, fontWeight: '800', fontSize: 15 }]}>
                {formatWeight(m.averageWeight, true)} / con
              </Text>
            </View>
          </View>

          <Pressable
            accessibilityRole="button"
            onPress={() => handleShareReceipt(session)}
            style={[
              styles.fullWidthBtn,
              { backgroundColor: accent, marginTop: space.lg },
            ]}
          >
            <Text style={{ color: c.onAccent, fontWeight: '800', fontSize: 15 }}>
              SAO CHÉP / GỬI PHIẾU CÂN QUA ZALO
            </Text>
          </Pressable>

          <Pressable
            accessibilityRole="button"
            accessibilityLabel="Về trang chủ"
            onPress={() => setActiveScreen('home')}
            style={[
              styles.secondaryActionBtn,
              {
                borderColor: c.borderStrong,
                backgroundColor: c.surfaceSubtle,
                marginTop: space.md,
                height: 48,
                borderRadius: radius.md,
                borderWidth: 1,
                alignItems: 'center',
                justifyContent: 'center',
              },
            ]}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
              <IconHome color={c.text} size={16} />
              <Text style={{ color: c.text, fontWeight: '700', fontSize: 14 }}>
                Về trang chủ
              </Text>
            </View>
          </Pressable>
        </ScrollView>
      </View>
    );
  }

  // ============================================================================
  // TAB 2: DANH BẠ NÔNG DÂN & THƯƠNG LÁI
  // ============================================================================
  function renderContactsTab(c: ThemePalette): React.ReactNode {
    return (
      <FlatList
        data={contacts}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{
          padding: space.lg,
          gap: space.md,
          paddingBottom: 80 + Math.max(insets.bottom, 12) + 24,
        }}
        ListHeaderComponent={
          <View style={styles.rowBetween}>
            <Text style={[typeScale.sectionTitle, { color: c.text }]}>
              Danh Bạ Khách Hàng ({contacts.length})
            </Text>
            <Pressable
              accessibilityRole="button"
              onPress={() => setShowContactModal(true)}
              style={[styles.primaryActionBtn, { backgroundColor: c.accentPig }]}
            >
              <Text
                style={{ color: c.onAccent, fontWeight: '800', fontSize: 13 }}
              >
                + Thêm Khách Hàng
              </Text>
            </Pressable>
          </View>
        }
        renderItem={({ item }) => (
          <View
            style={[
              styles.sectionBox,
              { backgroundColor: c.surface, borderColor: c.border },
            ]}
          >
            <View style={styles.rowBetween}>
              <Text style={[typeScale.sectionTitle, { color: c.text }]}>
                {item.name}
              </Text>
              <View
                style={[styles.badge, { backgroundColor: c.accentPigSoft }]}
              >
                <Text
                  style={{
                    color: c.accentPig,
                    fontWeight: '700',
                    fontSize: 12,
                  }}
                >
                  {item.role}
                </Text>
              </View>
            </View>
            {item.phone ? (
              <Text style={[typeScale.body, { color: c.text }]}>
                SĐT: {item.phone}
              </Text>
            ) : null}
            {item.address ? (
              <Text style={[typeScale.caption, { color: c.textMuted }]}>
                Địa chỉ: {item.address}
              </Text>
            ) : null}
          </View>
        )}
      />
    );
  }

  // ============================================================================
  // TAB 3: LỊCH SỬ PHIẾU CÂN & THỐNG KÊ
  // ============================================================================
  function renderStatsTab(
    c: ThemePalette,
    list: WeighingSession[]
  ): React.ReactNode {
    const pigList = list.filter((s) => s.type === 'pig');

    const pigNetKg = pigList.reduce(
      (sum, s) => sum + computeSessionMetrics(s).netWeight,
      0
    );
    const pigMoney = pigList.reduce(
      (sum, s) => sum + computeSessionMetrics(s).totalAmount,
      0
    );
    const totalHeads = pigList.reduce(
      (sum, s) => sum + computeSessionMetrics(s).totalHeadCount,
      0
    );
    const averageWeight = totalHeads > 0 ? pigNetKg / totalHeads : 0;

    const historyList = pigList.filter((s) => {
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase().trim();
        const matchName = s.partnerName?.toLowerCase().includes(q);
        const matchTitle = s.title?.toLowerCase().includes(q);
        return matchName || matchTitle;
      }
      return true;
    });

    return (
      <ScrollView
        contentContainerStyle={{
          padding: space.lg,
          gap: space.md,
          paddingBottom: 80 + Math.max(insets.bottom, 12) + 24,
        }}
        showsVerticalScrollIndicator={false}
      >
        {/* THANH TÌM KIẾM NHANH DỜI TỪ TRANG CHỦ VÀO ĐÂY */}
        <View
          style={[
            styles.searchBarWrap,
            { backgroundColor: c.surface, borderColor: c.border, marginBottom: 0 },
          ]}
        >
          <IconSearch color={c.textMuted} size={18} />
          <TextInput
            value={searchQuery}
            onChangeText={setSearchQuery}
            placeholder="Tìm theo tên khách, trại, loại phiếu..."
            placeholderTextColor={c.textMuted}
            style={[styles.searchInput, { color: c.text }]}
            returnKeyType="search"
            clearButtonMode="while-editing"
          />
          {searchQuery.length > 0 && (
            <Pressable
              onPress={() => setSearchQuery('')}
              hitSlop={8}
              style={{ padding: 4 }}
            >
              <Text
                style={{
                  color: c.textMuted,
                  fontSize: 13,
                  fontWeight: '700',
                }}
              >
                ✕
              </Text>
            </Pressable>
          )}
        </View>

        {/* THẺ TỔNG HỢP THỐNG KÊ (PHONG CÁCH WISECRYPTO) */}
        <View
          style={[
            styles.sectionBox,
            {
              backgroundColor: c.surface,
              borderColor: '#00B074',
              borderWidth: 1.5,
              borderRadius: 18,
            },
          ]}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
              <IconChart color="#00B074" size={17} />
              <Text style={[typeScale.caption, { color: c.textMuted, fontWeight: '800' }]}>
                TỔNG GIÁ TRỊ GIAO DỊCH
              </Text>
            </View>
            <View style={[styles.badge, { backgroundColor: '#E8F8F2' }]}>
              <Text style={{ color: '#00B074', fontSize: 12, fontWeight: '800' }}>
                {pigList.length} phiếu
              </Text>
            </View>
          </View>

          <Text
            style={[
              typeScale.tabularDisplay,
              { color: '#00B074', fontSize: 26, fontWeight: '900', marginTop: 6 },
            ]}
          >
            {formatCurrency(pigMoney)}
          </Text>

          <View
            style={[
              styles.cryptoSpecsStrip,
              { backgroundColor: '#F8FAFC', borderColor: '#F1F5F9', marginTop: space.sm },
            ]}
          >
            <View style={styles.cryptoSpecItem}>
              <Text style={[styles.cryptoSpecLabel, { color: c.textMuted }]}>Tổng heo</Text>
              <Text style={[styles.cryptoSpecValue, { color: c.text }]}>{totalHeads} con</Text>
            </View>
            <View style={styles.cryptoSpecDivider} />
            <View style={styles.cryptoSpecItem}>
              <Text style={[styles.cryptoSpecLabel, { color: c.textMuted }]}>Tổng tịnh</Text>
              <Text style={[styles.cryptoSpecValue, { color: c.text }]}>
                {formatWeight(pigNetKg, true)}
              </Text>
            </View>
            <View style={styles.cryptoSpecDivider} />
            <View style={styles.cryptoSpecItem}>
              <Text style={[styles.cryptoSpecLabel, { color: c.textMuted }]}>TB / con</Text>
              <Text style={[styles.cryptoSpecValue, { color: c.text }]}>
                {averageWeight > 0 ? `${averageWeight.toFixed(1)} kg` : '0 kg'}
              </Text>
            </View>
          </View>
        </View>

        {/* TIÊU ĐỀ DANH SÁCH LỊCH SỬ PHIẾU CÂN */}
        <View style={styles.sectionHeaderRow}>
          <Text
            style={[
              typeScale.caption,
              { color: c.textMuted, fontWeight: '800', letterSpacing: 0.5 },
            ]}
          >
            TOÀN BỘ PHIẾU CÂN
          </Text>
          <View style={[styles.badge, { backgroundColor: '#E8F8F2' }]}>
            <Text
              style={{
                color: '#00B074',
                fontSize: 12,
                fontWeight: '800',
              }}
            >
              {historyList.length} phiếu
            </Text>
          </View>
        </View>

        {/* DANH SÁCH TẤT CẢ PHIẾU CÂN TRONG LỊCH SỬ */}
        {historyList.length > 0 ? (
          historyList.map((item) => renderSessionCard(item))
        ) : (
          <View
            style={[
              styles.emptyBox,
              { backgroundColor: c.surface, borderColor: c.border, marginTop: space.xs },
            ]}
          >
            <View style={styles.emptyIconCircle}>
              <IconPiggy color="#00B074" size={32} />
            </View>
            <Text
              style={[
                typeScale.sectionTitle,
                { color: c.text, marginTop: space.sm },
              ]}
            >
              {searchQuery
                ? 'Không tìm thấy phiếu cân phù hợp'
                : 'Chưa có phiếu cân nào'}
            </Text>
            <Text
              style={[
                typeScale.body,
                { color: c.textMuted, textAlign: 'center', marginTop: 4 },
              ]}
            >
              {searchQuery
                ? 'Thử đổi từ khoá tìm kiếm khách hàng hoặc trại.'
                : 'Các phiếu cân heo bạn tạo sẽ được lưu lại toàn bộ tại đây.'}
            </Text>
          </View>
        )}
      </ScrollView>
    );
  }

  // ============================================================================
  // MODALS
  // ============================================================================
  function renderNewSessionModal(c: ThemePalette): React.ReactNode {
    return (
      <AnimatedModal
        visible={showNewModal}
        alignTop
        paddingTop={Platform.OS === 'ios' ? 20 : 16}
        onRequestClose={() => setShowNewModal(false)}
      >
        {(closeModal) => (
          <View
            style={[
              styles.modalCard,
              { backgroundColor: c.surface, borderColor: c.borderStrong },
            ]}
          >
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: space.sm,
                marginBottom: space.xs,
              }}
            >
              <View
                style={{
                  width: 40,
                  height: 40,
                  borderRadius: 20,
                  backgroundColor: c.accentPigSoft,
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <IconPiggy color={c.accentPig} size={24} />
              </View>
              <Text style={[typeScale.title, { color: c.text, fontWeight: '900' }]}>
                Tạo Phiếu Cân Heo Mới
              </Text>
            </View>

            <Text style={[typeScale.caption, { color: c.textMuted, marginTop: space.sm }]}>
              Tên phiếu / Chuồng heo:
            </Text>
            <TextInput
              value={newTitle}
              onChangeText={setNewTitle}
              style={[
                styles.inputField,
                {
                  color: c.text,
                  borderColor: c.borderStrong,
                  backgroundColor: c.background,
                },
              ]}
            />

            <Text style={[typeScale.caption, { color: c.textMuted }]}>
              Tên người bán / Khách hàng:
            </Text>
            <TextInput
              value={newPartnerName}
              placeholder="Ví dụ: Anh Long, Trại Chú Ba..."
              placeholderTextColor={c.textMuted}
              onChangeText={setNewPartnerName}
              style={[
                styles.inputField,
                {
                  color: c.text,
                  borderColor: c.borderStrong,
                  backgroundColor: c.background,
                },
              ]}
            />

            <Text style={[typeScale.caption, { color: c.textMuted }]}>
              Đơn giá dự kiến (đ/kg):
            </Text>
            <TextInput
              value={newPrice}
              placeholder="Ví dụ: 65.000"
              placeholderTextColor={c.textMuted}
              keyboardType="numeric"
              onChangeText={(val) => {
                setNewPrice(formatThousandsInput(val));
              }}
              style={[
                styles.inputField,
                {
                  color: c.text,
                  borderColor: c.borderStrong,
                  backgroundColor: c.background,
                },
              ]}
            />

            <View
              style={{
                flexDirection: 'row',
                justifyContent: 'flex-end',
                gap: space.sm,
                marginTop: space.md,
              }}
            >
              <Pressable
                accessibilityRole="button"
                onPress={() => closeModal()}
                style={[
                  styles.secondaryActionBtn,
                  { borderColor: c.borderStrong },
                ]}
              >
                <Text style={{ color: c.text, fontWeight: '700' }}>Huỷ</Text>
              </Pressable>
              <Pressable
                accessibilityRole="button"
                onPress={() => {
                  triggerHaptic();
                  handleCreateSession();
                  closeModal();
                }}
                style={({ pressed }) => [
                  styles.primaryActionBtn,
                  {
                    backgroundColor: c.accentPig,
                    transform: [{ scale: pressed ? 0.98 : 1 }],
                  },
                ]}
              >
                <Text style={{ color: c.onAccent, fontWeight: '800' }}>
                  Bắt Đầu Cân Ngay
                </Text>
              </Pressable>
            </View>
          </View>
        )}
      </AnimatedModal>
    );
  }

  function renderEditEntryModal(c: ThemePalette): React.ReactNode {
    if (!editingEntry) return null;
    const accent = c.accentPig;
    const soft = c.accentPigSoft;
    const parsedWeight = parseFastWeight(editWeightText, true);

    const displayWeight =
      parsedWeight !== null
        ? !editWeightText.includes('.') && editWeightText.length >= 3
          ? parsedWeight.toFixed(1)
          : formatCellWeight(parsedWeight)
        : null;

    return (
      <AnimatedModal
        visible={!!editingEntry}
        alignTop
        paddingTop={Platform.OS === 'ios' ? 24 : 16}
        onRequestClose={() => setEditingEntry(null)}
      >
        {(closeModal) => (
          <View
            style={[
              styles.modalCard,
              {
                backgroundColor: c.surface,
                borderColor: c.borderStrong,
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 6 },
                shadowOpacity: 0.35,
                shadowRadius: 12,
                elevation: 10,
              },
            ]}
          >
            <View
              style={{
                flexDirection: 'row',
                justifyContent: 'space-between',
                alignItems: 'center',
              }}
            >
              <Text style={[typeScale.title, { color: c.text }]}>
                Sửa mã cân #{editingEntry.orderNumber}
              </Text>
              <View style={[styles.badge, { backgroundColor: soft }]}>
                <Text style={{ color: accent, fontWeight: '800', fontSize: 12 }}>
                  Gốc: {formatCellWeight(editingEntry.entry.weight)} kg
                </Text>
              </View>
            </View>

            <Text
              style={[
                typeScale.caption,
                { color: c.textMuted, marginTop: space.xs },
              ]}
            >
              Gõ 3580 = Tự hiểu 358.0 kg • Gõ 1233 = 123.3 kg
            </Text>

            <View style={{ position: 'relative', width: '100%' }}>
              <TextInput
                value={editWeightText}
                keyboardType="decimal-pad"
                autoFocus
                selectTextOnFocus
                placeholder="Ví dụ: 3580 hoặc 358.0"
                placeholderTextColor={c.textMuted}
                onChangeText={(val) => {
                  setEditWeightText(val.replace(/,/g, '.'));
                }}
                style={[
                  styles.inputField,
                  typeScale.tabularDisplay,
                  {
                    color: c.text,
                    borderColor: accent,
                    borderWidth: 2,
                    backgroundColor: c.background,
                    marginTop: space.sm,
                    fontSize: 26,
                    fontWeight: '800',
                    textAlign: 'center',
                    height: 52,
                  },
                ]}
              />
              {editWeightText.length > 0 && (
                <Pressable
                  accessibilityRole="button"
                  accessibilityLabel="Xoá nội dung ô nhập"
                  onPress={() => setEditWeightText('')}
                  hitSlop={10}
                  style={{
                    position: 'absolute',
                    right: 14,
                    top: space.sm + 14,
                    width: 24,
                    height: 24,
                    borderRadius: 12,
                    backgroundColor: c.borderStrong,
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <Text style={{ color: c.text, fontSize: 13, fontWeight: '800', lineHeight: 14 }}>
                    ✕
                  </Text>
                </Pressable>
              )}
            </View>

            {/* Xem trước tự động */}
            <View
              style={{
                marginTop: space.xs,
                paddingVertical: 6,
                paddingHorizontal: space.sm,
                backgroundColor: soft,
                borderRadius: radius.sm,
                alignItems: 'center',
              }}
            >
              <Text
                style={{
                  color: accent,
                  fontWeight: '800',
                  fontSize: 14,
                }}
              >
                {displayWeight !== null
                  ? `Sẽ lưu: ${displayWeight} kg`
                  : 'Gõ 3580 = Tự hiểu 358.0 kg'}
              </Text>
            </View>

            <View
              style={[
                styles.rowBetween,
                { marginTop: space.md },
              ]}
            >
              <Pressable
                accessibilityRole="button"
                onPress={() => {
                  const targetId = editingEntry.entry.id;
                  updateActiveSession((prev) => ({
                    ...prev,
                    entries: prev.entries.filter((e) => e.id !== targetId),
                  }));
                  showToast('Đã xoá mã cân');
                  closeModal();
                }}
                style={[
                  styles.secondaryActionBtn,
                  {
                    borderColor: c.danger,
                    backgroundColor: c.dangerSoft,
                    height: 44,
                    paddingHorizontal: space.sm,
                  },
                ]}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
                  <IconTrash color={c.danger} size={15} />
                  <Text style={{ color: c.danger, fontWeight: '800', fontSize: 13 }}>
                    Xoá
                  </Text>
                </View>
              </Pressable>

              <View style={{ flexDirection: 'row', gap: space.sm }}>
                <Pressable
                  accessibilityRole="button"
                  onPress={() => closeModal()}
                  style={[
                    styles.secondaryActionBtn,
                    { borderColor: c.borderStrong, height: 44, paddingHorizontal: space.md },
                  ]}
                >
                  <Text style={{ color: c.text, fontWeight: '700' }}>Đóng</Text>
                </Pressable>
                <Pressable
                  accessibilityRole="button"
                  onPress={() => {
                    const finalWeight =
                      parsedWeight ??
                      parseFloat(editWeightText.replace(/,/g, '.'));
                    if (finalWeight && finalWeight > 0) {
                      const targetId = editingEntry.entry.id;
                      updateActiveSession((prev) => ({
                        ...prev,
                        entries: prev.entries.map((e) =>
                          e.id === targetId ? { ...e, weight: finalWeight } : e
                        ),
                      }));
                      showToast(
                        `Đã sửa mã #${editingEntry.orderNumber}: ${displayWeight ?? formatCellWeight(finalWeight)} kg`
                      );
                    }
                    closeModal();
                  }}
                  style={[
                    styles.primaryActionBtn,
                    { backgroundColor: accent, height: 44, paddingHorizontal: space.md },
                  ]}
                >
                  <Text style={{ color: c.onAccent, fontWeight: '800' }}>
                    {displayWeight
                      ? `✓ Lưu ${displayWeight} kg`
                      : '✓ Lưu thay đổi'}
                  </Text>
                </Pressable>
              </View>
            </View>
          </View>
        )}
      </AnimatedModal>
    );
  }

  function renderAddContactModal(c: ThemePalette): React.ReactNode {
    return (
      <AnimatedModal
        visible={showContactModal}
        alignTop
        paddingTop={Platform.OS === 'ios' ? 20 : 16}
        onRequestClose={() => setShowContactModal(false)}
      >
        {(closeModal) => (
          <View
            style={[
              styles.modalCard,
              { backgroundColor: c.surface, borderColor: c.borderStrong },
            ]}
          >
            <Text style={[typeScale.title, { color: c.text }]}>
              Thêm Khách Hàng / Thương Lái
            </Text>
            <Text style={[typeScale.caption, { color: c.textMuted, marginTop: space.sm }]}>
              Họ tên:
            </Text>
            <TextInput
              value={contactName}
              onChangeText={setContactName}
              style={[
                styles.inputField,
                {
                  color: c.text,
                  borderColor: c.borderStrong,
                  backgroundColor: c.background,
                },
              ]}
            />
            <Text style={[typeScale.caption, { color: c.textMuted }]}>
              Số điện thoại:
            </Text>
            <TextInput
              value={contactPhone}
              keyboardType="phone-pad"
              onChangeText={setContactPhone}
              style={[
                styles.inputField,
                {
                  color: c.text,
                  borderColor: c.borderStrong,
                  backgroundColor: c.background,
                },
              ]}
            />
            <Text style={[typeScale.caption, { color: c.textMuted }]}>
              Địa chỉ / Khu vực:
            </Text>
            <TextInput
              value={contactAddress}
              onChangeText={setContactAddress}
              style={[
                styles.inputField,
                {
                  color: c.text,
                  borderColor: c.borderStrong,
                  backgroundColor: c.background,
                },
              ]}
            />
            <View
              style={{
                flexDirection: 'row',
                justifyContent: 'flex-end',
                gap: space.sm,
                marginTop: space.md,
              }}
            >
              <Pressable
                accessibilityRole="button"
                onPress={() => closeModal()}
                style={[
                  styles.secondaryActionBtn,
                  { borderColor: c.borderStrong },
                ]}
              >
                <Text style={{ color: c.text, fontWeight: '700' }}>Huỷ</Text>
              </Pressable>
              <Pressable
                accessibilityRole="button"
                onPress={async () => {
                  if (!contactName.trim()) return;
                  const next: PartnerContact[] = [
                    {
                      id: `c_${Date.now()}`,
                      name: contactName.trim(),
                      phone: contactPhone.trim(),
                      role: contactRole,
                      address: contactAddress.trim(),
                      note: '',
                    },
                    ...contacts,
                  ];
                  setContacts(next);
                  try {
                    await AsyncStorage.setItem(
                      STORAGE_KEY_CONTACTS,
                      JSON.stringify(next)
                    );
                  } catch {}
                  setContactName('');
                  setContactPhone('');
                  setContactAddress('');
                  closeModal();
                }}
                style={[
                  styles.primaryActionBtn,
                  { backgroundColor: c.accentPig },
                ]}
              >
                <Text style={{ color: c.onAccent, fontWeight: '800' }}>
                  Lưu Danh Bạ
                </Text>
              </Pressable>
            </View>
          </View>
        )}
      </AnimatedModal>
    );
  }

  function renderConfirmDeleteModal(c: ThemePalette): React.ReactNode {
    if (!deletingSession) return null;
    const entryCount = deletingSession.entries.length;
    return (
      <AnimatedModal
        visible={!!deletingSession}
        onRequestClose={() => setDeletingSession(null)}
      >
        {(closeModal) => (
          <View
            style={[
              styles.modalCard,
              {
                backgroundColor: c.surface,
                borderColor: c.borderStrong,
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 6 },
                shadowOpacity: 0.35,
                shadowRadius: 12,
                elevation: 10,
              },
            ]}
          >
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: space.sm,
              }}
            >
              <IconAlertTriangle color={c.danger} size={26} />
              <Text style={[typeScale.title, { color: c.danger, flex: 1 }]}>
                Xác nhận xoá phiếu?
              </Text>
            </View>

            <Text
              style={[
                typeScale.body,
                { color: c.text, marginTop: space.md, lineHeight: 22 },
              ]}
            >
              Bạn có chắc chắn muốn xoá phiếu{' '}
              <Text style={{ fontWeight: '800' }}>
                "{deletingSession.title}"
              </Text>
              ?
            </Text>

            <View
              style={{
                marginTop: space.sm,
                padding: space.sm,
                backgroundColor: c.surfaceSubtle,
                borderRadius: radius.sm,
                borderWidth: 1,
                borderColor: c.border,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 5 }}>
                <IconUser color={c.textMuted} size={14} />
                <Text style={[typeScale.caption, { color: c.textMuted }]}>
                  Khách hàng:{' '}
                  <Text style={{ color: c.text, fontWeight: '700' }}>
                    {deletingSession.partnerName}
                  </Text>
                </Text>
              </View>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 5, marginTop: 5 }}>
                <IconChart color={c.textMuted} size={13} />
                <Text style={[typeScale.caption, { color: c.textMuted }]}>
                  Dữ liệu:{' '}
                  <Text style={{ color: c.text, fontWeight: '700' }}>
                    {entryCount} lượt cân
                  </Text>
                </Text>
              </View>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 5, marginTop: 5 }}>
                <IconClock color={c.textMuted} size={13} />
                <Text style={[typeScale.caption, { color: c.textMuted }]}>
                  Ngày cân:{' '}
                  <Text style={{ color: c.text, fontWeight: '700' }}>
                    {deletingSession.createdAt}
                  </Text>
                </Text>
              </View>
            </View>

            <View
              style={{
                marginTop: space.sm,
                padding: space.sm,
                backgroundColor: c.dangerSoft,
                borderRadius: radius.sm,
                borderWidth: 1,
                borderColor: c.danger,
                flexDirection: 'row',
                alignItems: 'center',
                gap: 6,
              }}
            >
              <IconAlertTriangle color={c.danger} size={16} />
              <Text
                style={[
                  typeScale.caption,
                  { color: c.danger, fontWeight: '700', flex: 1 },
                ]}
              >
                Toàn bộ dữ liệu của phiếu cân này sẽ bị xóa vĩnh viễn
              </Text>
            </View>

            <View
              style={{
                flexDirection: 'row',
                justifyContent: 'flex-end',
                gap: space.sm,
                marginTop: space.lg,
              }}
            >
              <Pressable
                accessibilityRole="button"
                accessibilityLabel="Giữ lại phiếu cân"
                onPress={() => closeModal()}
                style={[
                  styles.secondaryActionBtn,
                  { borderColor: c.borderStrong, minWidth: 90 },
                ]}
              >
                <Text style={{ color: c.text, fontWeight: '700' }}>Giữ lại</Text>
              </Pressable>

              <Pressable
                accessibilityRole="button"
                accessibilityLabel="Xác nhận xoá vĩnh viễn phiếu cân"
                onPress={() => {
                  const targetId = deletingSession.id;
                  const targetTitle = deletingSession.title;
                  const next = sessions.filter((s) => s.id !== targetId);
                  persistSessions(next);
                  showToast(`Đã xoá phiếu "${targetTitle}"`);
                  closeModal();
                }}
                style={[
                  styles.primaryActionBtn,
                  { backgroundColor: c.danger, minWidth: 120 },
                ]}
              >
                <Text style={{ color: '#ffffff', fontWeight: '800' }}>
                  Xác Nhận Xoá
                </Text>
              </Pressable>
            </View>
          </View>
        )}
      </AnimatedModal>
    );
  }
}

const styles = StyleSheet.create({
  safeRoot: {
    flex: 1,
  },
  responsiveWrapper: {
    flex: 1,
    width: '100%',
    maxWidth: 640,
    alignSelf: 'center',
  },
  headerBar: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: space.lg,
    paddingVertical: space.sm + 2,
    borderBottomWidth: 1,
    minHeight: 64,
  },
  // Wisecrypto Header styles
  avatarWrap: {
    width: 44,
    height: 44,
    borderRadius: 22,
    borderWidth: 2,
    borderColor: '#00B074',
    padding: 1.5,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarImg: {
    width: '100%',
    height: '100%',
    borderRadius: 20,
  },
  greetingText: {
    fontSize: 12.5,
    fontWeight: '600',
    color: '#64748B',
  },
  headerAppTitle: {
    fontSize: 17,
    fontWeight: '800',
    letterSpacing: -0.2,
    marginTop: 1,
  },
  headerActionBtn: {
    width: 42,
    height: 42,
    borderRadius: 21,
    borderWidth: 1,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  notificationDot: {
    position: 'absolute',
    top: 9,
    right: 9,
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#00B074',
    borderWidth: 1.5,
    borderColor: '#FFFFFF',
  },

  // Wisecrypto Hero Balance Card styles
  heroCryptoCard: {
    width: '100%',
    backgroundColor: '#00B074',
    borderRadius: 22,
    padding: space.lg,
    overflow: 'hidden',
    position: 'relative',
    shadowColor: '#00B074',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.28,
    shadowRadius: 16,
    elevation: 8,
  },
  heroCardHeaderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  heroCardIconPill: {
    width: 26,
    height: 26,
    borderRadius: 13,
    backgroundColor: 'rgba(255, 255, 255, 0.22)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  heroCardSubLabel: {
    fontSize: 12,
    fontWeight: '700',
    color: 'rgba(255, 255, 255, 0.9)',
    letterSpacing: 0.6,
  },
  heroStatusPill: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: radius.pill,
  },
  heroStatusPillText: {
    color: '#FFFFFF',
    fontSize: 11,
    fontWeight: '700',
  },
  heroBalanceText: {
    fontSize: 28,
    lineHeight: 34,
    fontWeight: '900',
    color: '#FFFFFF',
    fontVariant: ['tabular-nums'],
    letterSpacing: -0.5,
  },
  heroMetricsStrip: {
    marginTop: space.md,
    backgroundColor: 'rgba(255, 255, 255, 0.14)',
    borderRadius: radius.md,
    paddingVertical: space.sm + 2,
    paddingHorizontal: space.md,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  heroMetricCol: {
    flex: 1,
    alignItems: 'center',
  },
  heroMetricDivider: {
    width: 1,
    height: 24,
    backgroundColor: 'rgba(255, 255, 255, 0.22)',
  },
  heroMetricLabel: {
    fontSize: 11,
    fontWeight: '500',
    color: 'rgba(255, 255, 255, 0.82)',
  },
  heroMetricVal: {
    fontSize: 13,
    fontWeight: '800',
    color: '#FFFFFF',
    marginTop: 2,
    fontVariant: ['tabular-nums'],
  },
  heroActionsRow: {
    flexDirection: 'row',
    gap: space.sm,
    marginTop: space.md + 2,
  },
  heroPrimaryBtn: {
    flex: 1.25,
    minHeight: MIN_TOUCH_TARGET,
    backgroundColor: '#FFFFFF',
    borderRadius: radius.pill,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.12,
    shadowRadius: 4,
    elevation: 3,
  },
  heroSecondaryBtn: {
    flex: 1,
    minHeight: MIN_TOUCH_TARGET,
    backgroundColor: 'rgba(255, 255, 255, 0.22)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.38)',
    borderRadius: radius.pill,
    justifyContent: 'center',
    alignItems: 'center',
  },
  heroBtnContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  heroPrimaryBtnText: {
    color: '#00B074',
    fontSize: 14,
    fontWeight: '800',
  },
  heroSecondaryBtnText: {
    color: '#FFFFFF',
    fontSize: 13,
    fontWeight: '700',
  },

  // Search & Filter chips
  searchBarWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: 46,
    borderRadius: 14,
    borderWidth: 1,
    paddingHorizontal: space.md,
    marginBottom: space.sm,
  },
  searchInput: {
    flex: 1,
    fontSize: 14,
    marginLeft: space.sm,
    paddingVertical: 8,
  },
  filterChipsRow: {
    flexDirection: 'row',
    gap: space.sm,
    paddingVertical: 4,
  },
  filterChip: {
    paddingHorizontal: space.md,
    paddingVertical: 7,
    borderRadius: radius.pill,
    borderWidth: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  filterChipText: {
    fontSize: 12.5,
    fontWeight: '700',
  },
  sectionHeaderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: space.lg,
  },

  // Wisecrypto Session Card styles
  wisecryptoSessionCard: {
    borderRadius: 18,
    borderWidth: 1,
    paddingVertical: space.lg,
    paddingHorizontal: space.lg,
    marginBottom: space.md,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04,
    shadowRadius: 6,
    elevation: Platform.OS === 'android' ? 0 : 2,
  },
  cryptoCardTopRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 2,
  },
  cryptoAssetIconCircle: {
    width: 46,
    height: 46,
    borderRadius: 23,
    backgroundColor: '#E8F8F2',
    borderWidth: 1,
    borderColor: '#D1FAE5',
    justifyContent: 'center',
    alignItems: 'center',
  },
  cryptoStatusPill: {
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: radius.pill,
  },
  cryptoAmountBadge: {
    borderWidth: 1.5,
    borderRadius: 10,
    paddingHorizontal: 9,
    paddingVertical: 4.5,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cryptoSpecsStrip: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderRadius: radius.sm + 2,
    borderWidth: 1,
    paddingVertical: 10,
    paddingHorizontal: space.md,
    marginTop: space.md,
  },
  cryptoSpecItem: {
    flex: 1,
    alignItems: 'center',
  },
  cryptoSpecDivider: {
    width: 1,
    height: 18,
    backgroundColor: '#E2E8F0',
  },
  cryptoSpecLabel: {
    fontSize: 11,
    fontWeight: '500',
  },
  cryptoSpecValue: {
    fontSize: 12.5,
    fontWeight: '800',
    marginTop: 2,
    fontVariant: ['tabular-nums'],
  },
  cryptoCardActionRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: space.md,
    paddingTop: 6,
  },
  cryptoTrashBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: MIN_TOUCH_TARGET,
    paddingHorizontal: space.xs,
  },
  cryptoSecondaryActionBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: MIN_TOUCH_TARGET,
    paddingHorizontal: space.md,
    borderRadius: radius.sm + 2,
    borderWidth: 1,
  },
  cryptoPrimaryActionBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: MIN_TOUCH_TARGET,
    paddingHorizontal: space.md,
    borderRadius: radius.sm + 2,
  },
  emptyIconCircle: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#E8F8F2',
    justifyContent: 'center',
    alignItems: 'center',
  },
  viewAllHistoryBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 14,
    paddingHorizontal: space.md,
    borderRadius: 14,
    borderWidth: 1,
    marginTop: space.xs,
  },
  iconHitButton: {
    width: 42,
    height: 42,
    borderRadius: 12,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  rowBetween: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  receiptMetricRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: 12,
  },
  launchCard: {
    flex: 1,
    padding: space.lg,
    borderRadius: radius.md,
    borderWidth: 1.5,
    minHeight: 108,
  },
  launchHeroButton: {
    width: '100%',
    borderRadius: 18,
    borderWidth: 1.5,
    paddingVertical: space.md + 2,
    paddingHorizontal: space.lg,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.28,
    shadowRadius: 8,
    elevation: 4,
  },
  heroButtonInner: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  heroIconBadge: {
    width: 50,
    height: 50,
    borderRadius: 25,
    borderWidth: 1.5,
    alignItems: 'center',
    justifyContent: 'center',
  },
  heroCtaPill: {
    paddingHorizontal: space.md,
    paddingVertical: space.sm,
    borderRadius: radius.pill,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.12,
    shadowRadius: 3,
    elevation: 2,
  },
  filterPill: {
    minHeight: MIN_TOUCH_TARGET,
    paddingHorizontal: space.md,
    borderRadius: radius.sm,
    borderWidth: 1,
    justifyContent: 'center',
  },
  emptyBox: {
    padding: space.xl,
    borderRadius: radius.md,
    borderWidth: 1,
    alignItems: 'center',
  },
  sessionCard: {
    padding: space.lg,
    borderRadius: radius.md,
    borderWidth: 1,
    marginBottom: space.md,
  },
  badge: {
    paddingHorizontal: space.sm,
    paddingVertical: 3,
    borderRadius: radius.sm,
  },
  divider: {
    height: 1,
    marginVertical: space.md,
  },
  smallHitBtn: {
    minHeight: MIN_TOUCH_TARGET,
    justifyContent: 'center',
    paddingHorizontal: space.sm,
  },
  secondaryActionBtn: {
    minHeight: MIN_TOUCH_TARGET,
    paddingHorizontal: space.md,
    borderRadius: radius.sm,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primaryActionBtn: {
    minHeight: MIN_TOUCH_TARGET,
    paddingHorizontal: space.md,
    borderRadius: radius.sm,
    alignItems: 'center',
    justifyContent: 'center',
  },
  floatingNavContainer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    alignItems: 'center',
    paddingHorizontal: 0,
    zIndex: 99,
  },
  floatingNavPill: {
    width: '100%',
    maxWidth: 640,
    height: Platform.OS === 'ios' ? 74 : 64,
    borderTopLeftRadius: 18,
    borderTopRightRadius: 18,
    borderBottomLeftRadius: 0,
    borderBottomRightRadius: 0,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -3 },
    shadowOpacity: 0.08,
    shadowRadius: 10,
    elevation: 10,
  },
  floatingNavRow: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    paddingHorizontal: space.sm,
    paddingBottom: Platform.OS === 'ios' ? 12 : 2,
  },
  floatingNavTab: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 4,
    minHeight: MIN_TOUCH_TARGET,
  },
  subTabBtn: {
    flex: 1,
    minHeight: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  summaryStrip: {
    flexDirection: 'row',
    paddingHorizontal: space.md,
    paddingVertical: space.sm,
    borderBottomWidth: 1,
  },
  columnBox: {
    width: 132,
    height: '100%',
    borderRadius: radius.md,
    overflow: 'hidden',
  },
  columnHeader: {
    paddingVertical: 5,
    alignItems: 'center',
  },
  cellRow: {
    paddingHorizontal: space.sm,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderBottomWidth: 1,
  },
  columnFooter: {
    paddingVertical: 6,
    paddingHorizontal: space.sm,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderTopWidth: 1,
  },
  numpadContainer: {
    paddingHorizontal: space.md,
    paddingVertical: space.sm,
    borderTopWidth: 1,
  },
  toggleChip: {
    minHeight: 32,
    paddingHorizontal: space.sm,
    borderRadius: radius.sm,
    borderWidth: 1,
    justifyContent: 'center',
  },
  inputPreviewBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: space.md,
    paddingVertical: 6,
    borderRadius: radius.sm,
    borderWidth: 1.5,
    marginBottom: 6,
  },
  numKey: {
    flex: 1,
    height: 44,
    borderRadius: radius.sm,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sideActionKey: {
    width: '100%',
    borderRadius: radius.sm,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 4,
  },
  sectionBox: {
    padding: space.lg,
    borderRadius: radius.md,
    borderWidth: 1,
    gap: space.xs,
  },
  modePill: {
    flex: 1,
    minHeight: 42,
    borderRadius: radius.sm,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 4,
  },
  inputField: {
    minHeight: MIN_TOUCH_TARGET,
    borderWidth: 1,
    borderRadius: radius.sm,
    paddingHorizontal: space.md,
    fontSize: 16,
    fontWeight: '700',
    marginVertical: 4,
  },
  presetChip: {
    minHeight: 38,
    paddingHorizontal: space.md,
    borderRadius: radius.sm,
    borderWidth: 1,
    justifyContent: 'center',
  },
  highlightTotalBox: {
    padding: space.md,
    borderRadius: radius.sm,
  },
  fullWidthBtn: {
    minHeight: MIN_TOUCH_TARGET,
    borderRadius: radius.sm,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: space.md,
  },
  receiptColRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: space.md,
    paddingVertical: 12,
    borderRadius: radius.sm,
    borderWidth: 1,
    marginBottom: space.sm,
  },
  toastBanner: {
    position: 'absolute',
    bottom: 72,
    alignSelf: 'center',
    paddingHorizontal: space.lg,
    paddingVertical: space.sm,
    borderRadius: radius.md,
  },
  modalBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.35)',
    alignItems: 'center',
    justifyContent: 'center',
    padding: space.lg,
  },
  modalCard: {
    width: '100%',
    maxWidth: 420,
    padding: space.lg,
    borderRadius: radius.md,
    borderWidth: 1,
    gap: 6,
  },
});
