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
-- 筛选条件：卡片编号为24094653（即「融合」），且能够被加入手卡。
function c26902560.filter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 发动时的目标处理函数：判定能否发动，并设置本次效果的操作信息。
function c26902560.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动前检查（chk==0）：自己卡组中是否存在至少1张符合条件的「融合」，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c26902560.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果为将1张卡从卡组加入手卡，用于连锁和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从自己卡组选择1张「融合」加入手卡，并向对方展示。
function c26902560.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选出1张符合条件的「融合」（依据filter过滤）。
	local g=Duel.SelectMatchingCard(tp,c26902560.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示已加入手卡的卡，确认检索到的卡名。
		Duel.ConfirmCards(1-tp,g)
	end
end
