--雲魔物－タービュランス
-- 效果：
-- 这张卡不会被战斗破坏。这张卡在场上表侧守备表示存在的场合，这张卡破坏。这张卡召唤成功时，场上的名字带有「云魔物」的怪兽数量的雾指示物给这张卡放置。此外，可以通过把这张卡放置的1个雾指示物取除，从自己卡组或者双方墓地选1只「云魔物-小烟球」特殊召唤。
function c16197610.initial_effect(c)
	-- 这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡在场上表侧守备表示存在的场合，这张卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c16197610.sdcon)
	c:RegisterEffect(e2)
	-- 这张卡召唤成功时，场上的名字带有「云魔物」的怪兽数量的雾指示物给这张卡放置
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16197610,0))  --"放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c16197610.addc)
	c:RegisterEffect(e3)
	-- 此外，可以通过把这张卡放置的1个雾指示物取除，从自己卡组或者双方墓地选1只「云魔物-小烟球」特殊召唤
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
-- 当此卡为表侧守备表示时触发
function c16197610.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 过滤场上表侧表示的云魔物族怪兽
function c16197610.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18)
end
-- 统计场上云魔物族怪兽数量并放置等量的雾指示物
function c16197610.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 获取场上云魔物族怪兽数量
		local ct=Duel.GetMatchingGroupCount(c16197610.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		e:GetHandler():AddCounter(0x1019,ct)
	end
end
-- 支付1个雾指示物作为cost
function c16197610.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1019,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1019,1,REASON_COST)
end
-- 过滤云魔物-小烟球
function c16197610.spfilter(c,e,tp)
	return c:IsCode(80825553) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件
function c16197610.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断召唤者场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组或墓地是否存在云魔物-小烟球
		and Duel.IsExistingMatchingCard(c16197610.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行特殊召唤操作
function c16197610.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断召唤者场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只云魔物-小烟球
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16197610.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
