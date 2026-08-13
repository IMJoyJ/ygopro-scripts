--重力砲
-- 效果：
-- 机械族怪兽才能装备。1回合1次，可以让装备怪兽的攻击力上升400。此外，装备怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
function c35220244.initial_effect(c)
	-- 机械族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c35220244.target)
	e1:SetOperation(c35220244.operation)
	c:RegisterEffect(e1)
	-- 机械族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c35220244.eqlimit)
	c:RegisterEffect(e2)
	-- 1回合1次，可以让装备怪兽的攻击力上升400。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35220244,0))  --"攻击上升"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(c35220244.atkop)
	c:RegisterEffect(e3)
	-- 装备怪兽和对方怪兽进行战斗的场合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCondition(c35220244.discon)
	e4:SetOperation(c35220244.disop)
	c:RegisterEffect(e4)
	-- 只在战斗阶段内那只对方怪兽的效果无效化。
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
-- 装备限制判定：仅允许机械族怪兽装备此卡。
function c35220244.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 装备对象过滤器：选择双方场上表侧表示且机械族的怪兽。
function c35220244.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 装备魔法发动流程：确认存在可装备的表侧机械族怪兽，选择1只作为对象，并设置将本卡装备给对象的操作信息。
function c35220244.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c35220244.eqfilter(chkc) end
	-- 发动时检查是否存在至少1只场上表侧表示且机械族的怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c35220244.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择装备对象的提示信息，让玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只场上表侧表示机械族怪兽作为装备对象，并设为该连锁的对象。
	Duel.SelectTarget(tp,c35220244.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将本卡作为装备卡装备给对象（CATEGORY_EQUIP）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备处理：若本卡与对象均仍与效果关联且对象表侧表示，则将本卡装备给对象怪兽。
function c35220244.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 由当前玩家将本卡（装备魔法卡）装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 起动效果处理：若本卡仍装备着怪兽，则为装备怪兽附加攻击力上升400的效果。
function c35220244.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		-- 可以让装备怪兽的攻击力上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end
-- 战斗相关触发条件：装备怪兽为我方怪兽且正参与战斗（作为攻击方或被攻击对象），并存在战斗对象。
function c35220244.discon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判定装备怪兽是否正在与对方怪兽进行战斗，并获取其战斗对象。
	return ec and ec:IsControler(tp) and (ec==Duel.GetAttacker() or ec==Duel.GetAttackTarget()) and ec:GetBattleTarget()
end
-- 无效化标记处理：给与装备怪兽战斗的对方怪兽附加战斗阶段内有效的标记，并立即刷新无效状态。
function c35220244.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	tc:RegisterFlagEffect(35220244,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	-- 立即刷新场上受此效果影响的卡的无效状态，使战斗对象效果即时被无效。
	Duel.AdjustInstantly(e:GetHandler())
end
-- 无效化对象筛选：持有战斗阶段标记（35220244）的对方怪兽作为效果无效的对象。
function c35220244.distg(e,c)
	return c:GetFlagEffect(35220244)~=0
end
