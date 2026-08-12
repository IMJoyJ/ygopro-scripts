--真帝王領域
-- 效果：
-- ①：只要自己的额外卡组没有卡存在并是只有自己场上才有上级召唤的怪兽存在，对方不能从额外卡组把怪兽特殊召唤。
-- ②：自己的上级召唤的怪兽的攻击力只在向对方怪兽攻击的伤害计算时上升800。
-- ③：1回合1次，自己主要阶段才能发动。自己手卡1只攻击力2800/守备力1000的怪兽的等级直到回合结束时下降2星。
function c84171830.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己的额外卡组没有卡存在并是只有自己场上才有上级召唤的怪兽存在，对方不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c84171830.discon)
	e2:SetTarget(c84171830.splimit)
	c:RegisterEffect(e2)
	-- ②：自己的上级召唤的怪兽的攻击力只在向对方怪兽攻击的伤害计算时上升800。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c84171830.atkcon)
	e3:SetTarget(c84171830.atktg)
	e3:SetValue(800)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己主要阶段才能发动。自己手卡1只攻击力2800/守备力1000的怪兽的等级直到回合结束时下降2星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(84171830,0))  --"等级下降"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c84171830.lvtg)
	e4:SetOperation(c84171830.lvop)
	c:RegisterEffect(e4)
end
-- 限制特殊召唤的怪兽范围为额外卡组的怪兽
function c84171830.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：上级召唤方式召唤的怪兽
function c84171830.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 判断是否满足“自己额外卡组没有卡且只有自己场上存在上级召唤的怪兽”的适用条件
function c84171830.discon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己额外卡组的卡片数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
		-- 检查自己场上是否存在上级召唤的怪兽
		and Duel.IsExistingMatchingCard(c84171830.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否不存在上级召唤的怪兽
		and not Duel.IsExistingMatchingCard(c84171830.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 判断是否满足“向对方怪兽攻击的伤害计算时”的适用条件
function c84171830.atkcon(e)
	-- 获取本次战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	local tp=e:GetHandlerPlayer()
	-- 检查当前是否为伤害计算阶段，且存在由对方控制的被攻击怪兽
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and d and d:IsControler(1-tp)
end
-- 过滤符合攻击力上升效果的对象怪兽
function c84171830.atktg(e,c)
	-- 检查怪兽是否为本次战斗的攻击怪兽，且该怪兽是上级召唤的怪兽
	return c==Duel.GetAttacker() and c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤条件：攻击力2800且守备力1000的怪兽
function c84171830.filter(c)
	return c:IsAttack(2800) and c:IsDefense(1000)
end
-- 等级下降效果的发动准备，检查手牌中是否存在符合条件的怪兽
function c84171830.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己手牌中是否存在至少1只攻击力2800/守备力1000的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84171830.filter,tp,LOCATION_HAND,0,1,nil) end
end
-- 等级下降效果的实际处理：选择手牌中1只符合条件的怪兽展示，使其等级直到回合结束时下降2星
function c84171830.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置选择卡片时的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(84171830,1))  --"选择要把等级下降的怪兽"
	-- 让玩家从手牌中选择1只攻击力2800/守备力1000的怪兽
	local g=Duel.SelectMatchingCard(tp,c84171830.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 向对方展示所选择的怪兽以进行确认
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		-- 等级直到回合结束时下降2星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffect(e1)
	end
end
