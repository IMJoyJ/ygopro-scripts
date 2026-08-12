--EMスカイ・ピューピル
-- 效果：
-- 「娱乐伙伴 天空徒弟」的①的效果1回合只能使用1次。
-- ①：让自己场上1只5星以上的「娱乐伙伴」怪兽回到持有者手卡才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡和对方怪兽进行战斗的场合，直到伤害步骤结束时那只怪兽的效果无效化。
-- ③：自己场上有其他的「娱乐伙伴」怪兽存在的场合，这张卡向对方怪兽攻击的伤害计算前才能发动。那只对方怪兽破坏。
function c122520.initial_effect(c)
	-- ①：让自己场上1只5星以上的「娱乐伙伴」怪兽回到持有者手卡才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(122520,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,122520)
	e1:SetCost(c122520.spcost)
	e1:SetTarget(c122520.sptg)
	e1:SetOperation(c122520.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的场合，直到伤害步骤结束时那只怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c122520.distg)
	c:RegisterEffect(e2)
	-- ③：自己场上有其他的「娱乐伙伴」怪兽存在的场合，这张卡向对方怪兽攻击的伤害计算前才能发动。那只对方怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(122520,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetCondition(c122520.descon)
	e3:SetTarget(c122520.destg)
	e3:SetOperation(c122520.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在满足条件的怪兽（5星以上、娱乐伙伴卡组、正面表示、可送入手卡）
function c122520.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:IsLevelAbove(5) and c:IsAbleToHandAsCost()
end
-- 效果发动时的费用处理函数，检查是否满足支付条件
function c122520.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽（5星以上、娱乐伙伴卡组、正面表示、可送入手卡）
	if chk==0 then return Duel.IsExistingMatchingCard(c122520.spcfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要送入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 选择满足条件的怪兽送入手卡
	local g=Duel.SelectMatchingCard(tp,c122520.spcfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽送入手卡作为费用
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 效果发动时的处理函数，用于判断是否可以发动效果
function c122520.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果发动时的处理函数，执行效果的处理
function c122520.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 用于判断是否为战斗对象的函数
function c122520.distg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
-- 过滤函数，用于判断场上是否存在其他娱乐伙伴怪兽
function c122520.descfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 效果发动时的条件判断函数，检查是否满足发动条件
function c122520.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在其他娱乐伙伴怪兽
	return Duel.IsExistingMatchingCard(c122520.descfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果发动时的处理函数，用于设置目标和操作信息
function c122520.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击对象
	local t=Duel.GetAttackTarget()
	-- 检查是否满足发动条件（攻击者为自身且存在攻击对象）
	if chk==0 then return Duel.GetAttacker()==e:GetHandler() and t~=nil end
	-- 设置当前处理的连锁对象为攻击对象
	Duel.SetTargetCard(t)
	-- 设置效果处理时的操作信息，指定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,t,1,0,0)
end
-- 效果发动时的处理函数，执行效果的处理
function c122520.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的处理对象
	local t=Duel.GetFirstTarget()
	if t:IsRelateToBattle() then
		-- 将目标怪兽破坏
		Duel.Destroy(t,REASON_EFFECT)
	end
end
