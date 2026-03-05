--鋼核収納
-- 效果：
-- 名字带有「核成」的怪兽才能装备。和装备怪兽进行战斗的对方怪兽的攻击力只在那次伤害计算时下降装备怪兽的等级×100的数值。装备怪兽在结束阶段时被破坏的场合，可以作为代替把这张卡送去墓地。
function c20457551.initial_effect(c)
	-- 名字带有「核成」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c20457551.target)
	e1:SetOperation(c20457551.operation)
	c:RegisterEffect(e1)
	-- 和装备怪兽进行战斗的对方怪兽的攻击力只在那次伤害计算时下降装备怪兽的等级×100的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c20457551.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽在结束阶段时被破坏的场合，可以作为代替把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c20457551.atkcon)
	e3:SetTarget(c20457551.atktg)
	e3:SetValue(c20457551.atkval)
	c:RegisterEffect(e3)
	-- 效果作用
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c20457551.desreptg)
	c:RegisterEffect(e4)
end
-- 装备对象必须为名字带有「核成」的怪兽
function c20457551.eqlimit(e,c)
	return c:IsSetCard(0x1d)
end
-- 筛选名字带有「核成」的表侧怪兽
function c20457551.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d)
end
-- 选择装备对象，设置效果处理信息
function c20457551.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20457551.filter(chkc) end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(c20457551.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,c20457551.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡效果处理
function c20457551.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 伤害计算时触发效果
function c20457551.atkcon(e)
	-- 当前阶段为伤害计算阶段
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		and e:GetHandler():GetEquipTarget():GetBattleTarget()
end
-- 设定攻击对象为装备怪兽战斗中的对方怪兽
function c20457551.atktg(e,c)
	return c==e:GetHandler():GetEquipTarget():GetBattleTarget()
end
-- 设定攻击力下降值为装备怪兽等级×100
function c20457551.atkval(e,c)
	return e:GetHandler():GetEquipTarget():GetLevel()*-100
end
-- 代替破坏效果处理
function c20457551.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否为结束阶段且装备卡未被预定破坏
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_END and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED)
		and not e:GetHandler():GetEquipTarget():IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将装备卡送去墓地
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
		return true
	else return false end
end
