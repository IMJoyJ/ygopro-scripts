--トゥーンのもくじ
-- 效果：
-- ①：从卡组把1张「卡通」卡加入手卡。
function c89997728.initial_effect(c)
	-- ①：从卡组把1张「卡通」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c89997728.target)
	e1:SetOperation(c89997728.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中卡名含有「卡通」且可以加入手牌的卡
function c89997728.filter(c)
	return c:IsSetCard(0x62) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置
function c89997728.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c89997728.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，处理将卡加入手牌的具体逻辑
function c89997728.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c89997728.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
