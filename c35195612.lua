--砂塵の騎士
-- 效果：
-- 反转：从卡组把1只地属性怪兽送去墓地。
function c35195612.initial_effect(c)
	-- 反转：从卡组把1只地属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35195612,0))  --"检索送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c35195612.target)
	e1:SetOperation(c35195612.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的怪兽卡（地属性且能送去墓地）
function c35195612.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToGrave()
end
-- 效果处理时的处理目标函数，设置将要处理的卡为1张卡，来自卡组
function c35195612.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为送去墓地效果，目标为1张卡，来自卡组
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行将符合条件的卡从卡组送去墓地的操作
function c35195612.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c35195612.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
