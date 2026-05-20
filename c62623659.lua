--ゼアル・コンストラクション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把1张手卡给对方观看，从卡组把以下的卡之内任意1张加入手卡。那之后，给人观看的卡回到卡组。
-- ●「异热同心武器」怪兽
-- ●「异热同心从者」怪兽
-- ●「异热同心」魔法·陷阱卡
-- ●「升阶魔法」魔法卡
-- ●「降阶魔法」魔法卡
function c62623659.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把1张手卡给对方观看，从卡组把以下的卡之内任意1张加入手卡。那之后，给人观看的卡回到卡组。●「异热同心武器」怪兽●「异热同心从者」怪兽●「异热同心」魔法·陷阱卡●「升阶魔法」魔法卡●「降阶魔法」魔法卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62623659,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,62623659+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c62623659.target)
	e1:SetOperation(c62623659.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中满足条件的「异热同心武器」怪兽、「异热同心从者」怪兽、「异热同心」魔陷、「升阶魔法」魔法、「降阶魔法」魔法
function c62623659.filter(c)
	return ((c:IsSetCard(0x107e,0x207e) and c:IsType(TYPE_MONSTER))
		or (c:IsSetCard(0x7e) and c:IsType(TYPE_SPELL+TYPE_TRAP))
		or (c:IsSetCard(0x95,0x15e) and c:IsType(TYPE_SPELL))) and c:IsAbleToHand()
end
-- 过滤手牌中未公开且可以回到卡组的卡片
function c62623659.tdfilter(c)
	return not c:IsPublic() and c:IsAbleToDeck()
end
-- 效果发动时的可行性检测
function c62623659.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c62623659.filter,tp,LOCATION_DECK,0,1,nil)
		-- 检查手牌中是否存在可以展示并回到卡组的卡片
		and Duel.IsExistingMatchingCard(c62623659.tdfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c62623659.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手牌中1张要给对方观看的卡片
	local g=Duel.SelectMatchingCard(tp,c62623659.tdfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 给对方玩家确认选择的手牌
	Duel.ConfirmCards(1-tp,g)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的卡片
	local g1=Duel.SelectMatchingCard(tp,c62623659.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g1:GetCount()~=0 then
		-- 将选择的卡片加入手牌
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g1)
		-- 阶段性中断效果，使后续的回到卡组处理不与加入手牌同时进行
		Duel.BreakEffect()
		-- 将给对方观看的卡片送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	else
		-- 若未成功检索，则洗切手牌
		Duel.ShuffleHand(tp)
	end
end
