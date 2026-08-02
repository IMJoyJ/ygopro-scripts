--熟練の黒魔術師
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「黑魔术师」特殊召唤。
function c73752131.initial_effect(c)
	-- 标记这张卡上记载了卡号为46986414（「黑魔术师」）的卡名。
	aux.AddCodeList(c,46986414)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- 每次自己或者对方把魔法卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 设置操作：在魔法卡发动时，给此卡添加一个正在处理该连锁的标记。
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c73752131.acop)
	c:RegisterEffect(e1)
	-- 把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「黑魔术师」特殊召唤。
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
c73752131.mentioned_counter={
	[0x1]=true,
}
-- 效果处理：连锁处理结束时，若该连锁是魔法卡的发动，且此卡在发动时已记录，则放置1个魔力指示物。
function c73752131.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 发动代价：检查这张卡是否有3个魔力指示物并可以被解放，将其解放。
function c73752131.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 把作为代价的这张卡解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡名为「黑魔术师」（46986414）且能够被特殊召唤的怪兽。
function c73752131.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果对象设定：检查场上是否有空余怪兽区域，以及手卡·卡组·墓地是否有「黑魔术师」。
function c73752131.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有空位（考虑到自身解放作为代价，大于-1即可）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡、卡组或墓地是否存在1只满足特殊召唤条件的「黑魔术师」。
		and Duel.IsExistingMatchingCard(c73752131.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置将卡组、手卡或墓地的卡特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从手卡、卡组或墓地选1只不受王家长眠之谷影响的「黑魔术师」特殊召唤。
function c73752131.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区域是否还有大于0的空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给己方发送提示信息：“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组或墓地中选择1只不受「王家长眠之谷」影响的「黑魔术师」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c73752131.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的「黑魔术师」表侧表示特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
