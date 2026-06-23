--重力砲
-- 效果：
-- 机械族怪兽才能装备。1回合1次，可以让装备怪兽的攻击力上升400。此外，装备怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
function c35220244.initial_effect(c)
	-- 装备怪兽的攻击力上升400
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c35220244.target)
	e1:SetOperation(c35220244.operation)
	c:RegisterEffect(e1)
	-- 机械族怪兽才能装备
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c35220244.eqlimit)
	c:RegisterEffect(e2)
	-- 1回合1次，可以让装备怪兽的攻击力上升400
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35220244,0))  --"攻击上升"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(c35220244.atkop)
	c:RegisterEffect(e3)
	-- 装备怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCondition(c35220244.discon)
	e4:SetOperation(c35220244.disop)
	c:RegisterEffect(e4)
	-- 装备怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetTarget(c35220244.distg)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e6)
end
-- 限制只能装备给机械族怪兽
function c35220244.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 筛选场上正面表示的机械族怪兽
function c35220244.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 选择场上正面表示的机械族怪兽作为装备对象
function c35220244.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c35220244.eqfilter(chkc) end
	-- 判断是否存在符合条件的装备对象
	if chk==0 then return Duel.IsExistingTarget(c35220244.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,c35220244.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c35220244.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 使装备怪兽的攻击力上升400
function c35220244.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		-- 使装备怪兽的攻击力上升400
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end
-- 判断是否满足无效化条件
function c35220244.discon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 装备怪兽控制者为玩家且参与战斗
	return ec and ec:IsControler(tp) and (ec==Duel.GetAttacker() or ec==Duel.GetAttackTarget()) and ec:GetBattleTarget()
end
-- 设置对方怪兽在战斗阶段内效果无效的标记
function c35220244.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	tc:RegisterFlagEffect(35220244,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	-- 刷新场上卡片状态
	Duel.AdjustInstantly(e:GetHandler())
end
-- 判断目标怪兽是否被标记为无效化
function c35220244.distg(e,c)
	return c:GetFlagEffect(35220244)~=0
end
