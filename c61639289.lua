--イグナイト・イーグル
-- 效果：
-- ←2 【灵摆】 2→
-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
-- 【怪兽描述】
-- 很耿直属于行动派的点火骑士战士。被同伴们称为「子弹沙鹰」，经常与他保持着一点距离。
function c61639289.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有「点火骑士」卡存在的场合才能发动。自己的灵摆区域的卡全部破坏，从自己的卡组·墓地选1只战士族·炎属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c61639289.thcon)
	e2:SetTarget(c61639289.thtg)
	e2:SetOperation(c61639289.thop)
	c:RegisterEffect(e2)
end
-- 灵摆效果的发动条件函数
function c61639289.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的另一边灵摆区域是否存在除自身以外的「点火骑士」卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0xc8)
end
-- 过滤卡组或墓地中战士族·炎属性且能加入手牌的怪兽
function c61639289.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 灵摆效果的发动准备（Target）函数
function c61639289.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地中是否存在可加入手牌的战士族·炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c61639289.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 获取自己灵摆区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	-- 设置破坏自己灵摆区域2张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置从卡组或墓地将1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 灵摆效果的执行（Operation）函数
function c61639289.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前自己灵摆区域的所有卡片
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if dg:GetCount()<2 then return end
	-- 破坏自己灵摆区域的卡，若未能成功破坏2张则效果处理中止
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1只战士族·炎属性怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61639289.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
