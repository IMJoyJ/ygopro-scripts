--トップ・シェア
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选1张卡，给双方确认并在卡组最上面放置。那之后，对方从自身卡组选1张卡，给双方确认并在自身卡组最上面放置。
function c90359458.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组选1张卡，给双方确认并在卡组最上面放置。那之后，对方从自身卡组选1张卡，给双方确认并在自身卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90359458,1))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,90359458+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c90359458.target)
	e1:SetOperation(c90359458.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的可行性检查（Target函数）
function c90359458.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方卡组的卡片数量是否都在2张以上（发动条件）
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=2 end
end
-- 效果处理的执行（Activate函数）
function c90359458.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自身卡组卡片数量不足2张，则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<2 then return end
	-- 提示自身玩家选择要放置在卡组最上面的卡片
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(90359458,0))  --"请选择要放置在卡组最上面的卡"
	-- 自身玩家从卡组选择1张卡片
	local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 洗切自身卡组
	Duel.ShuffleDeck(tp)
	-- 将选择的卡片移动到自身卡组最上面
	Duel.MoveSequence(tc,SEQ_DECKTOP)
	-- 给双方确认自身卡组最上面的1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 若对方卡组卡片数量不足2张，则不处理后续效果
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<2 then return end
	-- 中断当前效果，使之后的效果处理（对方选卡）不视为同时处理
	Duel.BreakEffect()
	-- 提示对方玩家选择要放置在卡组最上面的卡片
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(90359458,0))  --"请选择要放置在卡组最上面的卡"
	-- 对方玩家从自身卡组选择1张卡片
	local tc2=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 洗切对方卡组
	Duel.ShuffleDeck(1-tp)
	-- 将选择的卡片移动到对方卡组最上面
	Duel.MoveSequence(tc2,SEQ_DECKTOP)
	-- 给双方确认对方卡组最上面的1张卡
	Duel.ConfirmDecktop(1-tp,1)
end
