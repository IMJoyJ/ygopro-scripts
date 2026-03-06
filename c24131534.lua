--イグナイト・マグナム
-- 效果：
-- ←7 【灵摆】 7→
-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
-- 【怪兽描述】
-- 操纵剑枪的火焰战士。虽然被冰冷的钢铁铠甲包住了身体，那里头却藏着激烈燃烧般火热的心。
function c24131534.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
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
-- 判断另一边的自己的灵摆区域是否存在「点火骑士」卡
function c24131534.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 另一边的自己的灵摆区域存在「点火骑士」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xc8)
end
-- 定义过滤函数，用于筛选战士族·炎属性且可以加入手牌的怪兽
function c24131534.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 设置效果的发动条件和目标，检查卡组和墓地是否存在符合条件的怪兽，并设置操作信息
function c24131534.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组和墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c24131534.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 获取自己灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置操作信息：将灵摆区域的卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置操作信息：从卡组或墓地选1只怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 设置效果的处理流程，包括确认卡是否有效、破坏灵摆区域的卡、选择并加入手牌
function c24131534.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取自己灵摆区域的所有卡
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if dg:GetCount()<2 then return end
	-- 破坏灵摆区域的卡，若未破坏2张则返回
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24131534.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
