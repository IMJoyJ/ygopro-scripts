--熟練の黒魔術師
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「黑魔术师」特殊召唤。
function c73752131.initial_effect(c)
	-- 注册卡片记有「黑魔术师」的卡名信息
	aux.AddCodeList(c,46986414)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 在连锁发生时，标记这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c73752131.acop)
	c:RegisterEffect(e1)
	-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「黑魔术师」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73752131,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c73752131.spcost)
	e2:SetTarget(c73752131.sptg)
	e2:SetOperation(c73752131.spop)
	c:RegisterEffect(e2)
end
-- 魔法卡发动连锁处理完毕时，若这张卡在发动时已在场，则给这张卡放置1个魔力指示物
function c73752131.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 检查并执行发动代价：自身有3个魔力指示物且可以被解放，发动时将自身解放
function c73752131.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡名为「黑魔术师」且可以被特殊召唤
function c73752131.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查怪兽区域是否有空位，以及手卡、卡组、墓地是否存在可以特殊召唤的「黑魔术师」，并设置特殊召唤的操作信息
function c73752131.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用位置（因为自身作为代价被解放，所以可用位置数需要大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己的手卡、卡组、墓地（0x13）是否存在至少1张满足条件的「黑魔术师」
		and Duel.IsExistingMatchingCard(c73752131.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡、卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：若怪兽区域有空位，则让玩家从手卡、卡组、墓地选择1只「黑魔术师」特殊召唤
function c73752131.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若没有则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并选择1张不受「王家之谷」影响的、位于手卡、卡组或墓地的「黑魔术师」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c73752131.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
