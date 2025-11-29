import api from './api'

export interface University {
  id: string
  name: string
  short_name: string
  description?: string
  logo?: string
  website?: string
  email?: string
  phone?: string
  address?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Campus {
  id: string
  name: string
  university: string
  address?: string
  city?: string
  is_main: boolean
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Department {
  id: string
  name: string
  university: string
  description?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface UniversitySettings {
  id: string
  university: string
  allow_student_registration: boolean
  require_email_verification: boolean
  require_phone_verification: boolean
  auto_verify_students: boolean
  max_groups_per_student: number
  max_events_per_student: number
  created_at: string
  updated_at: string
}

export const universityService = {
  // Universities
  getUniversities: async (params?: {
    search?: string
    is_active?: boolean
    page?: number
    page_size?: number
  }) => {
    const response = await api.get('/users/universities/', { params })
    return response.data
  },

  getUniversity: async (id: string) => {
    const response = await api.get(`/users/universities/${id}/`)
    return response.data
  },

  getMyUniversity: async () => {
    const response = await api.get('/users/universities/my_university/')
    return response.data
  },

  getUniversitySettings: async (universityId: string) => {
    const response = await api.get(`/users/universities/${universityId}/settings/`)
    return response.data
  },

  updateUniversitySettings: async (universityId: string, settings: Partial<UniversitySettings>) => {
    const response = await api.put(`/users/universities/${universityId}/settings/`, settings)
    return response.data
  },

  // Campuses
  getCampuses: async (params?: {
    university?: string
    search?: string
    is_active?: boolean
    page?: number
    page_size?: number
  }) => {
    const response = await api.get('/users/campuses/', { params })
    return response.data
  },

  getCampus: async (id: string) => {
    const response = await api.get(`/users/campuses/${id}/`)
    return response.data
  },

  createCampus: async (campusData: Partial<Campus> & { university: string }) => {
    // Convert university object/string to university_id
    const { university, ...restData } = campusData
    const payload = {
      ...restData,
      university_id: typeof university === 'string' ? university : university
    }
    const response = await api.post('/users/campuses/', payload)
    return response.data
  },

  updateCampus: async (id: string, campusData: Partial<Campus>) => {
    const response = await api.put(`/users/campuses/${id}/`, campusData)
    return response.data
  },

  deleteCampus: async (id: string) => {
    const response = await api.delete(`/users/campuses/${id}/`)
    return response.data
  },

  // Departments
  getDepartments: async (params?: {
    university?: string
    search?: string
    is_active?: boolean
    page?: number
    page_size?: number
  }) => {
    const response = await api.get('/users/departments/', { params })
    return response.data
  },

  getDepartment: async (id: string) => {
    const response = await api.get(`/users/departments/${id}/`)
    return response.data
  },

  createDepartment: async (departmentData: Partial<Department> & { university: string }) => {
    // Convert university object/string to university_id
    const { university, ...restData } = departmentData
    const payload = {
      ...restData,
      university_id: typeof university === 'string' ? university : university
    }
    const response = await api.post('/users/departments/', payload)
    return response.data
  },

  updateDepartment: async (id: string, departmentData: Partial<Department>) => {
    const response = await api.put(`/users/departments/${id}/`, departmentData)
    return response.data
  },

  deleteDepartment: async (id: string) => {
    const response = await api.delete(`/users/departments/${id}/`)
    return response.data
  },
}

