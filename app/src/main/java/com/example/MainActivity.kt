package com.example

import android.os.Bundle
import android.os.Vibrator
import android.os.VibrationEffect
import android.os.Build
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private lateinit var irTransmitter: IrTransmitter
    private var vibrator: Vibrator? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        irTransmitter = IrTransmitter(this)
        vibrator = getSystemService(VIBRATOR_SERVICE) as? Vibrator

        setContent {
            WaltonRemoteScreen(
                hasIrEmitter = irTransmitter.hasIrEmitter(),
                onSendCommand = { cmd, label ->
                    triggerVibrate()
                    val success = irTransmitter.sendCommand(cmd)
                    if (!success && !irTransmitter.hasIrEmitter()) {
                        Toast.makeText(
                            this,
                            "IR Blaster not detected on this device.",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                    success
                }
            )
        }
    }

    private fun triggerVibrate() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(VibrationEffect.createOneShot(30, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(30)
            }
        } catch (_: Exception) {}
    }
}

// Color Palette strictly matching design
val DarkBackground = Color(0xFF14161C)
val DarkSurface = Color(0xFF1D2028)
val DarkSurfaceHighlight = Color(0xFF2B303C)
val LightBackground = Color(0xFFF0F3F7)
val LightSurface = Color(0xFFF7F9FC)
val LightShadow = Color(0xFFD4DCDE)
val TextPrimaryDark = Color(0xFFF0F3F8)
val TextSecondaryDark = Color(0xFF8A93A6)
val TextPrimaryLight = Color(0xFF1E2638)
val TextSecondaryLight = Color(0xFF6E798F)
val ConnectedGreen = Color(0xFF00E676)
val IrBlue = Color(0xFF00B0FF)
val PowerRed = Color(0xFFFF3333)

