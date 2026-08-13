--おろかな副葬
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张魔法·陷阱卡送去墓地。
function c35726888.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1张魔法·陷阱卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35726888+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c35726888.target)
	e1:SetOperation(c35726888.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：对象必须是魔法·陷阱卡，并且可以被送去墓地。
function c35726888.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 发动条件与操作信息设定：进行发动合法性判定，并在满足条件时登记从卡组将1张卡送去墓地的操作信息。
function c35726888.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查卡组是否存在至少1张满足条件（魔法·陷阱卡且可送墓）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c35726888.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果属于送去墓地类别，预计从卡组将1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张魔法·陷阱卡，将其送去墓地。
function c35726888.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从玩家卡组中选择1张满足筛选条件的魔法·陷阱卡，选择数量为1张。
	local g=Duel.SelectMatchingCard(tp,c35726888.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
