/*
 * traffic_light.c
 
 * Traffic Light Controller Simulation (two-road intersection)
 *
 * Simulates a standard 4-way traffic junction with two perpendicular
 * roads (Road A: North-South, Road B: East-West) using a finite state
 * machine (FSM), so that only one road is ever green at a time and the
 * other is red - just like a real signal controller.
 *
 * States cycle as:
 *   Road A GREEN,  Road B RED
 *   Road A YELLOW, Road B RED
 *   Road A RED,    Road B GREEN
 *   Road A RED,    Road B YELLOW
 *   (repeat)
 *
 * Build:
 *   gcc -O2 -Wall -o traffic_light traffic_light.c
 *
 * Run (real-time, default durations):
 *   ./traffic_light
 *
 * Run in fast/demo mode (no waiting, prints instantly, good for testing
 * or a quick demo without sitting through real seconds):
 *   ./traffic_light --fast
 *
 * Optional: limit number of full cycles (default runs forever until Ctrl+C)
 *   ./traffic_light --cycles 3
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef _WIN32
    #include <windows.h>
    #define SLEEP_SECONDS(s) Sleep((s) * 1000)
#else
    #include <unistd.h>
    #define SLEEP_SECONDS(s) sleep(s)
#endif

/* --- Configuration: how long each light stays on (in seconds) --- */
#define GREEN_DURATION  5
#define YELLOW_DURATION 2
#define RED_DURATION    (GREEN_DURATION + YELLOW_DURATION) /* matches other road's green+yellow */

typedef enum { LIGHT_RED, LIGHT_YELLOW, LIGHT_GREEN } LightState;

typedef struct {
    const char *name;
    LightState state;
} Road;

static const char *state_name(LightState s) {
    switch (s) {
        case LIGHT_RED:    return "RED   ";
        case LIGHT_YELLOW: return "YELLOW";
        case LIGHT_GREEN:  return "GREEN ";
        default:           return "?     ";
    }
}

static void print_status(const Road *a, const Road *b, int seconds_left) {
    printf("[%-10s] %s : %s   |   [%-10s] %s : %s   (next change in %ds)\n",
           a->name, "Light", state_name(a->state),
           b->name, "Light", state_name(b->state),
           seconds_left);
    fflush(stdout); /* ensure output appears immediately in real-time mode */
}

/*
 * The intersection cycles through 4 phases. Each phase has a duration and
 * a (Road A state, Road B state) pair. This table-driven FSM design keeps
 * the transition logic simple and easy to extend (e.g. add a 3rd road).
 */
typedef struct {
    int duration;
    LightState state_a;
    LightState state_b;
} Phase;

static const Phase phases[] = {
    { GREEN_DURATION,  LIGHT_GREEN,  LIGHT_RED    },
    { YELLOW_DURATION, LIGHT_YELLOW, LIGHT_RED    },
    { GREEN_DURATION,  LIGHT_RED,    LIGHT_GREEN  },
    { YELLOW_DURATION, LIGHT_RED,    LIGHT_YELLOW },
};
#define NUM_PHASES (int)(sizeof(phases) / sizeof(phases[0]))

int main(int argc, char *argv[]) {
    int fast_mode = 0;
    int max_cycles = -1; /* -1 = run forever */

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--fast") == 0) {
            fast_mode = 1;
        } else if (strcmp(argv[i], "--cycles") == 0 && i + 1 < argc) {
            max_cycles = atoi(argv[++i]);
        }
    }

    Road road_a = { "Road A (N-S)", LIGHT_RED };
    Road road_b = { "Road B (E-W)", LIGHT_RED };

    printf("=== Traffic Light Controller Simulation ===\n");
    printf("Road A = North-South | Road B = East-West\n");
    printf("Green=%ds, Yellow=%ds per direction\n", GREEN_DURATION, YELLOW_DURATION);
    if (fast_mode) printf("(fast mode: no real-time delay)\n");
    printf("--------------------------------------------------------------------\n");

    int cycle = 0;
    while (max_cycles < 0 || cycle < max_cycles) {
        for (int p = 0; p < NUM_PHASES; p++) {
            road_a.state = phases[p].state_a;
            road_b.state = phases[p].state_b;
            int remaining = phases[p].duration;

            /* countdown, printing status each simulated second */
            for (int t = remaining; t > 0; t--) {
                print_status(&road_a, &road_b, t);
                if (!fast_mode) SLEEP_SECONDS(1);
            }
        }
        cycle++;
    }

    printf("--------------------------------------------------------------------\n");
    printf("Simulation complete. Cycles run: %d\n", cycle);
    return 0;
}
