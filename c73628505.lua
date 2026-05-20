--テラ・フォーミング
-- 效果：
-- ①：从卡组把1张场地魔法卡加入手卡。
function c73628505.initial_effect(c)
	-- ①：从卡组把1张场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c73628505.target)
	e1:SetOperation(c73628505.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡组中可以加入手牌的场地魔法卡
function c73628505.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置
function c73628505.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c73628505.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数：从卡组选择场地魔法卡加入手牌并给对方确认
function c73628505.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足过滤条件的场地魔法卡
	local g=Duel.SelectMatchingCard(tp,c73628505.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
