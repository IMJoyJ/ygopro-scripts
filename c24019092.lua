--イグナイト・マスケット
-- 效果：
-- ←2 【灵摆】 2→
-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
-- 【怪兽描述】
-- 以冷静沉着且理智出名的点火骑士参谋。其实只是头脑发热要点时间，心中好像总是快发火的样子。
function c24019092.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c24019092.thcon)
	e2:SetTarget(c24019092.thtg)
	e2:SetOperation(c24019092.thop)
	c:RegisterEffect(e2)
end
-- 判断另一边的自己的灵摆区域是否存在「点火骑士」卡
function c24019092.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家tp来看的自己的灵摆区域是否存在至少1张卡，且该卡的种族为点火骑士（0xc8）
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xc8)
end
-- 定义过滤函数，用于筛选满足条件的战士族·炎属性怪兽
function c24019092.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 设置效果的发动条件和目标，检查是否满足检索条件并设置操作信息
function c24019092.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的自己的卡组和墓地是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c24019092.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 获取玩家tp的灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置操作信息，表示将要破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置操作信息，表示将要从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 设置效果的处理函数，执行效果的主要逻辑
function c24019092.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取玩家tp的灵摆区域的所有卡
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if dg:GetCount()<2 then return end
	-- 破坏玩家tp的灵摆区域的全部卡，若未破坏2张则返回
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家tp的卡组和墓地中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24019092.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入玩家的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家能看到被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