@Composable
fun WaltonRemoteScreen(
    hasIrEmitter: Boolean,
    onSendCommand: (Int, String) -> Boolean
) {
    val pagerState = rememberPagerState(pageCount = { 2 })
    val coroutineScope = rememberCoroutineScope()
    var lastSentInfo by remember { mutableStateOf<String?>(null) }
    var showSettingsDialog by remember { mutableStateOf(false) }
    var showVideoPlayerDialog by remember { mutableStateOf(false) }

    fun send(cmd: Int, label: String) {
        val inv = 0xFF - cmd
        val hex = "00BC${cmd.toString(16).padStart(2, '0').uppercase()}${inv.toString(16).padStart(2, '0').uppercase()}"
        lastSentInfo = "$label ($hex)"
        onSendCommand(cmd, label)
    }

    Box(modifier = Modifier.fillMaxSize()) {
        HorizontalPager(
            state = pagerState,
            modifier = Modifier.fillMaxSize()
        ) { page ->
            if (page == 0) {
                MainRemoteScreen(
                    hasIr = hasIrEmitter,
                    onSend = ::send,
                    onOpenSettings = { showSettingsDialog = true },
                    onSwipeNext = {
                        coroutineScope.launch {
                            pagerState.animateScrollToPage(1)
                        }
                    }
                )
            } else {
                MoreControlsScreen(
                    onSend = ::send,
                    onOpenSettings = { showSettingsDialog = true },
                    onOpenVideoPlayer = { showVideoPlayerDialog = true },
                    onSwipeBack = {
                        coroutineScope.launch {
                            pagerState.animateScrollToPage(0)
                        }
                    }
                )
            }
        }

        // Floating transmission badge
        AnimatedVisibility(
            visible = lastSentInfo != null,
            enter = fadeIn(),
            exit = fadeOut(),
            modifier = Modifier
                .align(Alignment.TopCenter)
                .statusBarsPadding()
                .padding(top = 10.dp)
        ) {
            Surface(
                color = Color.Black.copy(alpha = 0.85f),
                shape = RoundedCornerShape(20.dp),
                border = androidx.compose.foundation.BorderStroke(1.dp, ConnectedGreen.copy(alpha = 0.6f)),
                shadowElevation = 8.dp
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .background(ConnectedGreen, CircleShape)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "IR TX: ${lastSentInfo ?: ""}",
                        color = Color.White,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }

    // Settings Dialog (Custom slot 6 & customization)
    if (showSettingsDialog) {
        AlertDialog(
            onDismissRequest = { showSettingsDialog = false },
            title = { Text("Settings & Customization", fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    Text(
                        "• Hardware Emitter: ${if (hasIrEmitter) "Detected" else "Standby / Simulated"}\n" +
                        "• Carrier Frequency: 38,000 Hz\n" +
                        "• NEC Bit Order: True LSB\n" +
                        "• Frame: 00 BC CMD INV\n" +
                        "• Custom Slots: 6 total slots (Video Player, Settings + 4 user slots)\n" +
                        "• YouTube: Sends IR command 0x60 (TV action)\n" +
                        "• TV Settings: Sends IR command 0x90 (TV action)\n" +
                        "• Offline & Ad-Free",
                        fontSize = 13.sp,
                        lineHeight = 20.sp
                    )
                }
            },
            confirmButton = {
                TextButton(onClick = { showSettingsDialog = false }) {
                    Text("Close")
                }
            }
        )
    }

    // Video Player Dialog (Custom slot 5)
    if (showVideoPlayerDialog) {
        AlertDialog(
            onDismissRequest = { showVideoPlayerDialog = false },
            title = { Text("In-App Video Player (Slot 5)", fontWeight = FontWeight.Bold) },
            text = {
                Text(
                    "Custom Slot 5 is assigned as an in-app Video Player. This operates inside the application on your phone, separate from TV IR commands.",
                    fontSize = 13.sp
                )
            },
            confirmButton = {
                TextButton(onClick = { showVideoPlayerDialog = false }) {
                    Text("OK")
                }
            }
        )
    }
}

// PAGE 1: MAIN CONTROLS (DARK THEME)
@Composable
fun MainRemoteScreen(
    hasIr: Boolean,
    onSend: (Int, String) -> Unit,
    onOpenSettings: () -> Unit,
    onSwipeNext: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = 24.dp)
    ) {
        // Top Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = "Walton TV",
                    color = TextPrimaryDark,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold
                )
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(top = 2.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .background(if (hasIr) ConnectedGreen else Color.Yellow, CircleShape)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = if (hasIr) "Connected" else "IR Ready",
                        color = if (hasIr) ConnectedGreen else TextSecondaryDark,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium
                    )
                }
            }

            Row(verticalAlignment = Alignment.CenterVertically) {
                Surface(
                    color = DarkSurface,
                    shape = RoundedCornerShape(18.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)),
                    modifier = Modifier.padding(end = 10.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.WifiTethering, contentDescription = "IR", tint = IrBlue, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("IR", color = TextPrimaryDark, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    }
                }

                Surface(
                    color = DarkSurface,
                    shape = CircleShape,
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)),
                    modifier = Modifier
                        .size(42.dp)
                        .clickable { onOpenSettings() }
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(Icons.Outlined.Settings, contentDescription = "Settings", tint = TextSecondaryDark, modifier = Modifier.size(20.dp))
                    }
                }
            }
        }

        // Power & Source Row
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Box(
                    modifier = Modifier
                        .size(64.dp)
                        .clip(CircleShape)
                        .background(
                            Brush.radialGradient(
                                colors = listOf(Color(0xFFFF5252), PowerRed, Color(0xFFB71C1C))
                            )
                        )
                        .clickable { onSend(0x00, "Power") },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Default.PowerSettingsNew, contentDescription = "Power", tint = Color.White, modifier = Modifier.size(32.dp))
                }
                Spacer(modifier = Modifier.height(4.dp))
                Text("Power", color = TextSecondaryDark, fontSize = 11.sp)
            }

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Surface(
                    color = DarkSurface,
                    shape = CircleShape,
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
                    modifier = Modifier
                        .size(64.dp)
                        .clickable { onSend(0x43, "Source") }
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(Icons.Default.Input, contentDescription = "Source", tint = TextPrimaryDark, modifier = Modifier.size(26.dp))
                    }
                }
                Spacer(modifier = Modifier.height(4.dp))
                Text("Source", color = TextSecondaryDark, fontSize = 11.sp)
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // Flanked Section: VOL | DPAD | CH
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Volume Capsule
            Surface(
                color = DarkSurface,
                shape = RoundedCornerShape(27.dp),
                border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
                modifier = Modifier
                    .width(54.dp)
                    .height(175.dp)
            ) {
                Column(
                    modifier = Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.SpaceBetween
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .weight(1f)
                            .clickable { onSend(0x48, "VOL +") },
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Default.Add, contentDescription = "VOL +", tint = TextPrimaryDark)
                    }
                    Text("VOL", color = TextSecondaryDark, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .weight(1f)
                            .clickable { onSend(0x49, "VOL -") },
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Default.Remove, contentDescription = "VOL -", tint = TextPrimaryDark)
                    }
                }
            }

            // D-Pad Controller
            Box(
                modifier = Modifier
                    .size(190.dp)
                    .clip(CircleShape)
                    .background(DarkSurface)
                    .border(1.5.dp, Color.White.copy(alpha = 0.14f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                // UP
                Box(
                    modifier = Modifier
                        .align(Alignment.TopCenter)
                        .padding(top = 4.dp)
                        .size(80.dp, 50.dp)
                        .clickable { onSend(0x13, "Up") },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Default.KeyboardArrowUp, contentDescription = "Up", tint = TextPrimaryDark, modifier = Modifier.size(32.dp))
                }
                // DOWN
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .padding(bottom = 4.dp)
                        .size(80.dp, 50.dp)
                        .clickable { onSend(0x14, "Down") },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Default.KeyboardArrowDown, contentDescription = "Down", tint = TextPrimaryDark, modifier = Modifier.size(32.dp))
                }
                // LEFT
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterStart)
                        .padding(start = 4.dp)
                        .size(50.dp, 80.dp)
                        .clickable { onSend(0x11, "Left") },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Default.KeyboardArrowLeft, contentDescription = "Left", tint = TextPrimaryDark, modifier = Modifier.size(32.dp))
                }
                // RIGHT
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterEnd)
                        .padding(end = 4.dp)
                        .size(50.dp, 80.dp)
                        .clickable { onSend(0x12, "Right") },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Default.KeyboardArrowRight, contentDescription = "Right", tint = TextPrimaryDark, modifier = Modifier.size(32.dp))
                }
                // OK
                Surface(
                    color = Color(0xFF222631),
                    shape = CircleShape,
                    border = androidx.compose.foundation.BorderStroke(1.5.dp, Color.White.copy(alpha = 0.2f)),
                    modifier = Modifier
                        .size(70.dp)
                        .clickable { onSend(0x10, "OK") }
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Text("OK", color = TextPrimaryDark, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    }
                }
            }

            // Channel Capsule
            Surface(
                color = DarkSurface,
                shape = RoundedCornerShape(27.dp),
                border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
                modifier = Modifier
                    .width(54.dp)
                    .height(175.dp)
            ) {
                Column(
                    modifier = Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.SpaceBetween
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .weight(1f)
                            .clickable { onSend(0x4A, "CH +") },
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Default.KeyboardArrowUp, contentDescription = "CH +", tint = TextPrimaryDark)
                    }
                    Text("CH", color = TextSecondaryDark, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .weight(1f)
                            .clickable { onSend(0x4B, "CH -") },
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Default.KeyboardArrowDown, contentDescription = "CH -", tint = TextPrimaryDark)
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Mute | Home | Back
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            RemoteCircleButton(Icons.Default.VolumeOff, "Mute") { onSend(0x01, "Mute") }
            RemoteCircleButton(Icons.Default.Home, "Home") { onSend(0x45, "Home") }
            RemoteCircleButton(Icons.Default.Undo, "Back / Recall") { onSend(0x44, "Recall") }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // CUSTOM 1 & CUSTOM 2
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Surface(
                color = Color.White,
                shape = RoundedCornerShape(25.dp),
                modifier = Modifier
                    .weight(1f)
                    .height(48.dp)
                    .clickable { onSend(0x15, "CUSTOM 1") }
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Icon(Icons.Default.GridView, contentDescription = null, tint = Color(0xFF2979FF), modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(6.dp))
                    Text("CUSTOM 1", color = Color.Black, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                }
            }

            Surface(
                color = DarkSurface,
                shape = RoundedCornerShape(25.dp),
                border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
                modifier = Modifier
                    .weight(1f)
                    .height(48.dp)
                    .clickable { onSend(0x41, "CUSTOM 2") }
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.Center
                ) {
                    Icon(Icons.Default.Star, contentDescription = null, tint = Color(0xFFAB47BC), modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(6.dp))
                    Text("CUSTOM 2", color = TextPrimaryDark, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Media controls
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            RemoteMediaButton(Icons.Default.FastRewind, "Rewind", 64.dp) { onSend(0x54, "Rewind") }
            RemoteMediaButton(Icons.Default.PlayArrow, "Play/Pause", 110.dp) { onSend(0x52, "Play/Pause") }
            RemoteMediaButton(Icons.Default.FastForward, "Forward", 64.dp) { onSend(0x55, "Forward") }
        }

        Spacer(modifier = Modifier.weight(1f))

        // Page Indicator
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { onSwipeNext() }
                .padding(bottom = 12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row {
                Box(modifier = Modifier.size(7.dp).background(Color.White, CircleShape))
                Spacer(modifier = Modifier.width(6.dp))
                Box(modifier = Modifier.size(7.dp).background(Color.White.copy(alpha = 0.3f), CircleShape))
            }
            Spacer(modifier = Modifier.height(6.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Swipe for more controls", color = TextSecondaryDark, fontSize = 12.sp)
                Spacer(modifier = Modifier.width(4.dp))
                Icon(Icons.Default.ArrowForward, contentDescription = null, tint = TextSecondaryDark, modifier = Modifier.size(14.dp))
            }
        }
    }
}

