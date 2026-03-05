--レアル・ジェネクス・マグナ
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只2星「真次世代」怪兽加入手卡。
function c1533292.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤时才能发动。从卡组把1只2星「真次世代」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1533292,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c1533292.target)
	e1:SetOperation(c1533292.operation)
	c:RegisterEffect(e1)
end
-- 检索满足等级为2、卡名含真次世代、可以送去手卡条件的卡
function c1533292.filter(c)
	return c:IsLevel(2) and c:IsSetCard(0x1002) and c:IsAbleToHand()
end
-- 效果作用：检查是否满足条件的卡存在于卡组
function c1533292.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1533292.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置连锁操作信息为检索卡组效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果原文内容：从卡组把1只2星「真次世代」怪兽加入手卡。
function c1533292.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c1533292.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
