--イグナイト・マグナム
-- 效果：
-- ←7 【灵摆】 7→
-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
-- 【怪兽描述】
-- 操纵剑枪的火焰战士。虽然被冰冷的钢铁铠甲包住了身体，那里头却藏着激烈燃烧般火热的心。
function c24131534.initial_effect(c)
	-- 为该灵摆怪兽添加灵摆召唤、灵摆卡发动等灵摆怪兽共通属性。
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c24131534.thcon)
	e2:SetTarget(c24131534.thtg)
	e2:SetOperation(c24131534.thop)
	c:RegisterEffect(e2)
end
-- 定义效果发动条件函数，检查另一侧自己的灵摆区是否存在「点火骑士」卡。
function c24131534.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件：以自己可见的灵摆区中，除本卡外，是否存在卡名含有「点火骑士」字段（setcode 0xc8）的卡，存在则满足发动条件。
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xc8)
end
-- 定义检索过滤条件：怪兽为战士族、炎属性且可以被加入手卡。
function c24131534.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 效果发动时的目标选择函数，负责检查可检索卡的存在并登记破坏与检索的操作信息。
function c24131534.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动确认（chk==0），检查卡组·墓地是否存在1张符合条件的怪兽，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c24131534.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 取得自己灵摆区域的全部卡作为预定破坏对象。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 登记破坏类操作信息，表明此次效果将破坏自己灵摆区的2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 登记检索加入手卡的操作信息，目标为不确定的1张卡，从卡组·墓地加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：破坏自己灵摆区的卡；若破坏成功，则从卡组·墓地选1只符合条件的怪兽加入手卡并让对方确认。
function c24131534.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 在处理时重新获取自己灵摆区域的全部卡。
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if dg:GetCount()<2 then return end
	-- 用效果破坏这些卡，若实际破坏数不足2（没有全部破坏），则中止后续检索效果。
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	-- 弹出选择“加入手牌”的卡片提示，引导玩家选择检索的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组·墓地选择1只符合条件的战士族·炎属性怪兽；过滤条件额外排除受“王家长眠之谷”影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24131534.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
