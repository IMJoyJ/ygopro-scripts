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
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。把1只电子界族怪兽召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
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
-- 该过滤函数用于选择可被召唤的电子界族怪兽：必须是电子界族，并且满足当前通常召唤条件（不检查召唤次数限制）。
function c34010534.sumfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsSummonable(true,nil)
end
-- 效果发动前的合法性检查与操作信息登记：若我方手牌·主要怪兽区存在符合召唤条件的电子界族怪兽，则允许发动，并向系统登记本效果将进行‘召唤’操作。
function c34010534.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时进行合法性检查，确认我方手牌·主要怪兽区至少存在1只可由本效果通常召唤的电子界族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c34010534.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 将本次连锁处理的操作信息设为‘召唤’1只怪兽，以便其他卡/效果正确响应这次召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理时：让玩家从手牌·主要怪兽区选择1只符合条件的电子界族怪兽进行通常召唤；召唤成功后，给发动方附加‘直到回合结束时不能从额外卡组特殊召唤非电子界族怪兽’的限制效果。
function c34010534.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示‘请选择要召唤的卡’的选择提示，引导玩家选择要通常召唤的电子界族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌·主要怪兽区中筛选并选择1只满足条件的电子界族怪兽作为本次通常召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c34010534.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 按通常召唤规则（忽略每回合的召唤次数限制）将所选电子界族怪兽表侧攻击表示通常召唤上场（仍需满足该怪兽自身的祭品等召唤条件）。
		Duel.Summon(tp,tc,true,nil)
	end
	-- 这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。②：自己的「码语者」怪兽进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34010534.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该‘非电子界族不能从额外卡组特殊召唤’的限制效果注册到决斗环境中，从当前回合开始持续到结束阶段，仅对发动方适用。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判定函数：若怪兽不是电子界族且位于额外卡组，则不能进行特殊召唤。
function c34010534.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_EXTRA)
end
-- 判定一张卡是否为我方表侧表示的「码语者」系列怪兽（系列编号0x101），用于②效果的条件检查。
function c34010534.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x101) and c:IsControler(tp)
end
-- ②效果的发动/适用条件：当攻击怪兽或攻击对象中存在我方表侧表示的「码语者」怪兽时，此效果适用。
function c34010534.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前战斗阶段进行攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗阶段被攻击的怪兽；如果是直接攻击，则为nil。
	local d=Duel.GetAttackTarget()
	return (a and c34010534.cfilter(a,tp)) or (d and c34010534.cfilter(d,tp))
end
