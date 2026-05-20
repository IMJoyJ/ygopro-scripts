--氷水のトレモラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡送去墓地才能发动。从手卡把1只水属性怪兽特殊召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的水属性怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己的手卡·墓地把「冰水之透闪石精」以外的1只「冰水」怪兽特殊召唤。
function c55151012.initial_effect(c)
	-- ①：把这张卡从手卡送去墓地才能发动。从手卡把1只水属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55151012,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,55151012)
	e1:SetCost(c55151012.spcost1)
	e1:SetTarget(c55151012.sptg1)
	e1:SetOperation(c55151012.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的水属性怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己的手卡·墓地把「冰水之透闪石精」以外的1只「冰水」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55151012,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,55151013)
	-- 设置效果的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c55151012.spcon)
	e2:SetTarget(c55151012.sptg)
	e2:SetOperation(c55151012.spop)
	c:RegisterEffect(e2)
end
-- 效果1的发动代价：将手卡的这张卡送去墓地
function c55151012.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：手卡的水属性怪兽
function c55151012.spfilter1(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1的发动准备：检查怪兽区域空位以及手卡是否存在可特殊召唤的水属性怪兽
function c55151012.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在除自身以外满足过滤条件的水属性怪兽
		and Duel.IsExistingMatchingCard(c55151012.spfilter1,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 设置连锁处理中的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果1的效果处理：从手卡特殊召唤1只水属性怪兽
function c55151012.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的怪兽区域空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c55151012.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示的水属性怪兽因战斗或效果被破坏
function c55151012.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsAttribute(ATTRIBUTE_WATER) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果2的发动条件：自己场上表侧表示的水属性怪兽被破坏，且被破坏的卡中不包含墓地的这张卡自身
function c55151012.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c55151012.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤条件：「冰水之透闪石精」以外的「冰水」怪兽
function c55151012.spfilter(c,e,tp)
	return c:IsSetCard(0x16c) and not c:IsCode(55151012) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动准备：检查怪兽区域空位以及手卡·墓地是否存在可特殊召唤的「冰水」怪兽
function c55151012.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在除自身以外满足过滤条件的「冰水」怪兽
		and Duel.IsExistingMatchingCard(c55151012.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置连锁处理中的操作信息：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果2的效果处理：从手卡或墓地特殊召唤1只「冰水之透闪石精」以外的「冰水」怪兽
function c55151012.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的怪兽区域空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足过滤条件且不受王家之谷影响的「冰水」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c55151012.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
