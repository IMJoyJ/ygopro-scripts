--堕天使ユコバック
-- 效果：
-- 「堕天使 乌科巴克」的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「堕天使」卡送去墓地。
function c92807548.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「堕天使」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92807548,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,92807548)
	e1:SetTarget(c92807548.tgtg)
	e1:SetOperation(c92807548.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以送去墓地的「堕天使」卡
function c92807548.tgfilter(c)
	return c:IsSetCard(0xef) and c:IsAbleToGrave()
end
-- 效果①的发动准备（检查卡组中是否存在可送去墓地的「堕天使」卡，并设置送去墓地的操作信息）
function c92807548.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以送去墓地的「堕天使」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92807548.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理（从卡组选择1张「堕天使」卡送去墓地）
function c92807548.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「堕天使」卡
	local g=Duel.SelectMatchingCard(tp,c92807548.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
