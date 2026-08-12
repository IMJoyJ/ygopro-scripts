--クリスタルウィング・シンクロ・ドラゴン
-- 效果：
-- 调整＋调整以外的同调怪兽1只以上
-- ①：1回合1次，这张卡以外的怪兽的效果发动时才能发动。那个发动无效并破坏。这个效果破坏怪兽的场合，这张卡的攻击力直到回合结束时上升这个效果破坏的怪兽的原本攻击力数值。
-- ②：这张卡和5星以上的对方怪兽进行战斗的伤害计算时发动。这张卡的攻击力只在那次伤害计算时上升进行战斗的对方怪兽的攻击力数值。
function c50954680.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的同调怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，这张卡以外的怪兽的效果发动时才能发动。那个发动无效并破坏。这个效果破坏怪兽的场合，这张卡的攻击力直到回合结束时上升这个效果破坏的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50954680,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c50954680.condition)
	e1:SetTarget(c50954680.target)
	e1:SetOperation(c50954680.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡和5星以上的对方怪兽进行战斗的伤害计算时发动。这张卡的攻击力只在那次伤害计算时上升进行战斗的对方怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(c50954680.atkcon)
	e2:SetOperation(c50954680.atkop)
	c:RegisterEffect(e2)
end
c50954680.material_type=TYPE_SYNCHRO
-- 判断是否满足效果发动条件，包括：发动的是怪兽效果、不是自己发动、自己未因战斗破坏、连锁可被无效
function c50954680.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 发动条件：效果为怪兽类型、不是自己发动、自己未因战斗破坏、连锁可被无效
	return re:IsActiveType(TYPE_MONSTER) and rc~=c and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 设置连锁处理信息，将使发动无效的效果加入处理列表
function c50954680.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，将破坏怪兽的效果加入处理列表
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁处理信息，将破坏怪兽的效果加入处理列表
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理，使连锁发动无效并破坏对方怪兽，若成功则提升自身攻击力
function c50954680.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 判断是否成功使连锁发动无效、破坏对象存在且有效、破坏对象攻击力非负
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(rc,REASON_EFFECT)~=0 and rc:GetBaseAttack()>=0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 为自身添加攻击力增加效果，在回合结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(rc:GetBaseAttack())
		c:RegisterEffect(e1)
	end
end
-- 判断是否满足战斗时攻击力提升的条件，即对方怪兽等级不低于5星且为对方控制
function c50954680.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsLevelAbove(5) and bc:IsControler(1-tp)
end
-- 执行战斗时攻击力提升效果，将自身攻击力提升至对方怪兽的攻击力数值
function c50954680.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 为自身添加攻击力增加效果，在伤害计算阶段结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(bc:GetAttack())
		c:RegisterEffect(e1)
	end
end
