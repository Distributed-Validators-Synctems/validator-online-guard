# Distributed Validators Synctems: Validator Online guard automation

## Disclaimer

Use this script at your OWN risk!

## Description

The purpose of this script is to guard validator node against appearance of another validator node with same key and to prevent double signing. This may happen if main validator node goes offline because of problems on provider side, and you need to start another one but if first validator appears online again it will lead to double signing if seconds validator will not be shut down. 

Supported operation systems: Debian, Ubuntu


## Usage

In order to install all required tools simply issue following command:

`$ bash <(curl -s https://raw.githubusercontent.com/Distributed-Validators-Synctems/validator-online-guard/master/setup.sh)`

## Notifications

In order to receive notifications about operation result please copy included `notification.sh.sample` into directory with `config.sh` and name it `notification.sh`. After that please provide correct values for `TELEGRAM_CHAT_ID` and `TELEGRAM_BOT_TOKEN` variables inside `notification.sh`.