// Copyright © 2022 Brad Howes. All rights reserved.

#import <CoreAudioKit/CoreAudioKit.h>

#import "C++/Kernel.hpp"
#import "Kernel.h"

@implementation KernelBridge {
  Kernel* kernel_;
}

- (instancetype)init:(NSString*)appExtensionName {
  if (self = [super init]) {
    self->kernel_ = new Kernel(std::string(appExtensionName.UTF8String));
  }
  return self;
}

- (void)setRenderingFormat:(AVAudioFormat*)inputFormat maxFramesToRender:(AUAudioFrameCount)maxFramesToRender {
  kernel_->setRenderingFormat(inputFormat, maxFramesToRender);
}

- (void)renderingStopped { kernel_->renderingStopped(); }

- (AUInternalRenderBlock)internalRenderBlock {
  auto& kernel = *kernel_;
  NSInteger bus = 0;
  return ^AUAudioUnitStatus(AudioUnitRenderActionFlags* flags, const AudioTimeStamp* timestamp,
                            AUAudioFrameCount frameCount, NSInteger, AudioBufferList* output,
                            const AURenderEvent* realtimeEventListHead, AURenderPullInputBlock pullInputBlock) {
    return kernel.processAndRender(timestamp, frameCount, bus, output, realtimeEventListHead, pullInputBlock);
  };
}

- (void)setBypass:(BOOL)state { kernel_->setBypass(state); }

- (void)set:(AUParameter *)parameter value:(AUValue)value { kernel_->setParameterValue(parameter.address, value); }

- (AUValue)get:(AUParameter *)parameter { return kernel_->getParameterValue(parameter.address); }

@end
