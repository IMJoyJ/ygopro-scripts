--紫炎の道場
-- 效果：
-- ①：每次「六武众」怪兽召唤·特殊召唤，给这张卡放置1个武士道指示物。
-- ②：把有武士道指示物放置的这张卡送去墓地才能发动。把持有这张卡放置的武士道指示物数量以下的等级的1只「六武众」效果怪兽或者「紫炎」效果怪兽从卡组特殊召唤。
function c47436247.initial_effect(c)
	c:EnableCounterPermit(0x3)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次「六武众」怪兽召唤·特殊召唤，给这张卡放置1个武士道指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c47436247.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：把有武士道指示物放置的这张卡送去墓地才能发动。把持有这张卡放置的武士道指示物数量以下的等级的1只「六武众」效果怪兽或者「紫炎」效果怪兽从卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(47436247,0))  --"特殊召唤"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c47436247.spcost)
	e4:SetTarget(c47436247.sptg)
	e4:SetOperation(c47436247.spop)
	c:RegisterEffect(e4)
end
c47436247.counter_add_list={0x3}
-- 过滤函数，用于判断是否为正面表示的「六武众」怪兽
function c47436247.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 当有「六武众」怪兽被召唤或特殊召唤成功时，给这张卡放置1个武士道指示物
function c47436247.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c47436247.ctfilter,1,nil) then
		e:GetHandler():AddCounter(0x3,1)
	end
end
-- 发动时的费用处理，将此卡送去墓地作为费用
function c47436247.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	local ct=e:GetHandler():GetCounter(0x3)
	e:SetLabel(ct)
	-- 将此卡送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于选择满足等级要求且为「六武众」或「紫炎」效果怪兽的卡片
function c47436247.filter(c,ct,e,tp)
	return c:IsLevelBelow(ct) and c:IsSetCard(0x103d,0x20)
		and c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的发动条件，检查场上是否有足够的空间以及卡组中是否存在符合条件的怪兽
function c47436247.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否还有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足等级和种族要求的怪兽
		and Duel.IsExistingMatchingCard(c47436247.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler():GetCounter(0x3),e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作，从卡组选择符合条件的怪兽并特殊召唤到场上
function c47436247.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ct=e:GetLabel()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c47436247.filter,tp,LOCATION_DECK,0,1,1,nil,ct,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
