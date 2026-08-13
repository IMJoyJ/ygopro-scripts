--ディメンション・スフィンクス
-- 效果：
-- 以自己场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
-- ①：作为对象的怪兽被比那只怪兽攻击力高的对方怪兽攻击的战斗步骤中1次，可以把这个效果发动。给与对方那只攻击怪兽和作为对象的怪兽的攻击力差的数值的伤害。
-- ②：作为对象的怪兽从场上离开的场合这张卡破坏。
function c17787975.initial_effect(c)
	-- 以自己场上1只表侧攻击表示怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c17787975.target)
	e1:SetOperation(c17787975.tgop)
	c:RegisterEffect(e1)
	-- ①：作为对象的怪兽被比那只怪兽攻击力高的对方怪兽攻击的战斗步骤中1次，可以把这个效果发动。给与对方那只攻击怪兽和作为对象的怪兽的攻击力差的数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17787975,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(TIMING_BATTLE_PHASE)
	e3:SetCondition(c17787975.damcon)
	e3:SetTarget(c17787975.damtg)
	e3:SetOperation(c17787975.damop)
	c:RegisterEffect(e3)
	-- ②：作为对象的怪兽从场上离开的场合这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c17787975.descon)
	e4:SetOperation(c17787975.desop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断怪兽是否为表侧攻击表示。
function c17787975.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 发动时的目标处理：选择自己场上1只表侧攻击表示怪兽作为对象。
function c17787975.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c17787975.filter(chkc) end
	-- 发动合法性检查：自己场上是否存在1只表侧攻击表示怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(c17787975.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，让玩家从表侧表示的怪兽中选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧攻击表示怪兽，并将其设为这张卡的效果对象。
	Duel.SelectTarget(tp,c17787975.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 发动处理：若这张卡和对象怪兽仍关联且对象怪兽表侧表示，则建立这张卡对对象怪兽的持续对象关系。
function c17787975.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 伤害效果的发动条件：当前阶段为战斗步骤。
function c17787975.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否处于战斗步骤。
	return Duel.GetCurrentPhase()==PHASE_BATTLE_STEP
end
-- 伤害效果发动条件及合法目标检查：对象怪兽正被攻击、攻击怪兽是对方怪兽且攻击力高于对象怪兽、本回合此卡还未发动过该效果。
function c17787975.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	-- 获取当前攻击的怪兽。
	local at=Duel.GetAttacker()
	-- 检查战斗的攻击目标是否就是这张卡持续对象的那只怪兽。
	if chk==0 then return tc and Duel.GetAttackTarget()==tc
		and at and at:IsControler(1-tp) and at:GetAttack()>tc:GetAttack()
		and c:GetFlagEffect(17787975)==0 end
	local dam=math.abs(at:GetAttack()-tc:GetAttack())
	-- 设置受到伤害的玩家为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为攻击怪兽与对象怪兽的攻击力差值。
	Duel.SetTargetParam(dam)
	-- 登记操作信息，表明将要对对方造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	c:RegisterFlagEffect(17787975,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 伤害效果处理：若攻击怪兽仍关联本次战斗，则根据连锁信息中保存的玩家和攻击力差值给予伤害。
function c17787975.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if not tc then return false end
	-- 获取当前攻击的怪兽。
	local at=Duel.GetAttacker()
	if at:IsRelateToBattle() then
		-- 获取连锁中登记的对象玩家（对方）。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 给予对方攻击怪兽与对象怪兽攻击力差值的伤害。
		Duel.Damage(p,math.abs(at:GetAttack()-tc:GetAttack()),REASON_EFFECT)
	end
end
-- 持续效果条件：这张卡的持续对象怪兽从场上离开。
function c17787975.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 持续效果处理：将此卡破坏。
function c17787975.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
