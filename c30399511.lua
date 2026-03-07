--ジェネクス・パワー・プランナー
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只3星「次世代」效果怪兽加入手卡。
function c30399511.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从卡组把1只3星「次世代」效果怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30399511,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c30399511.target)
	e1:SetOperation(c30399511.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的怪兽：等级为3、卡名含「次世代」、具有效果、可以送去手卡
function c30399511.filter(c)
	return c:IsLevel(3) and c:IsSetCard(0x2) and c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
-- 效果的处理目标函数，检查是否满足发动条件并设置操作信息
function c30399511.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：卡组中是否存在至少1张满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c30399511.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行检索并加入手牌的操作
function c30399511.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c30399511.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方能看到被送去手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
