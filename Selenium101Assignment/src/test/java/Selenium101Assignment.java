

import org.openqa.selenium.*;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.safari.SafariOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.Assert;
import org.testng.annotations.*;

import java.net.MalformedURLException;
import java.net.URL;
import java.time.Duration;
import java.util.HashMap;

public class Selenium101Assignment {

    private RemoteWebDriver driver;
    private WebDriverWait wait;

    // IMPORTANT: Replace ACCESS_KEY below with your actual LambdaTest / TestMu AI key from dashboard API settings
    private static final String USERNAME = "danstermishle@gmail.com";
    private static final String ACCESS_KEY = "LT_19tZngcvNMy2FNO6EKfvHb0gz1z925RKPeD3jG5KDzlNtfV";

    @BeforeMethod
    @Parameters({"browser", "browserVersion", "platform"})
    public void setUp(String browser, String browserVersion, String platform) throws MalformedURLException {

        HashMap<String, Object> ltOptions = new HashMap<>();
        ltOptions.put("username", USERNAME);
        ltOptions.put("accessKey", ACCESS_KEY);
        ltOptions.put("project", "Selenium 101 Assignment");
        ltOptions.put("selenium_version", "4.0.0");
        ltOptions.put("w3c", true);

        // Capabilities required by the assignment specs
        ltOptions.put("network", true);
        ltOptions.put("video", true);
        ltOptions.put("visual", true);
        ltOptions.put("console", "true");

        if (browser.equalsIgnoreCase("Chrome")) {
            ChromeOptions chromeOptions = new ChromeOptions();
            chromeOptions.setPlatformName(platform);
            chromeOptions.setBrowserVersion(browserVersion);
            chromeOptions.setCapability("LT:Options", ltOptions);
            driver = new RemoteWebDriver(new URL("https://hub.lambdatest.com/wd/hub"), chromeOptions);

        } else if (browser.equalsIgnoreCase("Safari")) {
            SafariOptions safariOptions = new SafariOptions();
            safariOptions.setPlatformName(platform);
            safariOptions.setBrowserVersion(browserVersion);
            safariOptions.setCapability("LT:Options", ltOptions);
            driver = new RemoteWebDriver(new URL("https://hub.lambdatest.com/wd/hub"), safariOptions);
        }

        wait = new WebDriverWait(driver, Duration.ofSeconds(10));
    }

    // SCENARIO 1: Simple Form Demo
    @Test
    public void testScenario1() {
        driver.get("https://www.testmuai.com/selenium-playground/");

        WebElement simpleFormLink = wait.until(
                ExpectedConditions.elementToBeClickable(By.linkText("Simple Form Demo"))
        );
        ((JavascriptExecutor) driver).executeScript(
                "arguments[0].click();",
                simpleFormLink
        );
        wait.until(ExpectedConditions.urlContains("simple-form-demo"));

        Assert.assertTrue(driver.getCurrentUrl().contains("simple-form-demo"));

        String messageText = "Welcome to TestMu AI";

        WebElement inputTextBox = driver.findElement(By.xpath("//input[@id='user-message']"));
        inputTextBox.sendKeys(messageText);

        WebElement showInputBtn = driver.findElement(By.id("showInput"));
        showInputBtn.click();

        WebElement displayedMessage = driver.findElement(By.id("message"));
        Assert.assertEquals(displayedMessage.getText(), messageText,
                "Displayed message does not match input string.");
    }

    // SCENARIO 2: Drag & Drop Sliders
    @Test
    public void testScenario2() {
        driver.get("https://www.testmuai.com/selenium-playground/");

        WebElement sliderLink = wait.until(
                ExpectedConditions.elementToBeClickable(
                        By.linkText("Drag & Drop Sliders"))
        );
        ((JavascriptExecutor) driver).executeScript(
                "arguments[0].click();",
                sliderLink
        );

        wait.until(ExpectedConditions.urlContains("drag-drop-range-sliders-demo"));

        WebElement slider = wait.until(
                ExpectedConditions.elementToBeClickable(
                        By.xpath("(//input[@type='range'])[3]")
                )
        );

        WebElement rangeOutput = wait.until(
                ExpectedConditions.visibilityOfElementLocated(
                        By.id("rangeSuccess"))
        );

        int currentVal = Integer.parseInt(slider.getAttribute("value"));

        while (currentVal < 95) {
            slider.sendKeys(Keys.ARROW_RIGHT);
            currentVal = Integer.parseInt(slider.getAttribute("value"));
        }

        Assert.assertEquals(rangeOutput.getText(), "95");
    }

    // SCENARIO 3: Input Form Submit
    @Test
    public void testScenario3() {
        driver.get("https://www.testmuai.com/selenium-playground/");

        WebElement inputFormLink = wait.until(
                ExpectedConditions.elementToBeClickable(
                        By.linkText("Input Form Submit"))
        );

        ((JavascriptExecutor) driver).executeScript(
                "arguments[0].click();",
                inputFormLink
        );

        wait.until(ExpectedConditions.urlContains("input-form-demo"));

        WebElement submitBtn = wait.until(
                ExpectedConditions.elementToBeClickable(
                        By.xpath("//button[text()='Submit']")
                )
        );

        // First submit without filling fields
        ((JavascriptExecutor) driver).executeScript(
                "arguments[0].scrollIntoView(true);",
                submitBtn
        );

        ((JavascriptExecutor) driver).executeScript(
                "arguments[0].click();",
                submitBtn
        );

        WebElement nameField = driver.findElement(By.name("name"));

        Boolean isRequired = (Boolean) ((JavascriptExecutor) driver)
                .executeScript(
                        "return arguments[0].matches(':invalid');",
                        nameField
                );

        Assert.assertTrue(
                isRequired,
                "Name field should be invalid when submitted empty."
        );

        // Fill form
        nameField.sendKeys("Mihle");

        driver.findElement(By.id("inputEmail4"))
                .sendKeys("danstermishle@gmail.com");

        driver.findElement(By.id("inputPassword4"))
                .sendKeys("Kuyidan@1014");

        driver.findElement(By.id("company"))
                .sendKeys("TestMu AI");

        driver.findElement(By.id("websitename"))
                .sendKeys("https://example.com");

        Select country = new Select(
                driver.findElement(By.name("country"))
        );
        country.selectByVisibleText("United States");

        driver.findElement(By.id("inputCity"))
                .sendKeys("Cape Town");

        driver.findElement(By.id("inputAddress1"))
                .sendKeys("F709 Sondela Street");

        driver.findElement(By.id("inputAddress2"))
                .sendKeys("F709 Sondela Street");

        driver.findElement(By.id("inputState"))
                .sendKeys("Western Cape");

        driver.findElement(By.id("inputZip"))
                .sendKeys("7784");

        // Final submit
        ((JavascriptExecutor) driver).executeScript(
                "arguments[0].scrollIntoView(true);",
                submitBtn
        );

        ((JavascriptExecutor) driver).executeScript(
                "arguments[0].click();",
                submitBtn
        );

        WebElement successMsg = wait.until(
                ExpectedConditions.visibilityOfElementLocated(
                        By.xpath("//*[contains(text(),'Thanks for contacting us')]")
                )
        );

        Assert.assertTrue(
                successMsg.getText()
                        .contains("Thanks for contacting us"),
                "Success message mismatch!"
        );
    }
}