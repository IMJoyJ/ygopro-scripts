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
	-- 在连锁发生时，注册该卡在场上存在的标记，用于后续检测魔法卡发动是否成功
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c46363422.acop)
	c:RegisterEffect(e1)
	-- 此外，把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「破坏之剑士」特殊召唤。
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
-- 在连锁处理结束时，若发动了魔法卡且该卡在连锁发动时在场，则给该卡放置1个魔力指示物
function c46363422.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 检查自身是否有3个魔力指示物且可以解放，并作为发动代价将自身解放
function c46363422.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤手卡、卡组、墓地中可以特殊召唤的「破坏之剑士」
function c46363422.filter(c,e,tp)
	return c:IsCode(78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位以及是否存在可特殊召唤的「破坏之剑士」
function c46363422.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（由于自身作为代价解放，可用格子数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己的手卡、卡组、墓地是否存在至少1只满足特殊召唤条件的「破坏之剑士」
		and Duel.IsExistingMatchingCard(c46363422.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示从手卡、卡组、墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤效果的处理，从手卡、卡组、墓地选择1只「破坏之剑士」特殊召唤
function c46363422.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤王家长眠之谷的影响，让玩家从自己的手卡、卡组、墓地选择1只「破坏之剑士」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c46363422.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
