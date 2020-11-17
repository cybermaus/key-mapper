#!/usr/bin/python3
# -*- coding: utf-8 -*-
# key-mapper - GUI for device specific keyboard mappings
# Copyright (C) 2020 sezanzeb <proxima@hip70890b.de>
#
# This file is part of key-mapper.
#
# key-mapper is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# key-mapper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with key-mapper.  If not, see <https://www.gnu.org/licenses/>.


"""Contains and manages mappings."""


from keymapper.logger import logger


class Mapping:
    """Contains and manages mappings.

    The keycode is always unique, multiple keycodes may map to the same
    character.
    """
    def __init__(self):
        self._mapping = {}
        self.changed = False

    def __iter__(self):
        """Iterate over tuples of unique keycodes and their character."""
        return iter(sorted(self._mapping.items()))

    def __len__(self):
        return len(self._mapping)

    def change(self, previous_keycode, new_keycode, character):
        """Replace the mapping of a keycode with a different one.

        Return True on success.

        Parameters
        ----------
        previous_keycode : int or None
            If None, will not remove any previous mapping. If you recently
            used 10 for new_keycode and want to overwrite that with 11,
            provide 5 here.
        new_keycode : int
            The source keycode, what the mouse would report without any
            modification.
        character : string or string[]
            A single character known to xkb, Examples: KP_1, Shift_L, a, B.
            Can also be an array, which is used for reading the xkbmap output
            completely.
        """
        try:
            new_keycode = int(new_keycode)
            if previous_keycode is not None:
                previous_keycode = int(previous_keycode)
        except ValueError:
            logger.error('Can only use numbers as keycodes')
            return False

        if new_keycode and character:
            self._mapping[new_keycode] = character
            if new_keycode != previous_keycode:
                # clear previous mapping of that code, because the line
                # representing that one will now represent a different one.
                self.clear(previous_keycode)
            self.changed = True
            return True

        return False

    def clear(self, keycode):
        """Remove a keycode from the mapping.

        Parameters
        ----------
        keycode : int
        """
        if self._mapping.get(keycode) is not None:
            del self._mapping[keycode]
            self.changed = True

    def empty(self):
        """Remove all mappings."""
        self._mapping = {}
        self.changed = True

    def get_keycode(self, character):
        """Get the keycode for that character."""
        # TODO prepare this with .lower() instead to make it faster
        character = character.lower()
        for keycode, mapping in self._mapping.items():
            if isinstance(mapping, list):
                if character in [c.lower() for c in mapping]:
                    return keycode
            elif mapping.lower() == character:
                return int(keycode)

        return None

    def get_character(self, keycode):
        """Read the character that is mapped to this keycode.

        Parameters
        ----------
        keycode : int
        """
        return self._mapping.get(keycode)

    def has(self, keycode):
        """Check if this keycode is going to be a line in the symbols file.
        TODO no symbols files anymore ^
        """
        return self._mapping.get(keycode) is not None


# one mapping object for the whole application that holds all
# customizations
custom_mapping = Mapping()

# one mapping that represents the xmodmap output
system_mapping = Mapping()
