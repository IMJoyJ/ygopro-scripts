--調律
-- 效果：
-- ①：从卡组把1只「同调士」调整加入手卡。那之后，自己卡组最上面的卡送去墓地。
function c96363153.initial_effect(c)
	-- ①：从卡组把1只「同调士」调整加入手卡。那之后，自己卡组最上面的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c96363153.target)
	e1:SetOperation(c96363153.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中卡名含有「同调士」的调整怪兽且该卡可以加入手卡
function c96363153.filter(c)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 效果发动时的合法性检测，检查玩家是否能将卡组顶端的卡送去墓地，以及卡组中是否存在符合条件的怪兽
function c96363153.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自身卡组是否能将至少1张卡送去墓地（防止因无法送墓而不能发动）
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 在发动阶段，检查自身卡组是否存在至少1只满足过滤条件的「同调士」调整怪兽
		and Duel.IsExistingMatchingCard(c96363153.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示此效果包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的核心逻辑，执行检索「同调士」调整加入手卡，洗卡，并把卡组最上面的卡送去墓地
function c96363153.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的「同调士」调整怪兽
	local g=Duel.SelectMatchingCard(tp,c96363153.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自身卡组
		Duel.ShuffleDeck(tp)
		-- 中断当前效果处理，使后续的送墓处理与加入手卡不视为同时进行（会造成错时点）
		Duel.BreakEffect()
		-- 将自身卡组最上面的1张卡因效果送去墓地
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
	end
end
