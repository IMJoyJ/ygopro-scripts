--雲魔物－タービュランス
-- 效果：
-- 这张卡不会被战斗破坏。这张卡在场上表侧守备表示存在的场合，这张卡破坏。这张卡召唤成功时，场上的名字带有「云魔物」的怪兽数量的雾指示物给这张卡放置。此外，可以通过把这张卡放置的1个雾指示物取除，从自己卡组或者双方墓地选1只「云魔物-小烟球」特殊召唤。
function c16197610.initial_effect(c)
	-- 这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡在场上表侧守备表示存在的场合，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c16197610.sdcon)
	c:RegisterEffect(e2)
	-- 这张卡召唤成功时，场上的名字带有「云魔物」的怪兽数量的雾指示物给这张卡放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16197610,0))  --"放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c16197610.addc)
	c:RegisterEffect(e3)
	-- 此外，可以通过把这张卡放置的1个雾指示物取除，从自己卡组或者双方墓地选1只「云魔物-小烟球」特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(16197610,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c16197610.spcost)
	e4:SetTarget(c16197610.sptg)
	e4:SetOperation(c16197610.spop)
	c:RegisterEffect(e4)
end
c16197610.mentioned_counter={
	[0x1019]=true,
}
-- 自我破坏的条件判断：这张卡在场上表侧守备表示存在时返回真。
function c16197610.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 过滤函数：筛选场上表侧表示的名字带有「云魔物」的怪兽。
function c16197610.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18)
end
-- 召唤成功时的必发处理：这张卡仍与效果关联时，统计场上「云魔物」怪兽数量并给这张卡放置那个数量的雾指示物。
function c16197610.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 统计双方场上表侧表示的名字带有「云魔物」的怪兽的数量。
		local ct=Duel.GetMatchingGroupCount(c16197610.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		e:GetHandler():AddCounter(0x1019,ct)
	end
end
-- 代价：检查并取除这张卡放置的1个雾指示物作为发动代价。
function c16197610.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1019,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1019,1,REASON_COST)
end
-- 过滤函数：筛选「云魔物-小烟球」且可以特殊召唤的卡。
function c16197610.spfilter(c,e,tp)
	return c:IsCode(80825553) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对象判定：确认自己主要怪兽区有空位，且自己卡组或双方墓地存在可以特殊召唤的「云魔物-小烟球」。
function c16197610.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组或双方墓地是否存在至少1只可以特殊召唤的「云魔物-小烟球」。
		and Duel.IsExistingMatchingCard(c16197610.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 设置操作信息：本次连锁处理预计从自己卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：自己主要怪兽区没有空位则中断，否则从自己卡组或双方墓地选1只「云魔物-小烟球」以表侧表示特殊召唤。
function c16197610.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有可用空位则中断处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组或双方墓地选择1只不受王家长眠之谷影响且可以特殊召唤的「云魔物-小烟球」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16197610.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的「云魔物-小烟球」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
