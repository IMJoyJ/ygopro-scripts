--復讐の女戦士ローズ
-- 效果：
-- ①：这张卡给与对方战斗伤害的场合发动。给与对方300伤害。
function c1557341.initial_effect(c)
	-- ①：这张卡给与对方战斗伤害的场合发动。给与对方300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1557341,0))  --"300伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c1557341.condition)
	e1:SetTarget(c1557341.target)
	e1:SetOperation(c1557341.operation)
	c:RegisterEffect(e1)
end
-- 判定受到战斗伤害的玩家不是这张卡的控制者，即仅当对方受到战斗伤害时效果满足发动条件。
function c1557341.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 发动时的目标处理：本效果不需要选择卡牌，直接返回可发动；随后将对象玩家设为对方，伤害参数设为300，并登记此次伤害效果的操作信息。
function c1557341.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为这张卡控制者的对手（1-tp），即最终要受到伤害的玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为300，表示此次效果将造成的伤害数值。
	Duel.SetTargetParam(300)
	-- 登记当前连锁为伤害效果，目标玩家为对方，伤害值为300，供系统进行后续效果交互检测（如对伤害效果的应答等）；targets 为 nil 表示不取对象。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 效果处理阶段：从连锁中获取目标玩家和伤害值，并执行伤害，给那个玩家造成对应的效果伤害。
function c1557341.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家和目标参数，分别赋给局部变量 p（玩家）和 d（伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 向目标玩家 p 造成 d 点伤害，伤害来源类型为效果（REASON_EFFECT）。
	Duel.Damage(p,d,REASON_EFFECT)
end
