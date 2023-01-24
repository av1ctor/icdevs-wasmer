/* eslint-disable prettier/prettier */
import React, { useCallback, useEffect, useState } from 'react';
import {
  Alert,
  Button,
  BackHandler,
  SafeAreaView,
  ScrollView,
  StatusBar,
  Text,
  TextInput,
  useColorScheme,
  View,
} from 'react-native';

import {Colors} from 'react-native/Libraries/NewAppScreen';

import * as Lib from './a-motoko-lib';
import { MoHelper } from './motoko-helper';

const helper = new MoHelper(Lib);

function App(): JSX.Element {
  const [started, setStarted] = useState(false);
  const [name, setName] = useState('');

  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  const handleTextChanged = useCallback((text: string) => {
    setName(text);
  }, []);

  const handleGreet = useCallback(() => {
    const res = Lib.greet(0, helper.stringToText(name));
    Alert.alert('greet() result', helper.textToString(res));
  }, [name]);

  const handleShowMessage = useCallback(() => {
    const res = Lib.getMessage(0);
    Alert.alert('getMessage() result', helper.textToString(res));
  }, []);

  const handleExit = useCallback(() => {
    BackHandler.exitApp();
  }, []);

  useEffect(() => {
    if (!started) {
      setStarted(true);
      Lib._start();
    }
  }, [started]);

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <Text style={{fontSize: 24, textAlign: 'center', padding: 8}}>Motoko - React Native</Text>
        <View
          style={{
            backgroundColor: isDarkMode ? Colors.black : Colors.white, padding: 8
          }}>
          <Text>Your name:</Text>
          <TextInput
            value={name}
            onChangeText={handleTextChanged}
          />
          <Button
            title="Greet()"
            onPress={handleGreet}
          />
          <Text>&nbsp;</Text>
          <Button
            title="GetMessage()"
            onPress={handleShowMessage}
          />
          <Text>&nbsp;</Text>
          <Button
            title="Exit"
            color="#f00"
            onPress={handleExit}
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

export default App;
