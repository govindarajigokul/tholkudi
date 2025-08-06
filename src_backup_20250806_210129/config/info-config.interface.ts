import { Config } from './config.interface';

export interface InfoConfig extends Config {
  enableEndUserAgreement: boolean;
  enablePrivacyStatement: boolean;
  enableAboutStatement: boolean;
  enableCreditsStatement: boolean;
  enableHelpStatement: boolean;
  enableCOARNotifySupport: boolean;
}
