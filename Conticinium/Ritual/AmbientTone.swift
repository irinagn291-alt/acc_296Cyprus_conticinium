import AVFoundation
import Foundation

/// Procedural tone for the Ambient leaf. No audio file and no capture session.
final class AmbientTone: @unchecked Sendable {
    private let engine = AVAudioEngine()
    private let phase = TonePhase()
    private var attached = false
    private let lock = NSLock()
    private var running = false

    func start() {
        lock.lock()
        let already = running
        lock.unlock()
        if already { return }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            return
        }

        if !attached {
            let format = engine.mainMixerNode.outputFormat(forBus: 0)
            let rate = Float(format.sampleRate > 0 ? format.sampleRate : 44_100)
            phase.step = (2 * Float.pi * 96) / rate
            let source = AVAudioSourceNode(format: format) { [phase] _, _, frameCount, audioBufferList -> OSStatus in
                let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
                let frames = Int(frameCount)
                for frame in 0..<frames {
                    let sample = sin(phase.phase) * 0.035
                    phase.phase += phase.step
                    if phase.phase > 2 * Float.pi {
                        phase.phase -= 2 * Float.pi
                    }
                    for buffer in buffers {
                        guard let data = buffer.mData else { continue }
                        let samples = data.assumingMemoryBound(to: Float.self)
                        samples[frame] = sample
                    }
                }
                return noErr
            }
            engine.attach(source)
            engine.connect(source, to: engine.mainMixerNode, format: format)
            attached = true
        }

        do {
            try engine.start()
            lock.lock()
            running = true
            lock.unlock()
        } catch {
            lock.lock()
            running = false
            lock.unlock()
        }
    }

    func stop() {
        lock.lock()
        running = false
        lock.unlock()
        engine.pause()
    }
}

private final class TonePhase: @unchecked Sendable {
    var phase: Float = 0
    var step: Float = 0
}