// PAGE 2: MORE CONTROLS (LIGHT THEME)
@Composable
fun MoreControlsScreen(
    onSend: (Int, String) -> Unit,
    onOpenSettings: () -> Unit,
    onOpenVideoPlayer: () -> Unit,
    onSwipeBack: () -> Unit
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .background(LightBackground)
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = 20.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        item {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(
                    color = LightSurface,
                    shape = CircleShape,
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.Black.copy(alpha = 0.08f)),
                    modifier = Modifier
                        .size(42.dp)
                        .clickable { onSwipeBack() }
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = TextPrimaryLight, modifier = Modifier.size(18.dp))
                    }
                }
                Column(
                    modifier = Modifier.weight(1f),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text("More Controls", color = TextPrimaryLight, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                    Text("Additional TV Functions", color = TextSecondaryLight, fontSize = 12.sp)
                }
                Spacer(modifier = Modifier.size(42.dp))
            }
        }

        // Top Row: Picture | Sound | Subtitle | Sleep
        item {
            Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                LightGridButton(Icons.Outlined.Image, "Picture", Modifier.weight(1f)) { onSend(0x02, "Picture") }
                LightGridButton(Icons.Outlined.VolumeUp, "Sound", Modifier.weight(1f)) { onSend(0x03, "Sound") }
                LightGridButton(Icons.Outlined.Subtitles, "Subtitle", Modifier.weight(1f)) { onSend(0x75, "Subtitle") }
                LightGridButton(Icons.Outlined.Bedtime, "Sleep", Modifier.weight(1f)) { onSend(0x5B, "Sleep") }
            }
        }

        // Row 2: Display | Menu | Exit
        item {
            Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                LightGridButton(Icons.Outlined.Info, "Display", Modifier.weight(1f)) { onSend(0x16, "Display") }
                LightGridButton(Icons.Default.Menu, "Menu", Modifier.weight(1f)) { onSend(0x40, "Menu") }
                LightGridButton(Icons.Default.ExitToApp, "Exit", Modifier.weight(1f)) { onSend(0x47, "Exit") }
            }
        }

        // Numpad (1-9, Display, 0, Back/Recall)
        item {
            Spacer(modifier = Modifier.height(6.dp))
            NumpadRow(listOf("1" to 0x05, "2" to 0x06, "3" to 0x07), onSend)
            Spacer(modifier = Modifier.height(6.dp))
            NumpadRow(listOf("4" to 0x08, "5" to 0x09, "6" to 0x0A), onSend)
            Spacer(modifier = Modifier.height(6.dp))
            NumpadRow(listOf("7" to 0x0B, "8" to 0x0C, "9" to 0x0D), onSend)
            Spacer(modifier = Modifier.height(6.dp))
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                LightNumpadTextButton("Display", Modifier.weight(1f)) { onSend(0x16, "Display") }
                LightNumpadDigitButton("0", Modifier.weight(1f)) { onSend(0x42, "0") }
                LightNumpadTextButton("Back / Recall", Modifier.weight(1f)) { onSend(0x44, "Recall") }
            }
        }

        // Input Sources: File Manager | HDMI | AV | VGA
        item {
            Spacer(modifier = Modifier.height(12.dp))
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                LightGridButton(Icons.Default.Usb, "File Manager", Modifier.weight(1f)) { onSend(0x74, "File Manager") }
                LightGridButton(Icons.Default.Tv, "HDMI", Modifier.weight(1f)) { onSend(0x7B, "HDMI") }
                LightGridButton(Icons.Default.RadioButtonChecked, "AV", Modifier.weight(1f)) { onSend(0x7C, "AV") }
                LightGridButton(Icons.Default.Computer, "VGA", Modifier.weight(1f)) { onSend(0x7F, "VGA") }
            }
        }

        // YouTube (Sends IR 0x60!) | Video Player (Custom Slot 5)
        item {
            Spacer(modifier = Modifier.height(12.dp))
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                // YouTube sends 0x60
                Surface(
                    color = LightSurface,
                    shape = RoundedCornerShape(16.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.Black.copy(alpha = 0.08f)),
                    modifier = Modifier.weight(1f).height(50.dp).clickable { onSend(0x60, "YouTube") }
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Center) {
                        Surface(color = Color.Red, shape = RoundedCornerShape(5.dp), modifier = Modifier.size(20.dp, 16.dp)) {
                            Box(contentAlignment = Alignment.Center) {
                                Icon(Icons.Default.PlayArrow, contentDescription = null, tint = Color.White, modifier = Modifier.size(14.dp))
                            }
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("YouTube", color = TextPrimaryLight, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    }
                }

                // Video Player opens local screen
                Surface(
                    color = LightSurface,
                    shape = RoundedCornerShape(16.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.Black.copy(alpha = 0.08f)),
                    modifier = Modifier.weight(1f).height(50.dp).clickable { onOpenVideoPlayer() }
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Center) {
                        Icon(Icons.Default.PlayArrow, contentDescription = null, tint = Color(0xFF1E88E5), modifier = Modifier.size(24.dp))
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("Video Player", color = TextPrimaryLight, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }
                }
            }
        }

        // CUSTOM 5 (Slot 3) | CUSTOM 6 (Slot 4)
        item {
            Spacer(modifier = Modifier.height(10.dp))
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                Surface(
                    color = LightSurface,
                    shape = RoundedCornerShape(16.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.Black.copy(alpha = 0.08f)),
                    modifier = Modifier.weight(1f).height(50.dp).clickable { onSend(0x57, "CUSTOM 5") }
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Center) {
                        Icon(Icons.Default.Apps, contentDescription = null, tint = Color(0xFF4CAF50), modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("CUSTOM 5", color = TextPrimaryLight, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }
                }

                Surface(
                    color = LightSurface,
                    shape = RoundedCornerShape(16.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.Black.copy(alpha = 0.08f)),
                    modifier = Modifier.weight(1f).height(50.dp).clickable { onSend(0x5A, "CUSTOM 6") }
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Center) {
                        Icon(Icons.Default.Star, contentDescription = null, tint = Color(0xFFFF9800), modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("CUSTOM 6", color = TextPrimaryLight, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }
                }
            }
        }

        // TV Settings (Sends IR 0x90!) | Settings (Slot 6 app action)
        item {
            Spacer(modifier = Modifier.height(10.dp))
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                // TV Settings sends 0x90
                Surface(
                    color = LightSurface,
                    shape = RoundedCornerShape(16.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.Black.copy(alpha = 0.08f)),
                    modifier = Modifier.weight(1f).height(50.dp).clickable { onSend(0x90, "TV Settings") }
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Center) {
                        Icon(Icons.Outlined.Settings, contentDescription = null, tint = Color(0xFF37474F), modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("TV Settings", color = TextPrimaryLight, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }
                }

                // App Settings opens settings
                Surface(
                    color = LightSurface,
                    shape = RoundedCornerShape(16.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, Color.Black.copy(alpha = 0.08f)),
                    modifier = Modifier.weight(1f).height(50.dp).clickable { onOpenSettings() }
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Center) {
                        Icon(Icons.Default.Settings, contentDescription = null, tint = Color(0xFF37474F), modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Settings", color = TextPrimaryLight, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    }
                }
            }
        }

        // Swipe back footer
        item {
            Spacer(modifier = Modifier.height(16.dp))
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onSwipeBack() }
                    .padding(bottom = 16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Row {
                    Box(modifier = Modifier.size(7.dp).background(TextSecondaryLight.copy(alpha = 0.3f), CircleShape))
                    Spacer(modifier = Modifier.width(6.dp))
                    Box(modifier = Modifier.size(7.dp).background(TextPrimaryLight, CircleShape))
                }
                Spacer(modifier = Modifier.height(6.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("Swipe back for main controls", color = TextSecondaryLight, fontSize = 12.sp)
                    Spacer(modifier = Modifier.width(4.dp))
                    Icon(Icons.Default.ArrowBack, contentDescription = null, tint = TextSecondaryLight, modifier = Modifier.size(14.dp))
                }
            }
        }
    }
}

