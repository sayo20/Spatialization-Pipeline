import numpy as np
import random
import itertools
import math
import pandas as pd
import pyroomacoustics as pra
from scipy.io.wavfile import write

class RoomImpulseResponseGenerator:
    """
    We simulate the RIRs using Pyroomacoustic package
    """
    def __init__(self, sample_rate=48000, wall_distance=1.4, mic_dist=0.05, rooms=500):
        self.sample_rate = sample_rate
        self.wall_distance = wall_distance
        self.mic_dist = mic_dist
        self.rooms = rooms
        self.microphone_cartesian_loc = np.array([
            [1, 0, 0],
            [-1, 0, 0],
            [0, -0.7071, 0.7071],
            [0, 0.7071, 0.7071],
            [0, -0.7071, -0.7071],
            [0, 0.7071, -0.7071],
            [0, 0, 0]
        ]) * 0.096 / 2  # Define mic positions

    def save_rir(self, rir, savepath=""):
        room_rir = np.vstack([np.pad(sample, (0, max([len(r) for r in rir]) - len(sample))) for sample in rir])
        room_rir = room_rir.T[:self.sample_rate]
        write(savepath, self.sample_rate, room_rir.astype(np.float32))

    def save_room_rir(self, room, savepath):
        flattened_rir = [sample for sublist in room.rir for sample in sublist]
        max_length = max(len(rir) for rir in flattened_rir)
        room_rir = [np.pad(rir, (0, max_length - len(rir))) for rir in flattened_rir]
        rir_stacked = np.vstack(room_rir)[:,:self.sample_rate]
        write(savepath, self.sample_rate, rir_stacked.T.astype(np.float32))

    def get_room_dimensions(self):
        x = random.randint(4, 10)  # Width
        y = random.randint(4, 10)  # Length
        z = random.uniform(2.5, 5)  # Height
        room_dim = [x, y, z]
        rt60 = self.get_rt60(room_dim)
        return room_dim, rt60

    def get_rt60(self, room_dim):
        min_room_size = 16
        max_room_size = 100
        current_rs = room_dim[0] * room_dim[1]
        current_rs_norm = (current_rs - min_room_size) / (max_room_size - min_room_size)
        RTs = np.arange(0.2, 0.7, 0.01) #reverberation time
        rt_idx = int(current_rs_norm * len(RTs)) + np.random.choice(np.arange(-10, 11), 1)[0]
        rt_idx = np.clip(rt_idx, 0, len(RTs) - 1)
        return RTs[rt_idx]

    def get_all_coordinates(self, x_y_bounds):
        x_coords = np.arange(x_y_bounds[0][0], x_y_bounds[0][1], 1.0)
        y_coords = np.arange(x_y_bounds[1][0], x_y_bounds[1][1], 1.0)
        return list(itertools.product(x_coords, y_coords))

    def source_position(self, mid_coord, angle, radius=1.4):
        offset_angle = angle + 90
        angle_rad = math.radians(offset_angle)
        source_x = mid_coord[0] + (radius * np.cos(angle_rad))
        source_y = mid_coord[1] + (radius * np.sin(angle_rad))
        return source_x, source_y, 1.25, offset_angle

    def get_mic_source_positions(self, room_dim, room_num, t60):
        w_d = self.wall_distance * 2
        mic_space = [x - w_d for x in room_dim[:2]]  # Subtract wall distance twice
        x_bound_high = mic_space[0] + self.wall_distance
        x_bound_low = self.wall_distance
        y_bound_high = mic_space[1] + self.wall_distance
        y_bound_low = self.wall_distance

        all_coordinates = self.get_all_coordinates([(x_bound_low, x_bound_high), (y_bound_low, y_bound_high)])
        use_sample = all_coordinates if len(all_coordinates) < 5 else random.sample(all_coordinates, 5) #selected 5 positions within the room

        df = pd.DataFrame(columns=["Room_number", "Room_letter", "Room_dimension", "T60", "Room_node", "Source_angle", "Source_Pos", "Offset_angle"])
        room_letters = ['a', 'b', 'c', 'd', 'e']
        source_angles = np.arange(0, 360, 15) #change this to match the resolution of the HRTF
        
        indx = 0
        for n, node in enumerate(use_sample):
            node_ = [node[0], node[1], 1.25]
            for angle in source_angles:
                source_x, source_y, z, offse_ang = self.source_position(node_, angle)
                df.loc[indx] = [room_num, room_letters[n], room_dim, t60, node_, angle, [source_x, source_y, z], offse_ang]
                indx += 1

        return df

    def convert_cartesian_to_room(self, node_p, microphone_cartesian_loc):
        return node_p + microphone_cartesian_loc

    def generate_rir(self, params, base_path, save_path_brir):
        for i in range(len(params)):
            room_num = params.loc[i, "Room_number"]
            room_dim = params.loc[i, "Room_dimension"]
            room_node = params.loc[i, "Room_node"]
            rt60 = params.loc[i, "T60"]
            source_pos = params.loc[i, "Source_Pos"]
            source_angle = params.loc[i, "Source_angle"]
            room_letter = params.loc[i, "Room_letter"]

            save_path = f"{base_path}Room{room_num}{room_letter}_{source_angle}.flac"
            brir_back = f"{save_path_brir}Room{room_num}{room_letter}_{source_angle}.wav"
            
            params.loc[i, "Path"] = save_path
            params.loc[i, "brirPath"] = brir_back

            e_absorption, max_order = pra.inverse_sabine(rt60, room_dim)
            room = pra.ShoeBox(room_dim, fs=self.sample_rate, materials=pra.Material(e_absorption), max_order=max_order, air_absorption=True)
            room.add_source(source_pos)
            frl_roomMic_loc = self.convert_cartesian_to_room(room_node, self.microphone_cartesian_loc)
            room.add_microphone_array(frl_roomMic_loc.T)
            room.compute_rir()
            self.save_room_rir(room, save_path)

        return params

    def create_room_simulations(self, base_path, save_path_brir):
        df = pd.DataFrame(columns=["Room_number", "Room_letter", "Room_dimension", "T60", "Room_node", "Source_angle", "Source_Pos", "Offset_angle", "Path", "brirPath"])
        for room_num in range(1, self.rooms + 1):
            room_dim, rt60 = self.get_room_dimensions()
            param = self.get_mic_source_positions(room_dim, room_num, rt60)
            param = self.generate_rir(param, base_path, save_path_brir)
            df = pd.concat([df, param], ignore_index=True)
        df.to_csv(f"{base_path}/RIR_Meta_rt60PerRms.csv", index=False)

# Example usage:
# generator = RoomImpulseResponseGenerator(rooms=10)
# generator.create_room_simulations(base_path="path_to_save_rir", save_path_brir="path_to_save_brir")
