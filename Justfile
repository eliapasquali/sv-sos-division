COMPILE := "typst compile --root ."
WATCH := "typst watch --root ."

@all: compile-notes compile-slides

compile-notes:
    @echo "Compiling notes (notes/notes.typ -> notes/notes.pdf)"
    @{{COMPILE}} notes/notes.typ

compile-slides:
    @echo "Compiling slides (slides/slides.typ -> slides/slides.pdf)..."
    @{{COMPILE}} slides/slides.typ

watch-notes:
    @echo "Watching notes"
    @{{WATCH}} notes/notes.typ

watch-slides:
    @echo "Watching slides"
    @{{WATCH}} slides/slides.typ

clean:
    @echo "Removing all generated files"
    @find ./common -type f -name "*.pdf" -not -path "./common/assets/*" -delete
    @find ./notes -type f -name "*.pdf" -not -path "./notes/assets/*" -delete
    @find ./slides -type f -name "*.pdf" -not -path "./slides/assets/*" -delete