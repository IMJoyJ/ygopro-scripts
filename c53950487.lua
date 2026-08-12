--B・F－突撃のヴォウジェ
-- 效果：
-- 昆虫族调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡向持有这张卡的攻击力以上的攻击力的对方怪兽攻击的伤害计算时才能发动1次。那只对方怪兽的攻击力只在伤害计算时变成一半。
-- ②：这张卡给与对方战斗伤害时才能发动。给与对方为自己场上的「蜂军」怪兽数量×200伤害。
function c53950487.initial_effect(c)
	-- 添加同调召唤手续：昆虫族调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡向持有这张卡的攻击力以上的攻击力的对方怪兽攻击的伤害计算时才能发动1次。那只对方怪兽的攻击力只在伤害计算时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c53950487.atkcon)
	e1:SetCost(c53950487.atkcost)
	e1:SetOperation(c53950487.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡给与对方战斗伤害时才能发动。给与对方为自己场上的「蜂军」怪兽数量×200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,53950487)
	e2:SetCondition(c53950487.damcon)
	e2:SetTarget(c53950487.damtg)
	e2:SetOperation(c53950487.damop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c53950487.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	-- 判定此卡是否为攻击怪兽，且对方怪兽表侧表示存在、属于对方，且其攻击力在此卡攻击力以上
	return c==Duel.GetAttacker() and tc and tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsAttackAbove(c:GetAttack())
end
-- 效果①的发动代价判定与处理函数（限制每场战斗只能发动1次）
function c53950487.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(53950487)==0 end
	c:RegisterFlagEffect(53950487,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果①的效果处理函数
function c53950487.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if c:IsRelateToBattle() and c:IsFaceup() and tc:IsRelateToBattle() and tc:IsFaceup() then
		-- 那只对方怪兽的攻击力只在伤害计算时变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动条件判定函数（给与对方战斗伤害时）
function c53950487.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤自己场上表侧表示的「蜂军」怪兽
function c53950487.damfilter(c)
	return c:IsSetCard(0x12f) and c:IsFaceup()
end
-- 效果②的发动目标判定与效果声明函数
function c53950487.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「蜂军」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c53950487.damfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 计算自己场上表侧表示的「蜂军」怪兽数量乘以200的伤害数值
	local val=Duel.GetMatchingGroupCount(c53950487.damfilter,tp,LOCATION_MZONE,0,nil)*200
	-- 设置效果目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果目标参数为计算出的伤害数值
	Duel.SetTargetParam(val)
	-- 声明该连锁的操作信息为给与对方对应数值的效果伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
-- 效果②的效果处理函数
function c53950487.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算当前自己场上表侧表示的「蜂军」怪兽数量乘以200的伤害数值
	local val=Duel.GetMatchingGroupCount(c53950487.damfilter,tp,LOCATION_MZONE,0,nil)*200
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,val,REASON_EFFECT)
end
