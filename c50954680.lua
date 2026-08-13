--クリスタルウィング・シンクロ・ドラゴン
-- 效果：
-- 调整＋调整以外的同调怪兽1只以上
-- ①：1回合1次，这张卡以外的怪兽的效果发动时才能发动。那个发动无效并破坏。这个效果破坏怪兽的场合，这张卡的攻击力直到回合结束时上升这个效果破坏的怪兽的原本攻击力数值。
-- ②：这张卡和5星以上的对方怪兽进行战斗的伤害计算时发动。这张卡的攻击力只在那次伤害计算时上升进行战斗的对方怪兽的攻击力数值。
function c50954680.initial_effect(c)
	-- 为水晶翼同调龙添加同调召唤手续：调整 + 调整以外的同调怪兽1只以上。
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
-- ①效果的发动条件：检测到有怪兽效果发动，且发动者不是这张卡自身，这张卡未处于战斗破坏确定状态，且该连锁发动能够被无效。
function c50954680.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 判定条件为：发动效果是怪兽效果、该效果来源不是本卡、本卡没有战斗破坏确定状态、当前连锁可以被无效。
	return re:IsActiveType(TYPE_MONSTER) and rc~=c and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ①效果的发动时处理：宣告要无效的对象（正在发动的效果），并根据对象是否可破坏且仍与效果相关，决定是否同时宣告破坏对象。
function c50954680.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本连锁的操作信息为“无效发动”，对象为正在发动效果的卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动效果的那张卡可被破坏且仍与该效果关联，则设置操作信息为“破坏”该卡，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果处理：先无效对方怪兽效果的发动，若成功且那张卡仍相关，则将其破坏；若破坏成功且其原本攻击力非负，且本卡仍相关并表侧表示，则给本卡附加攻击力上升效果。
function c50954680.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 处理条件判断：无效发动成功、那张卡仍与效果相关、破坏成功（返回值不为0）、其原本攻击力非负、本卡仍与效果相关且为表侧表示。
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(rc,REASON_EFFECT)~=0 and rc:GetBaseAttack()>=0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到回合结束时上升这个效果破坏的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(rc:GetBaseAttack())
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：本卡正在进行伤害计算，战斗对象是对方怪兽且等级为5星以上。
function c50954680.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsLevelAbove(5) and bc:IsControler(1-tp)
end
-- ②效果处理：若本卡和战斗对象均仍与战斗相关且表侧表示，则为本卡附加攻击力上升效果，数值为战斗对象当前攻击力，并在伤害计算阶段结束时重置。
function c50954680.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 这张卡的攻击力只在那次伤害计算时上升进行战斗的对方怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(bc:GetAttack())
		c:RegisterEffect(e1)
	end
end
