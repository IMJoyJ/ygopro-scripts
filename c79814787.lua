--伝説の白石
-- 效果：
-- ①：这张卡被送去墓地的场合发动。从卡组把1只「青眼白龙」加入手卡。
function c79814787.initial_effect(c)
	-- 记录这张卡的效果中记载了「青眼白龙」的卡名
	aux.AddCodeList(c,89631139)
	-- ①：这张卡被送去墓地的场合发动。从卡组把1只「青眼白龙」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79814787,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c79814787.target)
	e1:SetOperation(c79814787.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选卡组中卡名为「青眼白龙」且可以加入手牌的卡
function c79814787.filter(c)
	return c:IsCode(89631139) and c:IsAbleToHand()
end
-- 效果发动的目标处理函数，设置检索卡组的操作信息
function c79814787.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组将「青眼白龙」加入手牌并给对方确认
function c79814787.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中获取第一张符合过滤条件的卡（即「青眼白龙」）
	local tc=Duel.GetFirstMatchingCard(c79814787.filter,tp,LOCATION_DECK,0,nil)
	if tc~=nil then
		-- 将目标卡片因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
