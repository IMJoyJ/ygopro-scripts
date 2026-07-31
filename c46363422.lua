--熟練の白魔導師
-- 效果：
-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。此外，把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「破坏之剑士」特殊召唤。
function c46363422.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- 创建效果，设置持续/场上效果类型，禁止无效化，触发时机为连锁发生时，作用范围为怪兽区域，操作为aux.chainreg函数。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在。
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 创建效果，设置持续/场上效果类型，触发时机为连锁处理结束时，作用范围为怪兽区域，操作为c46363422.acop函数。
-- c46363422.acop: 如果连锁中的卡片是魔法卡且激活，则给这张卡增加1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c46363422.acop)
	c:RegisterEffect(e1)
	-- 创建效果，设置描述（特殊召唤），效果分类为特殊召唤，类型为起动效果，作用范围为怪兽区域，代价为c46363422.spcost函数，目标选择为c46363422.sptg函数，操作为c46363422.spop函数。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46363422,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c46363422.spcost)
	e2:SetTarget(c46363422.sptg)
	e2:SetOperation(c46363422.spop)
	c:RegisterEffect(e2)
end
c46363422.mentioned_counter={
	[0x1]=true,
}
-- 如果连锁中的卡片是魔法卡且激活，并且这张卡有连锁标志位，则给这张卡增加1个魔力指示物。
function c46363422.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 检查代价是否为0，如果是，则返回当此卡的魔力指示物数量等于3且可以解放时为真；否则，解放此卡。
function c46363422.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 以REASON_COST原因解放目标卡片。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：如果卡片的代码是78193831（破坏之剑士）并且可以特殊召唤，则返回真。
function c46363422.filter(c,e,tp)
	return c:IsCode(78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查目标玩家的怪兽区域是否有空位，以及是否存在满足c46363422.filter条件的卡片。
function c46363422.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查目标玩家的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查是否存在满足过滤条件c46363422.filter的卡片。
		and Duel.IsExistingMatchingCard(c46363422.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置当前处理的连锁的操作信息，类别为特殊召唤，目标数量为1，目标玩家为tp，目标位置为手牌、卡组和墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 如果怪兽区域没有空位则返回。提示玩家选择要特殊召唤的卡片，选择满足过滤条件c46363422.filter（并受到王家长眠之谷影响）的卡片，然后特殊召唤选中的卡片。
function c46363422.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果怪兽区域没有空位则直接返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择满足过滤条件c46363422.filter（并受到王家长眠之谷影响）的卡片。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c46363422.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 特殊召唤选中的卡片。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
