--熾天蝶
-- 效果：
-- 卡名不同的怪兽2只以上
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡连接召唤成功的场合发动。作为这张卡的连接素材的昆虫族怪兽数量的指示物给这张卡放置。
-- ②：这张卡的攻击力上升这张卡的指示物数量×200。
-- ③：把这张卡1个指示物取除才能发动。从自己墓地选1只4星以下的昆虫族怪兽守备表示特殊召唤。这个效果在对方回合也能发动。
function c91140491.initial_effect(c)
	c:EnableCounterPermit(0x53)
	-- 设置连接召唤的手续，需要2只以上的怪兽，且素材需要满足lcheck过滤条件（卡名不同）。
	aux.AddLinkProcedure(c,nil,2,nil,c91140491.lcheck)
	c:EnableReviveLimit()
	-- 作为这张卡的连接素材的昆虫族怪兽数量
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c91140491.matcheck)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤成功的场合发动。作为这张卡的连接素材的昆虫族怪兽数量的指示物给这张卡放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91140491,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetLabelObject(e1)
	e2:SetCountLimit(1,91140491)
	e2:SetCondition(c91140491.ctcon)
	e2:SetTarget(c91140491.cttg)
	e2:SetOperation(c91140491.ctop)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击力上升这张卡的指示物数量×200。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c91140491.atkval)
	c:RegisterEffect(e3)
	-- ③：把这张卡1个指示物取除才能发动。从自己墓地选1只4星以下的昆虫族怪兽守备表示特殊召唤。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,91140491)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetCost(c91140491.spcost)
	e4:SetTarget(c91140491.sptg)
	e4:SetOperation(c91140491.spop)
	c:RegisterEffect(e4)
end
-- 过滤连接素材，检查素材怪兽的卡名是否各不相同。
function c91140491.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 过滤昆虫族怪兽。
function c91140491.matfilter(c)
	return c:IsLinkRace(RACE_INSECT)
end
-- 检查并记录作为连接素材的昆虫族怪兽数量。
function c91140491.matcheck(e,c)
	local ct=c:GetMaterial():FilterCount(c91140491.matfilter,nil)
	e:SetLabel(ct)
end
-- 检查这张卡是否是通过连接召唤特殊召唤的。
function c91140491.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 放置指示物效果的发动准备，设置放置指示物的操作信息。
function c91140491.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabelObject():GetLabel()
	-- 设置当前连锁的操作信息为放置对应数量的指示物（0x53）。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x53)
end
-- 放置指示物效果的实际处理，给这张卡放置对应数量的指示物。
function c91140491.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x53,ct)
	end
end
-- 计算并返回这张卡因自身指示物数量而上升的攻击力数值。
function c91140491.atkval(e,c)
	return c:GetCounter(0x53)*200
end
-- 特殊召唤效果的代价：取除这张卡的1个指示物。
function c91140491.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x53,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x53,1,REASON_COST)
end
-- 过滤自己墓地中可以守备表示特殊召唤的4星以下的昆虫族怪兽。
function c91140491.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位及是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息。
function c91140491.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的昆虫族怪兽。
		and Duel.IsExistingMatchingCard(c91140491.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤效果的实际处理，从自己墓地选择1只满足条件的昆虫族怪兽守备表示特殊召唤。
function c91140491.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件且不受王家长眠之谷影响的昆虫族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c91140491.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
