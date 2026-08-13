--吸血コアラ
-- 效果：
-- 这张卡和怪兽的战斗给与对方基本分战斗伤害时，自己基本分回复给与的战斗伤害的数值。
function c1371589.initial_effect(c)
	-- 这张卡和怪兽的战斗给与对方基本分战斗伤害时，自己基本分回复给与的战斗伤害的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1371589,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c1371589.condition)
	e1:SetTarget(c1371589.target)
	e1:SetOperation(c1371589.operation)
	c:RegisterEffect(e1)
end
-- 判定效果发动条件：本卡与怪兽战斗造成对方战斗伤害时才满足触发条件。
function c1371589.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 伤害对象不是自己（而是对方），且当前存在攻击对象，即这是怪兽之间的战斗造成的伤害。
	return ep~=tp and Duel.GetAttackTarget()~=nil
end
-- 效果发动时登记本次回复的目标玩家和回复数值，并声明该效果属于回复类别。
function c1371589.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的目标玩家设置为效果控制者自己（tp），表示要回复基本分的是自己。
	Duel.SetTargetPlayer(tp)
	-- 将连锁的目标参数设置为本次战斗伤害数值（ev），作为后续回复的数值。
	Duel.SetTargetParam(ev)
	-- 登记操作信息，声明本效果含回复基本分（CATEGORY_RECOVER），目标玩家为自己，回复量为ev。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ev)
end
-- 效果处理时从连锁信息中取出记录的目标玩家和回复数值，实际执行基本分回复。
function c1371589.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设置的目标玩家p和目标参数d（即回复量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使玩家p回复d点基本分，原因标记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
end
