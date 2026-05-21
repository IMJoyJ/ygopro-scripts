--イグナイト・ウージー
-- 效果：
-- ←7 【灵摆】 7→
-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
-- 【怪兽描述】
-- 「德林加」的监督官兼亲卫队队长。总是被鲁莽行事的她牵着鼻子走，经常跟唯一的知己「点五零」吐露苦水。
function c93662626.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和作为灵摆卡发动）
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c93662626.thcon)
	e2:SetTarget(c93662626.thtg)
	e2:SetOperation(c93662626.thop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：另一边的自己的灵摆区域有「点火骑士」卡存在
function c93662626.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域是否存在除自身以外的「点火骑士」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xc8)
end
-- 过滤条件：战士族、炎属性且能加入手牌的怪兽
function c93662626.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 效果发动准备（检查可行性并设置操作信息）
function c93662626.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测发动可行性，则检查卡组或墓地是否存在至少1只战士族·炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c93662626.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 获取自己灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置操作信息：预计破坏自己灵摆区域的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置操作信息：预计从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：破坏自己灵摆区域的卡，并从卡组或墓地将1只战士族·炎属性怪兽加入手牌
function c93662626.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取自己灵摆区域的所有卡
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if dg:GetCount()<2 then return end
	-- 破坏自己灵摆区域的卡，若未能成功破坏2张则效果处理终止
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1只满足条件的战士族·炎属性怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c93662626.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
