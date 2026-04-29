import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:alisbae/viewmodel/home/home_view_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookViewModel bookViewModel;
  final BookDownloadsCubit bookDownloadsCubit;
  BookBloc(this.bookViewModel, this.bookDownloadsCubit) : super(BookInitial()) {
    on<LikeBook>((event, emit) async {
      try {
        await bookViewModel.updateLikeStatus(isLiked: true);

        await bookDownloadsCubit.getBooks(
          folderId: bookViewModel.bookStore?.folderId,
        );
        emit(BookLikeSuccess());
      } catch (e) {
        emit(BookUpdateFailed());
      }
    });

    on<DislikeBook>((event, emit) async {
      try {
        await bookViewModel.updateLikeStatus(isLiked: false);

        await bookDownloadsCubit.getBooks(
          folderId: bookViewModel.bookStore?.folderId,
        );
        emit(BookDislikeSuccess());
      } catch (e) {
        emit(BookUpdateFailed());
      }
    });

    on<BookUpdateLastRead>((event, emit) async {
      try {
        await bookViewModel.updateLastRead(
          currentRead: event.currentRead,
          lastRead: DateTime.now(),
        );
        await bookDownloadsCubit.getBooks(
          folderId: bookViewModel.bookStore?.folderId,
        );
        emit(BookLastReadUpdateSuccess());
      } catch (e) {
        emit(BookUpdateFailed());
      }
    });
    on<BookUpdateRatingandReview>((event, emit) async {
      try {
        await bookViewModel.updateRatingandReview(
          rating: event.rating,
          review: event.review,
        );
        await bookDownloadsCubit.getBooks(
          folderId: bookViewModel.bookStore?.folderId,
        );
        emit(BookRatingandReviewUpdateSuccess());
      } catch (e) {
        emit(BookUpdateFailed());
      }
    });
  }
}