// Helpers
@Composable
fun RemoteCircleButton(icon: ImageVector, label: String, onClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Surface(
            color = DarkSurface,
            shape = CircleShape,
            border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
            modifier = Modifier.size(56.dp).clickable { onClick() }
        ) {
            Box(contentAlignment = Alignment.Center) {
                Icon(icon, contentDescription = label, tint = TextPrimaryDark, modifier = Modifier.size(24.dp))
            }
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(label, color = TextSecondaryDark, fontSize = 11.sp)
    }
}

@Composable
fun RemoteMediaButton(icon: ImageVector, label: String, width: androidx.compose.ui.unit.Dp, onClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Surface(
            color = DarkSurface,
            shape = RoundedCornerShape(26.dp),
            border = androidx.compose.foundation.BorderStroke(1.dp, Color.White.copy(alpha = 0.12f)),
            modifier = Modifier.width(width).height(52.dp).clickable { onClick() }
        ) {
            Box(contentAlignment = Alignment.Center) {
                Icon(icon, contentDescription = label, tint = TextPrimaryDark, modifier = Modifier.size(24.dp))
            }
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(label, color = TextSecondaryDark, fontSize = 11.sp)
    }
}

@Composable
fun LightGridButton(icon: ImageVector, label: String, modifier: Modifier, onClick: () -> Unit) {
    Surface(
        color = LightSurface,
        shape = RoundedCornerShape(14.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, Color.Black.copy(alpha = 0.08f)),
        modifier = modifier.height(64.dp).clickable { onClick() }
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(icon, contentDescription = label, tint = TextPrimaryLight, modifier = Modifier.size(22.dp))
            Spacer(modifier = Modifier.height(4.dp))
            Text(label, color = TextPrimaryLight, fontSize = 11.sp, fontWeight = FontWeight.SemiBold, maxLines = 1)
        }
    }
}

@Composable
fun NumpadRow(items: List<Pair<String, Int>>, onSend: (Int, String) -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        for (item in items) {
            LightNumpadDigitButton(item.first, Modifier.weight(1f)) {
                onSend(item.second, item.first)
            }
        }
    }
}

@Composable
fun LightNumpadDigitButton(digit: String, modifier: Modifier, onClick: () -> Unit) {
    Surface(
        color = LightSurface,
        shape = RoundedCornerShape(12.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, Color.Black.copy(alpha = 0.08f)),
        modifier = modifier.height(46.dp).clickable { onClick() }
    ) {
        Box(contentAlignment = Alignment.Center) {
            Text(digit, color = TextPrimaryLight, fontSize = 18.sp, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
fun LightNumpadTextButton(label: String, modifier: Modifier, onClick: () -> Unit) {
    Surface(
        color = LightSurface,
        shape = RoundedCornerShape(12.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, Color.Black.copy(alpha = 0.08f)),
        modifier = modifier.height(46.dp).clickable { onClick() }
    ) {
        Box(contentAlignment = Alignment.Center) {
            Text(label, color = TextPrimaryLight, fontSize = 11.sp, fontWeight = FontWeight.SemiBold)
        }
    }
}
