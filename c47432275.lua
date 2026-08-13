--クリボン
-- 效果：
-- 这张卡成为对方怪兽的攻击对象的战斗伤害计算时，可以把那次战斗发生的对自己的战斗伤害变成0并让对方基本分回复攻击怪兽的攻击力的数值，这张卡回到手卡。
function c47432275.initial_effect(c)
	-- 这张卡成为对方怪兽的攻击对象的战斗伤害计算时，可以把那次战斗发生的对自己的战斗伤害变成0并让对方基本分回复攻击怪兽的攻击力的数值，这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47432275,0))  --"伤害变成0"
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c47432275.con)
	e1:SetTarget(c47432275.target)
	e1:SetOperation(c47432275.op)
	c:RegisterEffect(e1)
end
-- 效果的发动条件判断函数：确认本卡是对方怪兽的攻击对象，且己方在本次战斗中会承受战斗伤害，满足时效果才能发动。
function c47432275.con(e,tp,eg,ep,ev,re,r,rp)
	-- 条件表达式：当前攻击对象等于本卡，且己方战斗伤害大于0。
	return Duel.GetAttackTarget()==e:GetHandler() and Duel.GetBattleDamage(tp)>0
end
-- 效果发动时的target处理：先确认可以发动（chk==0返回true），然后取得攻击怪兽攻击力，将连锁对象玩家设为对方，参数设为攻击力，并登记回复LP的操作信息，为效果处理做准备。
function c47432275.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取攻击怪兽当前攻击力，用于后续对方回复基本分的数值。
	local val=Duel.GetAttacker():GetAttack()
	-- 将连锁的对象玩家设置为对方玩家，表示回复基本分的对象是对方。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的对象参数设置为攻击怪兽的攻击力数值，作为回复量。
	Duel.SetTargetParam(val)
	-- 登记操作信息：本效果包含回复LP（CATEGORY_RECOVER），目标玩家为对方，回复数值为攻击力。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,val)
end
-- 效果处理函数：为己方附加一个避免战斗伤害的永续效果，使本次战斗伤害变成0；然后按之前设定的对象玩家和参数回复对方LP；最后将本卡返回手牌。
function c47432275.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 可以把那次战斗发生的对自己的战斗伤害变成0并让对方基本分回复攻击怪兽的攻击力的数值，这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将避免战斗伤害的永续效果注册给玩家tp（己方），使其在本次伤害步骤内生效，防止己方受到那次战斗伤害。
	Duel.RegisterEffect(e1,tp)
	-- 从当前连锁信息中取出target阶段设定的对象玩家和参数，分别作为回复对象和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家（对方）回复参数数值的基本分，回复原因记为效果。
	Duel.Recover(p,d,REASON_EFFECT)
	-- 将本卡（缎带栗子）从场上返回其持有者的手牌。
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
