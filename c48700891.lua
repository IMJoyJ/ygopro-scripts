--記憶破壊者
-- 效果：
-- 这张卡对对方玩家直接攻击造成伤害的场合，给与对方基本分对方额外卡组的卡数×100分数值的伤害。
function c48700891.initial_effect(c)
	-- 这张卡对对方玩家直接攻击造成伤害的场合，给与对方基本分对方额外卡组的卡数×100分数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48700891,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c48700891.condition)
	e1:SetTarget(c48700891.target)
	e1:SetOperation(c48700891.operation)
	c:RegisterEffect(e1)
end
-- 定义诱发效果的发动条件：判断是否满足“这张卡对对方玩家直接攻击造成伤害”的场合。
function c48700891.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 条件成立需同时满足：受到战斗伤害的玩家不是这张卡的控制者（即伤害对象为对方），且本次战斗没有攻击对象（即直接攻击）。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 定义效果发动时的目标处理：若发动时检查通过，则记录目标玩家为对方，并将伤害数值设为对方额外卡组数量×100，同时登记该伤害操作信息。
function c48700891.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取以当前效果控制者视角来看的对方（0区域）的额外卡组卡片数量，作为伤害计算的基数。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	-- 将本次效果的目标玩家设置为对方的玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次效果的目标参数设置为“对方额外卡组卡数×100”，即伤害数值。
	Duel.SetTargetParam(ct*100)
	-- 登记当前连锁的伤害类操作信息：造成伤害的对象为对方玩家，预计伤害数值为额外卡组卡数×100，用于给其他卡的效果（如星尘龙等）进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*100)
end
-- 定义效果处理时的执行操作：在效果结算时再次获取对方额外卡组数量，取出连锁中记录的目标玩家，并给予对应数值的效果伤害。
function c48700891.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取对方额外卡组的卡片数量，确保结算时使用最新数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	-- 从当前连锁信息中取出之前设置的目标玩家，确定伤害的承受者。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以效果伤害的形式，给予该目标玩家“对方额外卡组数量×100”的基本分伤害。
	Duel.Damage(p,ct*100,REASON_EFFECT)
end
