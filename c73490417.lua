--密林に潜む者
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①③的效果1回合各能使用1次。
-- ①：从自己墓地把1只光·暗属性怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：只要场地区域有2张卡存在，对方不能把这张卡作为效果的对象。
-- ③：这张卡被对方破坏的场合才能发动。自己的墓地·除外状态的最多2张场地魔法卡回到卡组。那之后，可以把最多有回去数量的对方场上的卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含特殊召唤限制、不能成为效果对象、手卡特殊召唤、被破坏时回收场地魔法并破坏对方卡片的效果。
function s.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ②：只要场地区域有2张卡存在，对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.dcon)
	-- 设置不能成为对方卡的效果的对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ①：从自己墓地把1只光·暗属性怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方破坏的场合才能发动。自己的墓地·除外状态的最多2张场地魔法卡回到卡组。那之后，可以把最多有回去数量的对方场上的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 限制此卡只能通过卡的效果进行特殊召唤。
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 检查场地区域是否存在2张卡的条件函数。
function s.dcon(e)
	-- 检查双方的场地区域合计是否存在至少2张卡。
	return Duel.IsExistingMatchingCard(nil,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,2,nil)
end
-- 过滤自己墓地中可以作为Cost除外的光·暗属性怪兽。
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 效果①的Cost处理函数，从自己墓地将1只光·暗属性怪兽除外。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的光·暗属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只光·暗属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动的Cost。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的Target处理函数，检查自身是否能特殊召唤并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息，表明此效果将特殊召唤1张自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的Operation处理函数，将此卡从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到发动效果的玩家场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果③的发动条件函数，检查此卡是否被对方破坏。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤墓地或除外状态中可以回到卡组的表侧表示场地魔法卡。
function s.tdfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsFaceup() and c:IsAbleToDeck()
end
-- 效果③的Target处理函数，检查是否存在可回到卡组的场地魔法并设置回收的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的墓地或除外状态中是否存在至少1张场地魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置连锁中的操作信息，表明此效果将使最多2张墓地或除外状态的卡回到卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果③的Operation处理函数，将场地魔法卡回到卡组，并根据回去的数量选择是否破坏对方场上的卡。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地或除外状态选择最多2张不受王家长眠之谷影响的场地魔法卡。
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,2,nil)
	if tg:GetCount()>0 then
		-- 将选中的卡送回持有者卡组并洗牌。
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		tg=tg:Filter(Card.IsLocation,nil,LOCATION_DECK)
		tg=tg-tg:Filter(Card.IsReason,nil,REASON_REDIRECT)
		-- 检查是否有卡成功回到卡组、对方场上是否有卡，并询问玩家是否发动后续的破坏效果。
		if #tg>0 and Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_ONFIELD,nil)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否要把对方场上的卡破坏？"
			-- 中断当前效果处理，使后续的破坏处理与回到卡组不视为同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 让玩家选择对方场上最多等同于回到卡组数量的卡。
			local dg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,#tg,nil)
			-- 显式地为选中的卡片播放被选为效果目标的动画效果。
			Duel.HintSelection(dg)
			-- 破坏选中的对方场上的卡。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
