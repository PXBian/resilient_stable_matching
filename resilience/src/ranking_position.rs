use std::ops::Index;
use std::slice;

#[repr(C)]
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RankingListMatrix {
    pub ptr: *const u32,
    pub n: usize, // Matrix n x n
}

impl Index<usize> for RankingListMatrix {
    type Output = [u32]; // Slice of u32 representing a row

    fn index(&self, row: usize) -> &Self::Output {
        assert!(row < self.n, "Row index out of bounds");
        unsafe {
            let row_ptr = self.ptr.add(row * self.n);
            slice::from_raw_parts(row_ptr, self.n)
        }
    }
}

impl RankingListMatrix {
    pub fn rows(&self) -> impl Iterator<Item = &[u32]> {
        (0..self.n).map(move |r| &self[r])
    }
}

#[repr(C)]
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PositionMapMatrix {
    pub ptr: *const u32,
    pub n: usize, // Matrix n x n
}

impl Index<usize> for PositionMapMatrix {
    type Output = [u32]; // Slice of u32 representing a row

    fn index(&self, row: usize) -> &Self::Output {
        assert!(row < self.n, "Row index out of bounds");
        unsafe {
            let row_ptr = self.ptr.add(row * self.n);
            slice::from_raw_parts(row_ptr, self.n)
        }
    }
}

impl PositionMapMatrix {
    pub fn rows(&self) -> impl Iterator<Item = &[u32]> {
        (0..self.n).map(move |r| &self[r])
    }

    pub fn prefers(&self, subj: u32, obj1: u32, obj2: u32) -> bool {
        self[subj as usize][obj1 as usize] < self[subj as usize][obj2 as usize]
    }
}

