--サイバネット・オプティマイズ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。把1只电子界族怪兽召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
-- ②：自己的「码语者」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c34010534.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。把1只电子界族怪兽召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34010534,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,34010534)
	e2:SetTarget(c34010534.sumtg)
	e2:SetOperation(c34010534.sumop)
	c:RegisterEffect(e2)
	-- ②：自己的「码语者」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c34010534.actcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选可以通常召唤的电子界族怪兽
function c34010534.sumfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsSummonable(true,nil)
end
-- 效果的发动时点处理，检查是否满足发动条件并设置操作信息
function c34010534.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌或场上是否存在至少1只可以通常召唤的电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34010534.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息为召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果的发动处理，选择并通常召唤一只电子界族怪兽，并设置后续不能特殊召唤非电子界族怪兽的效果
function c34010534.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的1只电子界族怪兽
	local g=Duel.SelectMatchingCard(tp,c34010534.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
	-- 创建并注册一个直到回合结束时禁止特殊召唤非电子界族怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34010534.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制非电子界族怪兽从额外卡组特殊召唤
function c34010534.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断目标怪兽是否为「码语者」怪兽
function c34010534.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x101) and c:IsControler(tp)
end
-- 判断是否为「码语者」怪兽参与战斗
function c34010534.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前被攻击怪兽
	local d=Duel.GetAttackTarget()
	return (a and c34010534.cfilter(a,tp)) or (d and c34010534.cfilter(d,tp))
end
