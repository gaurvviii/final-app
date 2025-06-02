import prisma from '../lib/prisma';

interface NewsItem {
  title: string;
  description: string;
  latitude: number;
  longitude: number;
  address?: string;
  city: string;
  state: string;
  country: string;
  publishedAt: Date;
}

export const newsService = {
  async storeNewsItem(newsItem: NewsItem) {
    try {
      // First, create or find the location
      const location = await prisma.location.upsert({
        where: {
          latitude_longitude: {
            latitude: newsItem.latitude,
            longitude: newsItem.longitude
          }
        },
        create: {
          latitude: newsItem.latitude,
          longitude: newsItem.longitude,
          address: newsItem.address,
          city: newsItem.city,
          state: newsItem.state,
          country: newsItem.country
        },
        update: {}
      });

      // Then create the crime report
      const crimeReport = await prisma.crimeReport.create({
        data: {
          title: newsItem.title,
          description: newsItem.description,
          category: 'News Report',
          severity: 'Medium',
          location: {
            connect: {
              id: location.id
            }
          },
          // For now, we'll use a default user. In a real app, you'd want to associate this with an actual user
          user: {
            connect: {
              id: 'default-user-id' // You should replace this with actual user management
            }
          }
        }
      });

      return crimeReport;
    } catch (error) {
      console.error('Error storing news item:', error);
      throw error;
    }
  },

  async getRecentNewsItems(days: number = 7) {
    try {
      const date = new Date();
      date.setDate(date.getDate() - days);

      return await prisma.crimeReport.findMany({
        where: {
          createdAt: {
            gte: date
          }
        },
        include: {
          location: true
        },
        orderBy: {
          createdAt: 'desc'
        }
      });
    } catch (error) {
      console.error('Error fetching recent news items:', error);
      throw error;
    }
  }
}; 