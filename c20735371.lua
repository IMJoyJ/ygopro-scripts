--バイバイダメージ
-- 效果：
-- 这个卡名的效果1回合只能适用1次。
-- ①：自己怪兽被攻击的伤害计算时才能发动。那只自己怪兽不会被那次战斗破坏。那次战斗让自己受到战斗伤害时，对方受到那个数值2倍的效果伤害。
function c20735371.initial_effect(c)
	-- 这个卡名的效果1回合只能适用1次。①：自己怪兽被攻击的伤害计算时才能发动。那只自己怪兽不会被那次战斗破坏。那次战斗让自己受到战斗伤害时，对方受到那个数值2倍的效果伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c20735371.condition)
	e1:SetTarget(c20735371.target)
	e1:SetOperation(c20735371.activate)
	c:RegisterEffect(e1)
end
-- 伤害计算时点判定：取得攻击怪兽及其战斗目标，确认攻击者为对方怪兽、被攻击者为己方怪兽，并把被攻击的己方怪兽存入效果的LabelObject，供后续效果处理使用。
function c20735371.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前进行伤害计算的攻击怪兽，用于后续判断攻击对象是否为己方怪兽。
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	e:SetLabelObject(d)
	return a:IsControler(1-tp) and d and d:IsControler(tp)
end
-- 效果发动的合法性检查：确认己方本回合尚未适用过本卡名效果（无20735371标志），保证该效果1回合只能适用1次；发动时无需选择对象。
function c20735371.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动询问（chk==0）时，检查己方是否没有本卡名已使用标志，以此实现1回合1次限制。
	if chk==0 then return Duel.GetFlagEffect(tp,20735371)==0 end
end
-- 效果处理：再次确认本回合未适用过本卡名效果；从效果取出被攻击的己方怪兽，若其仍与本次战斗关联，则给它附加不会被本次战斗破坏的效果；随后在本伤害步骤内注册一个监听战斗伤害的持续效果，用于把所受伤害的2倍反弹给对方；最后登记本卡名已使用过的标志。
function c20735371.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次检查本回合是否已适用过本卡名效果，若已有标志则直接终止处理，防止重复适用。
	if Duel.GetFlagEffect(tp,20735371)~=0 then return end
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if not tc:IsRelateToBattle() then return end
	-- 那只自己怪兽不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e1)
	-- 这个卡名的效果1回合只能适用1次。那次战斗让自己受到战斗伤害时，对方受到那个数值2倍的效果伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c20735371.damcon)
	e2:SetOperation(c20735371.damop)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将伤害反弹效果e2以场地持续效果的形式注册给tp方，使其在本次伤害步骤内监听EVENT_BATTLE_DAMAGE。
	Duel.RegisterEffect(e2,tp)
	-- 为tp玩家注册本卡名的使用标志（持续到结束阶段重置），用于记录本回合已适用过该效果，实现1回合1次限制。
	Duel.RegisterFlagEffect(tp,20735371,RESET_PHASE+PHASE_END,0,1)
end
-- 伤害反弹效果的条件：本次战斗伤害的承受者是己方tp（即“那次战斗让自己受到战斗伤害时”）。
function c20735371.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 效果处理：当己方受到战斗伤害时，给对方玩家造成两倍于该数值的效果伤害。
function c20735371.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 对对方玩家造成本次战斗伤害数值2倍的效果伤害（ev为受到的战斗伤害值）。
	Duel.Damage(1-tp,ev*2,REASON_EFFECT)
end
