--流星連打－シロクロイド
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：5次以上攻击宣言过的回合的战斗阶段才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡进行战斗的伤害步骤内，这张卡的攻击力上升这个回合由回合玩家攻击宣言的次数×1000。
function c99748883.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：5次以上攻击宣言过的回合的战斗阶段才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99748883,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_BATTLE_END)
	e1:SetCountLimit(1,99748883)
	e1:SetCondition(c99748883.spcon)
	e1:SetTarget(c99748883.sptg)
	e1:SetOperation(c99748883.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的伤害步骤内，这张卡的攻击力上升这个回合由回合玩家攻击宣言的次数×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c99748883.atkcon)
	e2:SetValue(c99748883.atkval)
	c:RegisterEffect(e2)
	if not c99748883.global_check then
		c99748883.global_check=true
		-- 5次以上攻击宣言过的回合；这个回合由回合玩家攻击宣言的次数。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c99748883.checkop)
		-- 将全局攻击宣言监听效果ge1注册到全局环境，使所有玩家每次攻击宣言时都能触发checkop，用于累计本回合攻击宣言次数。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时的处理函数：每当任意玩家进行攻击宣言，就为攻击怪兽的控制者记录一次攻击宣言次数。该函数作为全局持续效果的操作用来支持①和②的攻击宣言计数。
function c99748883.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为攻击怪兽的控制者增加1个99748883计数标志，表示该玩家本回合进行了一次攻击宣言；该标志在结束阶段重置。
	Duel.RegisterFlagEffect(Duel.GetAttacker():GetControler(),99748883,RESET_PHASE+PHASE_END,0,1)
end
-- ①效果的特殊召唤条件判定函数：判断当前是否处于战斗阶段（从战斗阶段开始到战斗阶段结束），并且本回合双方玩家累计攻击宣言次数达到5次以上。
function c99748883.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否处于战斗阶段（PHASE_BATTLE_START到PHASE_BATTLE之间）。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
		-- 检查玩家0和玩家1的99748883标志数量之和是否≥5，即本回合全场攻击宣言次数是否达到5次以上。
		and (Duel.GetFlagEffect(0,99748883)+Duel.GetFlagEffect(1,99748883))>=5
end
-- ①效果的发动目标判定函数：在发动时检查自己主要怪兽区是否有空位，且手牌中的这张卡能否被特殊召唤；若可以，则允许发动并设置特殊召唤的操作信息。
function c99748883.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己主要怪兽区是否存在可用空格，作为特殊召唤的发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果处理的信息为特殊召唤：将这张卡从手牌特殊召唤到场上（对象明确为此卡，数量1，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：效果结算时，如果此卡仍与效果关联，则将其从手牌特殊召唤到场上。
function c99748883.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到其控制者的主要怪兽区（无视苏生限制的通常特殊召唤处理）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的永续攻击力上升的条件判定函数：判断当前是否为伤害步骤（PHASE_DAMAGE或PHASE_DAMAGE_CAL），并且这张卡是攻击怪兽或攻击对象（正在进行战斗）。
function c99748883.atkcon(e)
	-- 获取当前阶段，用于判断是否处于伤害步骤或伤害计算时。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断这张卡是否参与当前战斗：它作为攻击怪兽，或作为被攻击的目标存在。
		and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
-- ②效果的攻击力上升值计算函数：根据当前回合玩家本回合的攻击宣言次数，决定攻击力上升量。
function c99748883.atkval(e,c,tp)
	-- 返回当前回合玩家本回合攻击宣言次数乘以1000，作为这张卡在伤害步骤内的攻击力上升值。
	return Duel.GetFlagEffect(Duel.GetTurnPlayer(),99748883)*1000
end
