import UIKit
import GPUImage
import AVFoundation

let blendImageName = "WID-small.jpg"

class FilterDisplayViewController: UIViewController, UISplitViewControllerDelegate {

    @IBOutlet var filterSlider: UISlider?
    @IBOutlet var filterView: RenderView?
    
    var videoCamera:Camera?
    var blendImage:PictureInput?

    required init(coder aDecoder: NSCoder)
    {
        do {
            videoCamera = try Camera(sessionPreset:AVCaptureSession.Preset.iFrame960x540, location:.frontFacing)
            videoCamera!.runBenchmark = true
        } catch {
            videoCamera = nil
            print("Couldn't initialize camera with error: \(error)")
        }

        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        do {
            videoCamera = try Camera(sessionPreset:AVCaptureSession.Preset.iFrame960x540, location:.backFacing)
            videoCamera!.runBenchmark = true
        } catch {
            videoCamera = nil
            print("Couldn't initialize camera with error: \(error)")
        }
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    
    var filterOperation: FilterOperationInterface?
    
    func configureView() {
        guard let videoCamera = videoCamera else {
            let errorAlertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: "Couldn't initialize camera", preferredStyle: .alert)
            errorAlertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
            self.present(errorAlertController, animated: true, completion: nil)
            return
        }
        if let currentFilterConfiguration = self.filterOperation {
            self.title = currentFilterConfiguration.titleName
            
            // Configure the filter chain, ending with the view
            if let view = self.filterView {
                switch currentFilterConfiguration.filterOperationType {
                case .singleInput:
                    videoCamera.addTarget(currentFilterConfiguration.filter)
                    currentFilterConfiguration.filter.addTarget(view)
                case .blend:
                    videoCamera.addTarget(currentFilterConfiguration.filter)
                    self.blendImage = PictureInput(imageName:blendImageName)
                    self.blendImage?.addTarget(currentFilterConfiguration.filter)
                    self.blendImage?.processImage()
                    currentFilterConfiguration.filter.addTarget(view)
                case let .custom(filterSetupFunction:setupFunction):
                    currentFilterConfiguration.configureCustomFilter(setupFunction(videoCamera, currentFilterConfiguration.filter, view))
                }
                
                videoCamera.startCapture()
            }

            // Hide or display the slider, based on whether the filter needs it
            if let slider = self.filterSlider {
                switch currentFilterConfiguration.sliderConfiguration {
                case .disabled:
                    slider.isHidden = true
//                case let .Enabled(minimumValue, initialValue, maximumValue, filterSliderCallback):
                case let .enabled(minimumValue, maximumValue, initialValue):
                    slider.minimumValue = minimumValue
                    slider.maximumValue = maximumValue
                    slider.value = initialValue
                    slider.isHidden = false
                    self.updateSliderValue()
                }
            }
            
            
            filterView?.fillMode = .preserveAspectRatioAndFill
            
            
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2) + .milliseconds(0)) { [unowned self] in
//                self.filterView?.fillMode = .preserveAspectRatio
//            }
        }
    }
    
    @IBAction func updateSliderValue() {
        if let currentFilterConfiguration = self.filterOperation {
            switch (currentFilterConfiguration.sliderConfiguration) {
                case .enabled(_, _, _): currentFilterConfiguration.updateBasedOnSliderValue(Float(self.filterSlider!.value))
                case .disabled: break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
            videoCamera.removeAllTargets()
            blendImage?.removeAllTargets()
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func touchCameraSwitch(_ sender: UIButton) {
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
            videoCamera.removeAllTargets()
            blendImage?.removeAllTargets()
        }
        
        if sender.isSelected{
            videoCamera = try? Camera(sessionPreset:AVCaptureSession.Preset.iFrame960x540, location:.frontFacing)
        }
        else{
            videoCamera = try? Camera(sessionPreset:AVCaptureSession.Preset.iFrame960x540, location:.backFacing)
        }
        self.configureView()
        
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func touchShutter(_ sender: UIButton) {
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_hhmmss"
        let dateString = dateFormatter.string(from:date as Date)
        
        let savePath = "\(NSHomeDirectory())/Documents/\(dateString).png"
        let saveUrl = URL(fileURLWithPath: savePath)
        videoCamera?.saveNextFrameToURL(saveUrl, format: PictureFileFormat.png)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1) + .milliseconds(0)) { [unowned self] in
            let image = UIImage(contentsOfFile: savePath)!
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            Toast.showToast(title: "Photo Saved!")
//            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
        }
    }

}


extension UIButton {
    @IBInspectable var cornerRadiusHalf:Bool{
        set{
            self.clipsToBounds = true
            self.layer.cornerRadius = self.frame.size.width/2
        }
        get{
            return false
        }
    }
}
