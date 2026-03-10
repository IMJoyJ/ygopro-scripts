--イグナイト・ライオット
-- 效果：
-- ←7 【灵摆】 7→
-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
-- 【怪兽描述】
-- 点火骑士的上级战士。二刀流剑枪擅长不分场合大范围横扫，不只是敌方害怕就连己方也一样害怕。
function c50407691.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c50407691.thcon)
	e2:SetTarget(c50407691.thtg)
	e2:SetOperation(c50407691.thop)
	c:RegisterEffect(e2)
end
-- 判断自己灵摆区是否存在「点火骑士」卡
function c50407691.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己灵摆区是否存在「点火骑士」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xc8)
end
-- 过滤函数：筛选战士族、炎属性且可以加入手牌的怪兽
function c50407691.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 设置效果的发动条件和处理目标，检查是否满足检索条件并设置操作信息
function c50407691.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c50407691.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 获取自己灵摆区的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置连锁操作信息：将灵摆区的卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置连锁操作信息：从卡组或墓地选1只怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：确认灵摆区卡数并进行破坏，然后检索符合条件的怪兽加入手牌
function c50407691.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取自己灵摆区的所有卡片
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if dg:GetCount()<2 then return end
	-- 将灵摆区的卡全部破坏，若未破坏2张则取消效果
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50407691.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
