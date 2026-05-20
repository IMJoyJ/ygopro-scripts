--扇風機塊プロペライオン
-- 效果：
-- 「机块」怪兽1只
-- 这张卡在连接召唤的回合不能作为连接素材。
-- ①：这张卡可以直接攻击。
-- ②：1回合1次，这张卡是互相连接状态的场合，自己和对方的怪兽之间进行战斗的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时变成0。
-- ③：1回合1次，不在互相连接状态的这张卡在和对方怪兽进行战斗的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时变成0。
function c81769387.initial_effect(c)
	-- 设置连接召唤条件为「机块」怪兽1只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x14b),1,1)
	c:EnableReviveLimit()
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c81769387.lmlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- ②：1回合1次，这张卡是互相连接状态的场合，自己和对方的怪兽之间进行战斗的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81769387,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c81769387.atkcon1)
	e3:SetTarget(c81769387.atktg)
	e3:SetOperation(c81769387.atkop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，不在互相连接状态的这张卡在和对方怪兽进行战斗的伤害计算时才能发动。那只对方怪兽的攻击力只在那次伤害计算时变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(81769387,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c81769387.atkcon2)
	e4:SetTarget(c81769387.atktg)
	e4:SetOperation(c81769387.atkop)
	c:RegisterEffect(e4)
end
-- 限制自身在连接召唤的回合不能作为连接素材
function c81769387.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 判断自身处于互相连接状态，且自己和对方的怪兽之间进行战斗
function c81769387.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取被攻击怪兽
	local d=Duel.GetAttackTarget()
	return e:GetHandler():GetMutualLinkedGroupCount()>0 and d and a:GetControler()~=d:GetControler()
end
-- 判断进行战斗的对方怪兽是否存在且攻击力不为0
function c81769387.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方进行战斗的怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	if chk==0 then return tc and not tc:IsAttack(0) end
end
-- 使进行战斗的对方怪兽的攻击力只在伤害计算时变成0
function c81769387.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方进行战斗的怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	if tc and tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 那只对方怪兽的攻击力只在那次伤害计算时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
	end
end
-- 判断自身不在互相连接状态，且和对方怪兽进行战斗
function c81769387.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:GetMutualLinkedGroupCount()==0 and bc and bc:IsControler(1-tp)
end
