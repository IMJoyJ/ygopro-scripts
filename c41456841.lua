--究極変異態・インセクト女王
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：场上有其他的昆虫族怪兽存在的场合，自己场上的昆虫族怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：这张卡攻击的伤害步骤结束时，把自己场上1只怪兽解放才能发动。这张卡向对方怪兽可以继续攻击。
-- ③：自己·对方的结束阶段才能发动。在自己场上把1只「昆虫怪兽衍生物」（昆虫族·地·1星·攻/守100）特殊召唤。
function c41456841.initial_effect(c)
	-- ①：场上有其他的昆虫族怪兽存在的场合，自己场上的昆虫族怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c41456841.splimit)
	c:RegisterEffect(e1)
	-- ①：场上有其他的昆虫族怪兽存在的场合，自己场上的昆虫族怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c41456841.indcon)
	-- 设置效果目标为场上的昆虫族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT))
	-- 设置效果值为不会被对方效果破坏的过滤函数
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ①：场上有其他的昆虫族怪兽存在的场合，自己场上的昆虫族怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c41456841.indcon)
	-- 设置效果目标为场上的昆虫族怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT))
	-- 设置效果值为不会成为对方效果对象的过滤函数
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：这张卡攻击的伤害步骤结束时，把自己场上1只怪兽解放才能发动。这张卡向对方怪兽可以继续攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41456841,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(c41456841.atcon)
	e4:SetCost(c41456841.atcost)
	e4:SetOperation(c41456841.atop)
	c:RegisterEffect(e4)
	-- ③：自己·对方的结束阶段才能发动。在自己场上把1只「昆虫怪兽衍生物」（昆虫族·地·1星·攻/守100）特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(41456841,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetTarget(c41456841.sptg)
	e5:SetOperation(c41456841.spop)
	c:RegisterEffect(e5)
end
-- 特殊召唤条件：只能通过包含动作效果的卡来特殊召唤
function c41456841.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 过滤函数：判断是否为场上正面表示的昆虫族怪兽
function c41456841.indfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 条件函数：判断场上是否存在其他昆虫族怪兽
function c41456841.indcon(e)
	-- 检查场上是否存在至少1张满足indfilter条件的卡
	return Duel.IsExistingMatchingCard(c41456841.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- 条件函数：判断此卡是否为攻击怪兽且可连锁攻击
function c41456841.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否为攻击怪兽且可连锁攻击
	return Duel.GetAttacker()==c and c:IsChainAttackable(0,true)
end
-- 费用函数：支付1只怪兽解放的费用
function c41456841.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放至少1张满足条件的卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) end
	-- 选择1张满足条件的卡进行解放
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,e:GetHandler())
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 效果函数：使攻击卡可以再进行1次攻击
function c41456841.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	-- 使攻击卡可以再进行1次攻击
	Duel.ChainAttack()
	-- 效果函数：此卡不能直接攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	c:RegisterEffect(e1)
end
-- 效果函数：判断是否可以特殊召唤衍生物
function c41456841.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,91512836,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 设置操作信息为召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果函数：执行特殊召唤衍生物
function c41456841.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断是否可以特殊召唤衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,91512836,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	-- 创建衍生物
	local token=Duel.CreateToken(tp,41456842)
	-- 将衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
