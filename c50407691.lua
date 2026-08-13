--イグナイト・ライオット
-- 效果：
-- ←7 【灵摆】 7→
-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
-- 【怪兽描述】
-- 点火骑士的上级战士。二刀流剑枪擅长不分场合大范围横扫，不只是敌方害怕就连己方也一样害怕。
function c50407691.initial_effect(c)
	-- 为这张灵摆怪兽添加灵摆怪兽属性，使其具备灵摆召唤和灵摆卡发动的相关基础效果。
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
-- 定义效果的发动条件函数：检查自己灵摆区域是否满足存在另一张「点火骑士」卡的条件。
function c50407691.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区域是否存在除自身以外的1张「点火骑士」系列卡（0xc8为该系列字段）。
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xc8)
end
-- 定义检索用的过滤条件：要求是战士族、炎属性且能够加入手卡的怪兽。
function c50407691.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 定义效果的发动时目标选择与操作信息登记函数：确认发动合法性，并登记破坏自己灵摆区全部卡及检索加入手卡的操作信息。
function c50407691.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：自己卡组或墓地是否存在至少1只符合条件的战士族·炎属性怪兽可供检索。
	if chk==0 then return Duel.IsExistingMatchingCard(c50407691.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 获取自己灵摆区域的全部卡，作为这组效果中预定要被破坏的对象。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 登记破坏效果的操作信息：预定破坏自己灵摆区域全部卡，预期数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 登记检索加入手卡的操作信息：处理时从自己卡组·墓地选1只符合条件的怪兽加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义效果处理函数：效果处理时确认发动卡仍在灵摆区域，破坏自己灵摆区域全部卡；若破坏成功，则从卡组·墓地选1只符合条件的怪兽加入手卡并向对方确认。
function c50407691.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取自己灵摆区域当前全部卡，作为实际处理时的破坏对象。
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if dg:GetCount()<2 then return end
	-- 用效果破坏自己灵摆区域的全部卡；若实际破坏数量不等于2，则后续检索处理不执行。
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	-- 向操作玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组·墓地选择1只符合条件的战士族·炎属性怪兽，过滤时排除受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50407691.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
