declare module '@expo/vector-icons/Ionicons' {
  import * as React from 'react';
  import type { TextStyle } from 'react-native';

  export interface IoniconsProps {
    name: string;
    size?: number;
    color?: string;
    style?: TextStyle | TextStyle[];
  }

  export default class Ionicons extends React.Component<IoniconsProps> {}
}
