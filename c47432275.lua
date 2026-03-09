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
-- 当此卡成为对方怪兽攻击对象且自己受到战斗伤害时才能发动
function c47432275.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否攻击此卡且自己在本次战斗中受到伤害
	return Duel.GetAttackTarget()==e:GetHandler() and Duel.GetBattleDamage(tp)>0
end
-- 设置效果发动时的目标玩家和参数
function c47432275.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取攻击怪兽的攻击力数值
	local val=Duel.GetAttacker():GetAttack()
	-- 设置连锁效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为攻击怪兽的攻击力
	Duel.SetTargetParam(val)
	-- 设置连锁效果的操作信息为对方回复对应攻击力数值的生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,val)
end
-- 处理效果发动时的具体操作
function c47432275.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使对方基本分回复攻击怪兽的攻击力数值，然后将此卡送回手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将避免战斗伤害的效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
	-- 获取连锁中目标玩家和目标参数的值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应数值的生命值
	Duel.Recover(p,d,REASON_EFFECT)
	-- 将此卡送回手卡
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
