--レアル・ジェネクス・マグナ
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只2星「真次世代」怪兽加入手卡。
function c1533292.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只2星「真次世代」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1533292,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c1533292.target)
	e1:SetOperation(c1533292.operation)
	c:RegisterEffect(e1)
end
-- 筛选卡组中满足条件的卡片：等级为2、属于「真次世代」字段、且能够加入手卡的怪兽。
function c1533292.filter(c)
	return c:IsLevel(2) and c:IsSetCard(0x1002) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：确认条件并登记操作信息，表示本次效果将检索并加入手卡。
function c1533292.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组中是否存在至少1只满足条件的「真次世代」怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c1533292.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，向系统预告本次效果将把1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，从符合条件的卡中选择1张加入手卡，并向对方展示。
function c1533292.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1只满足条件的「真次世代」怪兽。
	local g=Duel.SelectMatchingCard(tp,c1533292.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
