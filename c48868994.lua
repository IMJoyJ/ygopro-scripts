--D・クリーナン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：1回合1次，可以把这张卡装备的1张装备卡送去墓地，给与对方基本分500分伤害。
-- ●守备表示：1回合1次，可以把对方场上表侧攻击表示存在的1只怪兽当作装备卡使用只有1只给这张卡装备。
function c48868994.initial_effect(c)
	-- 攻击表示时，1回合1次，可以把这张卡装备的1张装备卡送去墓地，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48868994,0))  --"给与对方500伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c48868994.cona)
	e1:SetCost(c48868994.costa)
	e1:SetTarget(c48868994.tga)
	e1:SetOperation(c48868994.opa)
	c:RegisterEffect(e1)
	-- 守备表示时，1回合1次，可以把对方场上表侧攻击表示存在的1只怪兽当作装备卡使用只有1只给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48868994,1))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c48868994.cond)
	e2:SetTarget(c48868994.tgd)
	e2:SetOperation(c48868994.opd)
	c:RegisterEffect(e2)
end
-- 效果发动条件：此卡在攻击表示且未被无效化。
function c48868994.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 效果发动费用：选择1张可作为费用送去墓地的装备卡并执行送去墓地操作。
function c48868994.costa(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(Card.IsAbleToGraveAsCost,1,nil) end
	-- 提示玩家选择要送去墓地的装备卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,Card.IsAbleToGraveAsCost,1,1,nil)
	-- 将选定的装备卡以作为费用的原因送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果目标为对方玩家，伤害值为500。
function c48868994.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁效果的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为500点伤害。
	Duel.SetTargetParam(500)
	-- 设置效果操作信息为对对方造成500点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 执行对对方造成500点伤害的效果处理。
function c48868994.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标玩家和目标参数（伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定点数的伤害，伤害原因为效果。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果发动条件：此卡在守备表示且未被无效化，并且自身未拥有此效果。
function c48868994.cond(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
		and not e:GetHandler():IsHasEffect(48868994)
end
-- 筛选条件函数：选择对方场上表侧攻击表示且能改变控制权的怪兽。
function c48868994.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsAbleToChangeControler()
end
-- 设置效果目标选择条件：选择对方场上1只表侧攻击表示的怪兽作为目标。
function c48868994.tgd(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c48868994.filter(chkc) end
	-- 判断玩家在魔陷区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断对方场上是否存在满足条件的怪兽作为目标。
		and Duel.IsExistingTarget(c48868994.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的对方怪兽作为装备对象。
	local g=Duel.SelectTarget(tp,c48868994.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制函数：只有装备者自身能装备此卡，且被装备怪兽未被无效化时才可装备。
function c48868994.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
-- 执行装备效果处理：将目标怪兽装备给此卡并注册相关效果。
function c48868994.opd(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackPos() then
		-- 尝试将目标怪兽装备给此卡，若失败则返回。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD)
		e:SetLabelObject(tc)
		-- 注册装备限制效果，确保只有此卡能装备该怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c48868994.eqlimit)
		tc:RegisterEffect(e1)
		-- 注册装备效果，使被装备怪兽获得特定效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(48868994)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
