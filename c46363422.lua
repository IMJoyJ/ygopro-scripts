--熟練の白魔導師
-- 效果：
-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。此外，把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「破坏之剑士」特殊召唤。
function c46363422.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 连锁发生时记录这张卡在怪兽区域存在，用于后续放置魔力指示物的判定
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c46363422.acop)
	c:RegisterEffect(e1)
	-- 把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「破坏之剑士」特殊召唤。
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
-- 连锁处理结束时，若该连锁是魔法卡的发动且这张卡在连锁发生时已在场上，则给这张卡放置1个魔力指示物
function c46363422.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 效果发动的代价：检查这张卡放置有3个魔力指示物且可以解放，然后将其解放
function c46363422.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 把这张卡作为代价解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选卡号为「破坏之剑士」且可以特殊召唤的卡
function c46363422.filter(c,e,tp)
	return c:IsCode(78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动对象检查：确认自己主要怪兽区有可用空格，且手卡·卡组·墓地存在可以特殊召唤的「破坏之剑士」
function c46363422.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区特殊召唤后仍有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己的手卡·卡组·墓地存在至少1只可以特殊召唤的「破坏之剑士」
		and Duel.IsExistingMatchingCard(c46363422.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置操作信息：预计从自己的手卡·卡组·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：若主要怪兽区没有空格则中止，否则让玩家从手卡·卡组·墓地选1只「破坏之剑士」以表侧表示特殊召唤
function c46363422.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的主要怪兽区没有可用空格则效果处理中止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组·墓地选1只不受王家长眠之谷影响且可以特殊召唤的「破坏之剑士」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c46363422.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 把选择的「破坏之剑士」在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
