namespace LinguaNovaBackend.Controllers
{
    // Yeni DTO class'ı ekleyin
    public class UpdateTestResponseDto
    {
        public bool Success { get; set; }
        public bool LevelUp { get; set; }
        public int? NewLevel { get; set; }
        public string Message { get; set; }
    }

    [Route("api/[controller]")]
    [ApiController]
    public class UserTestProgressController : ControllerBase
    {
        [HttpPut("UpdateIsCorrect/{id}")]
        public async Task<ActionResult<UpdateTestResponseDto>> UpdateIsCorrect(int id, [FromBody] UpdateIsCorrectDto updateDto, int type)
        {
            var existingProgress = await _context.UserTestProgresses.FindAsync(id);
            if (existingProgress == null)
            {
                return NotFound(new UpdateTestResponseDto 
                { 
                    Success = false, 
                    Message = "Test progress not found" 
                });
            }

            // UserTestProgress'i güncelle
            existingProgress.IsCorrect = updateDto.IsCorrect;
            _context.Entry(existingProgress).State = EntityState.Modified;
            await _context.SaveChangesAsync();

            // 'type' parametresine göre ilgili işlemi yap
            if (existingProgress.ArticleId.HasValue && type == 1)
            {
                await CheckAndUpdateArticleCompletion(existingProgress.ArticleId.Value, existingProgress.UserId);
            }
            else if (existingProgress.VideoId.HasValue && type == 2)
            {
                await CheckAndUpdateVideoCompletion(existingProgress.VideoId.Value, existingProgress.UserId);
            }
            else if (existingProgress.AudioId.HasValue && type == 3)
            {
                await CheckAndUpdateAudioCompletion(existingProgress.AudioId.Value, existingProgress.UserId);
            }
            
            // Level atlama kontrolü ve response
            var levelUpResult = await CheckAndUpdateLevelIfAllCompleted(existingProgress.UserId);
            
            return Ok(new UpdateTestResponseDto
            {
                Success = true,
                LevelUp = levelUpResult.LevelUp,
                NewLevel = levelUpResult.NewLevel,
                Message = levelUpResult.LevelUp ? "Congratulations! Level up!" : "Test updated successfully"
            });
        }

        // UpdateLevelIfAllCompleted metodunu yeniden düzenleyin
        private async Task<(bool LevelUp, int? NewLevel)> CheckAndUpdateLevelIfAllCompleted(int userId)
        {
            // Kullanıcının mevcut seviyesini al
            var user = await _context.Users
                .Where(u => u.Id == userId)
                .FirstOrDefaultAsync();
        
            if (user == null)
                return (false, null);

            var currentLevel = user.Level;

            // Kullanıcının seviyesindeki tüm makale içeriklerini al
            var articles = await _context.Articles
                .Where(a => a.Level == currentLevel)
                .ToListAsync();

            // Kullanıcının seviyesindeki tüm video içeriklerini al
            var videos = await _context.Videos
                .Where(v => v.Level == currentLevel)
                .ToListAsync();

            // Kullanıcının seviyesindeki tüm ses içeriklerini al
            var audios = await _context.Audios
                .Where(a => a.Level == currentLevel)
                .ToListAsync();

            // Eğer hiç içerik yoksa false döndür
            if (!articles.Any() && !videos.Any() && !audios.Any())
                return (false, null);

            // Makale testlerinin tamamlanma durumu
            bool allArticlesCompleted = !articles.Any() || await _context.UserArticleProgresses
                .Where(up => up.UserId == userId && articles.Select(a => a.Id).Contains(up.ArticleId))
                .AllAsync(up => up.IsCompleted);

            // Video testlerinin tamamlanma durumu
            bool allVideosCompleted = !videos.Any() || await _context.UserVideoProgresses
                .Where(up => up.UserId == userId && videos.Select(v => v.Id).Contains(up.VideoId))
                .AllAsync(up => up.IsCompleted);

            // Ses testlerinin tamamlanma durumu
            bool allAudiosCompleted = !audios.Any() || await _context.UserAudioProgresses
                .Where(up => up.UserId == userId && audios.Select(a => a.Id).Contains(up.AudioId))
                .AllAsync(up => up.IsCompleted);

            // Eğer tüm içerikler tamamlanmışsa, kullanıcı bir üst seviyeye geçsin
            if (allArticlesCompleted && allVideosCompleted && allAudiosCompleted)
            {
                user.Level += 1; // Seviyeyi artır
                _context.Users.Update(user);
                await _context.SaveChangesAsync();
                return (true, user.Level);
            }

            return (false, user.Level);
        }
    }
} 