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
-- 筛选卡组中满足条件（怪兽族、地属性、可送入墓地）的卡作为可选的送墓对象。
function c35195612.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToGrave()
end
-- 反转效果发动时的条件判断：只要不在处理阶段就允许发动，并在发动时登记从卡组将1张卡送去墓地的操作信息。
function c35195612.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次连锁处理时将执行“从卡组把1张卡送去墓地”这一操作，用于效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 反转效果的实际处理：由玩家从卡组选择1只地属性怪兽，并将其送去墓地。
function c35195612.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示“请选择要送去墓地的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让当前玩家从自己的卡组中选出1张满足筛选条件、且可以送去墓地的地属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c35195612.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的那张卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
