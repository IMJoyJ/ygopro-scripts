--舞い戻った死神
-- 效果：
-- 这个卡名在规则上也当作「永火」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地的怪兽以及除外的自己怪兽之中选1只「永火」怪兽特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「永火」怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。这张卡在自己场上盖放。
function c4599182.initial_effect(c)
	-- ①：从自己的手卡·墓地的怪兽以及除外的自己怪兽之中选1只「永火」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4599182)
	e1:SetTarget(c4599182.target)
	e1:SetOperation(c4599182.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「永火」怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,4599183)
	e2:SetCondition(c4599182.setcon)
	e2:SetTarget(c4599182.settg)
	e2:SetOperation(c4599182.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「永火」怪兽，包括手牌、墓地或除外区的怪兽，且可以被特殊召唤。
function c4599182.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or c:IsFaceup())
end
-- 效果处理时的判断条件，检查是否满足特殊召唤的条件，包括场上是否有空位和是否存在符合条件的怪兽。
function c4599182.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位可以用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌、墓地或除外区是否存在至少一张符合条件的「永火」怪兽。
		and Duel.IsExistingMatchingCard(c4599182.filter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张「永火」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 发动效果时的处理函数，检查是否有空位并选择要特殊召唤的怪兽。
function c4599182.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果场上没有空位则直接返回，不进行后续处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌、墓地或除外区中选择一张符合条件的「永火」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c4599182.filter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于判断是否满足盖放条件的过滤函数，检查怪兽是否为「永火」怪兽且因战斗或对方效果离开场上的情况。
function c4599182.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and bit.band(c:GetPreviousTypeOnField(),TYPE_MONSTER)~=0
		and c:IsPreviousSetCard(0xb) and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
-- 触发效果的条件函数，判断是否有符合条件的怪兽因战斗或对方效果离开场上。
function c4599182.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4599182.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 设置盖放效果的目标函数，检查该卡是否可以盖放。
function c4599182.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置连锁操作信息，表示将要盖放此卡。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 盖放效果的处理函数，检查卡是否有效并将其盖放。
function c4599182.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡盖放到场上。
		Duel.SSet(tp,c)
	end
end
