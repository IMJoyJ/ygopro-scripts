--蛇神ゲー
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：自己场上的怪兽被对方的攻击·效果破坏的场合，把基本分支付一半才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡不会成为效果的对象。
-- ③：这张卡向对方怪兽攻击的伤害步骤内，那只怪兽的效果无效化，攻击力变成原本攻击力的一半。
-- ④：这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力变成和场上的怪兽的最高原本攻击力相同。
function c82103466.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：自己场上的怪兽被对方的攻击·效果破坏的场合，把基本分支付一半才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82103466,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c82103466.spcon)
	e1:SetCost(c82103466.spcost)
	e1:SetTarget(c82103466.sptg)
	e1:SetOperation(c82103466.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡不会成为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡向对方怪兽攻击的伤害步骤内，那只怪兽的效果无效化，攻击力变成原本攻击力的一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c82103466.adcon)
	e3:SetTarget(c82103466.adtg)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_SET_ATTACK_FINAL)
	e5:SetValue(c82103466.atkval)
	c:RegisterEffect(e5)
	-- ④：这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力变成和场上的怪兽的最高原本攻击力相同。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e6:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e6:SetCondition(c82103466.atkcon)
	e6:SetTarget(c82103466.atktg)
	e6:SetOperation(c82103466.atkop)
	c:RegisterEffect(e6)
end
-- 过滤函数：筛选自己场上被对方的攻击或效果破坏的怪兽
function c82103466.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		-- 判断怪兽是否因对方怪兽的攻击而被破坏
		and ((c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp))
		or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
end
-- 特殊召唤效果的发动条件：检查是否有满足条件的怪兽被破坏
function c82103466.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c82103466.cfilter,1,nil,tp)
end
-- 特殊召唤效果的发动代价：支付一半基本分
function c82103466.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让玩家支付当前基本分一半的数值（向下取整）
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 特殊召唤效果的发动目标：检查怪兽区域是否有空位，且自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c82103466.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，确认自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置特殊召唤的操作信息，表示将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤，并完成正规召唤程序
function c82103466.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试无视召唤条件将自身以表侧表示特殊召唤，并判断是否特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 效果无效及攻击力减半效果的适用条件：自身向对方怪兽攻击的伤害步骤内
function c82103466.adcon(e)
	local c=e:GetHandler()
	-- 判断自身是否为攻击怪兽，且存在战斗对象
	return Duel.GetAttacker()==c and c:GetBattleTarget()
		-- 判断当前阶段是否为伤害步骤或伤害计算阶段
		and (Duel.GetCurrentPhase()==PHASE_DAMAGE or Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL)
end
-- 效果无效及攻击力减半效果的影响对象：自身的战斗对象
function c82103466.adtg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
-- 计算攻击力数值：返回目标怪兽原本攻击力一半的数值（向上取整）
function c82103466.atkval(e,c)
	return math.ceil(c:GetBaseAttack()/2)
end
-- 攻击力改变效果的发动条件：自身进行战斗
function c82103466.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否为攻击怪兽或被攻击怪兽
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
-- 攻击力改变效果的发动目标：检查场上是否存在其他表侧表示怪兽，并确认自身攻击力是否不等于场上怪兽的最高原本攻击力
function c82103466.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 获取场上除自身以外的所有表侧表示怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c)
		if g:GetCount()==0 then return false end
		local g1,atk=g:GetMaxGroup(Card.GetBaseAttack)
		return not c:IsAttack(atk)
	end
end
-- 攻击力改变效果的处理：获取场上除自身以外的怪兽的最高原本攻击力，并将自身的攻击力变成该数值
function c82103466.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上除自身以外的所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	if g:GetCount()==0 then return end
	local g1,atk=g:GetMaxGroup(Card.GetBaseAttack)
	if c:IsRelateToEffect(e) and c:IsFaceup() and atk>0 then
		-- 这张卡的攻击力变成和场上的怪兽的最高原本攻击力相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
	end
end
