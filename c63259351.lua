--奇跡のジュラシック・エッグ
-- 效果：
-- ①：场上的表侧表示的这张卡不能除外。
-- ②：只要这张卡在怪兽区域存在，每次恐龙族怪兽被送去自己墓地，给这张卡放置2个指示物。
-- ③：把这张卡解放才能发动。把持有这张卡放置的指示物数量以下的等级的1只恐龙族怪兽从卡组特殊召唤。
function c63259351.initial_effect(c)
	c:EnableCounterPermit(0x14)
	-- ①：场上的表侧表示的这张卡不能除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次恐龙族怪兽被送去自己墓地，给这张卡放置2个指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c63259351.ctop)
	c:RegisterEffect(e2)
	-- ③：把这张卡解放才能发动。把持有这张卡放置的指示物数量以下的等级的1只恐龙族怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(63259351,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c63259351.spcost)
	e3:SetTarget(c63259351.sptg)
	e3:SetOperation(c63259351.spop)
	c:RegisterEffect(e3)
end
-- 过滤属于自己且是恐龙族的怪兽
function c63259351.ctfilter(c,tp)
	return c:IsControler(tp) and c:IsRace(RACE_DINOSAUR)
end
-- 每次有恐龙族怪兽送去自己墓地，给这张卡放置2个指示物
function c63259351.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c63259351.ctfilter,1,nil,tp) then
		e:GetHandler():AddCounter(0x14,2)
	end
end
-- 起动效果的Cost处理：检查是否能解放，记录解放前的指示物数量，并解放自身
function c63259351.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	e:SetLabel(e:GetHandler():GetCounter(0x14))
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中等级在指定数值以下、且可以特殊召唤的恐龙族怪兽
function c63259351.spfilter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 起动效果的Target处理：检查怪兽区域空位以及卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c63259351.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在解放这张卡后，自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在等级在当前指示物数量以下、且可以特殊召唤的恐龙族怪兽
		and Duel.IsExistingMatchingCard(c63259351.spfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler():GetCounter(0x14),e,tp) end
	-- 设置特殊召唤的操作信息，表示从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 起动效果的Operation处理：从卡组选择1只等级在解放前指示物数量以下的恐龙族怪兽特殊召唤
function c63259351.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只等级在解放前指示物数量以下的恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c63259351.spfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel(),e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
