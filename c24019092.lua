--イグナイト・マスケット
-- 效果：
-- ←2 【灵摆】 2→
-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
-- 【怪兽描述】
-- 以冷静沉着且理智出名的点火骑士参谋。其实只是头脑发热要点时间，心中好像总是快发火的样子。
function c24019092.initial_effect(c)
	-- 使这张卡获得灵摆怪兽属性（可以进行灵摆召唤以及灵摆卡的发动）。
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
-- 发动条件函数：检查自己灵摆区域是否存在满足条件的「点火骑士」卡。
function c24019092.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域是否存在除自身以外的卡名含有「点火骑士」（0xc8）字段的卡，即“另一边的自己的灵摆区域有点火骑士卡存在”。
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xc8)
end
-- 检索目标过滤函数：候选卡必须是战士族、炎属性，并且能够加入手卡。
function c24019092.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 发动时目标与操作信息设定函数：确认可以发动后，记录预定破坏的灵摆区域卡以及预定检索的范围。
function c24019092.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己的卡组·墓地中是否存在至少1只满足条件的战士族·炎属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24019092.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 取得自己灵摆区域的所有卡，作为之后预定要被破坏的对象。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置破坏效果的操作信息：预定破坏自己灵摆区域的2张卡（即g中的卡）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置加入手牌效果的操作信息：预定从自己的卡组·墓地选1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：先确认自身仍与效果相关，再破坏自己灵摆区域全部卡，然后从卡组·墓地选1只符合条件的怪兽加入手牌并向对方确认。
function c24019092.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 效果处理时重新获取当前自己灵摆区域的全部卡。
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if dg:GetCount()<2 then return end
	-- 以效果破坏自己灵摆区域的卡；只有实际破坏了2张（即全部灵摆区域卡都被破坏）时才继续后续检索处理。
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	-- 给玩家弹出“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地中选择1只满足战士族、炎属性且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c24019092.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
