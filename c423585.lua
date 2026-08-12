--召喚僧サモンプリースト
-- 效果：
-- ①：这张卡召唤·反转召唤的场合发动。这张卡变成守备表示。
-- ②：只要这张卡在怪兽区域存在，这张卡不能解放。
-- ③：1回合1次，从手卡丢弃1张魔法卡才能发动。从卡组把1只4星怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c423585.initial_effect(c)
	-- ①：这张卡召唤·反转召唤的场合发动。这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(423585,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c423585.potg)
	e1:SetOperation(c423585.poop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ③：1回合1次，从手卡丢弃1张魔法卡才能发动。从卡组把1只4星怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(423585,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c423585.spcost)
	e3:SetTarget(c423585.sptg)
	e3:SetOperation(c423585.spop)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，这张卡不能解放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_UNRELEASABLE_SUM)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e5)
end
-- 设置连锁操作信息为改变表示形式
function c423585.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为改变表示形式，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身变为守备表示
function c423585.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 过滤函数：判断手卡中是否存在可丢弃的魔法卡
function c423585.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果处理：丢弃1张手卡中的魔法卡作为代价
function c423585.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c423585.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1张满足条件的魔法卡
	Duel.DiscardHand(tp,c423585.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断卡组中是否存在可特殊召唤的4星怪兽
function c423585.filter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁操作信息为特殊召唤，检查是否有足够的召唤位置和满足条件的怪兽
function c423585.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查召唤位置是否足够
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c423585.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤，目标为卡组中的一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只4星怪兽特殊召唤，并使其本回合不能攻击
function c423585.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c423585.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 给特殊召唤的怪兽添加不能攻击的效果，持续到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
