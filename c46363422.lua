--熟練の白魔導師
-- 效果：
-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。此外，把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「破坏之剑士」特殊召唤。
function c46363422.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 此外，把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「破坏之剑士」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c46363422.acop)
	c:RegisterEffect(e1)
	-- 效果作用
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
-- 当有魔法卡发动时，若此卡在连锁中存在，则给此卡放置1个魔力指示物
function c46363422.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 支付解放费用：确认此卡拥有3个魔力指示物且可被解放
function c46363422.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 将此卡从场上解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数：检查目标是否为「破坏之剑士」且可特殊召唤
function c46363422.filter(c,e,tp)
	return c:IsCode(78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的条件：确认场上存在可用区域且手卡·卡组·墓地有「破坏之剑士」
function c46363422.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组·墓地是否存在满足条件的「破坏之剑士」
		and Duel.IsExistingMatchingCard(c46363422.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置操作信息：确定特殊召唤的目标为手卡·卡组·墓地中的任意一张「破坏之剑士」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行特殊召唤操作：选择并特殊召唤符合条件的「破坏之剑士」
function c46363422.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有可用区域则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择一张满足条件的「破坏之剑士」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c46363422.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「破坏之剑士」特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
