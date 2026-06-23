--融合賢者
-- 效果：
-- 选1张自己的卡组的「融合」加入手卡。之后洗切卡组。
function c26902560.initial_effect(c)
	-- 选1张自己的卡组的「融合」加入手卡。之后洗切卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26902560.target)
	e1:SetOperation(c26902560.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查卡号为24094653且可以送去手卡的卡片
function c26902560.filter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果的发动时点处理，检查是否满足发动条件并设置操作信息
function c26902560.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足filter条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c26902560.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将1张卡从卡组送去手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，选择并处理目标卡片
function c26902560.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家的卡组中选择1张满足filter条件的卡片
	local g=Duel.SelectMatchingCard(tp,c26902560.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因送去手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认被选中的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
