--魔族召喚師
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●把手卡或者墓地存在的1只恶魔族怪兽特殊召唤。这个效果1回合只能使用1次。这张卡从场上离开时，这个效果特殊召唤的恶魔族怪兽破坏。
function c94944637.initial_effect(c)
	-- 赋予该卡在场上·墓地当作通常怪兽使用，以及再度召唤成为效果怪兽的二重怪兽特性。
	aux.EnableDualAttribute(c)
	-- ●把手卡或者墓地存在的1只恶魔族怪兽特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(94944637,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果发动条件为该卡处于再度召唤的状态（二重状态）。
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c94944637.target)
	e1:SetOperation(c94944637.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，这个效果特殊召唤的恶魔族怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c94944637.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡或墓地的恶魔族怪兽，且可以被特殊召唤。
function c94944637.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与可行性检测函数。
function c94944637.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地以及对方的墓地是否存在至少1只满足条件的恶魔族怪兽。
		and Duel.IsExistingMatchingCard(c94944637.filter,tp,LOCATION_GRAVE+LOCATION_HAND,LOCATION_GRAVE,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息，表明此效果包含从手卡或墓地特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理的执行函数，用于特殊召唤恶魔族怪兽并建立卡片对象关联。
function c94944637.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无空余的怪兽区域，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地（受王家长眠之谷影响）选择1只满足条件的恶魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c94944637.filter),tp,LOCATION_GRAVE+LOCATION_HAND,LOCATION_GRAVE,1,1,nil,e,tp)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤，若特殊召唤失败则结束处理。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		if c:IsFaceup() and c:IsRelateToEffect(e) then c:SetCardTarget(tc) end
	end
end
-- 过滤条件：属于该卡（魔族召唤师）指向的卡片对象，且是恶魔族怪兽。
function c94944637.desfilter(c,rc)
	return rc:GetCardTarget():IsContains(c) and c:IsRace(RACE_FIEND)
end
-- 离场时破坏被该效果特殊召唤的怪兽的处理函数。
function c94944637.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCardTargetCount()>0 then
		-- 获取场上所有被该卡效果特殊召唤且仍存在于场上的恶魔族怪兽。
		local dg=Duel.GetMatchingGroup(c94944637.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
		-- 因效果将这些怪兽破坏。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
