--おろかな副葬
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张魔法·陷阱卡送去墓地。
function c35726888.initial_effect(c)
	-- ①：从卡组把1张魔法·陷阱卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35726888+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c35726888.target)
	e1:SetOperation(c35726888.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选可以送去墓地的魔法或陷阱卡
function c35726888.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 效果的发动条件判断，检查是否满足发动条件
function c35726888.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查自己卡组中是否存在魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c35726888.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，指定将要处理的卡为1张送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果的发动处理函数，执行将卡送去墓地的操作
function c35726888.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡从卡组送去墓地
	local g=Duel.SelectMatchingCard(tp,c35726888.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
