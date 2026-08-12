--緊急鋼核処分
-- 效果：
-- 从自己卡组选择1张「核成兽的钢核」送去墓地。
function c63018036.initial_effect(c)
	-- 在卡片中注册其记载了「核成兽的钢核」（卡号36623431）的卡片密码
	aux.AddCodeList(c,36623431)
	-- 从自己卡组选择1张「核成兽的钢核」送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63018036.target)
	e1:SetOperation(c63018036.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中卡名为「核成兽的钢核」且能送去墓地的卡的条件函数
function c63018036.tgfilter(c)
	return c:IsCode(36623431) and c:IsAbleToGrave()
end
-- 效果发动的目标选择与检测函数
function c63018036.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己卡组是否存在至少1张满足条件的「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c63018036.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果的处理为将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c63018036.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1张满足条件的「核成兽的钢核」
	local g=Duel.SelectMatchingCard(tp,c63018036.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
