--ギガストーン・オメガ
-- 效果：
-- 这张卡不能通常召唤。把自己墓地存在的2只地属性怪兽从游戏中除外的场合可以特殊召唤。自己场上表侧表示存在的这张卡被卡的效果送去墓地时，对方场上存在的魔法·陷阱卡全部破坏。
function c79080761.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己墓地存在的2只地属性怪兽从游戏中除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c79080761.spcon)
	e1:SetTarget(c79080761.sptg)
	e1:SetOperation(c79080761.spop)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的这张卡被卡的效果送去墓地时，对方场上存在的魔法·陷阱卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79080761,0))  --"对方场上所有魔法·陷阱卡全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c79080761.condition)
	e2:SetTarget(c79080761.target)
	e2:SetOperation(c79080761.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以作为特殊召唤Cost除外的地属性怪兽
function c79080761.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件：检查怪兽区域空位以及墓地地属性怪兽数量
function c79080761.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的主要怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少2只可以除外的地属性怪兽
		and Duel.IsExistingMatchingCard(c79080761.spfilter,tp,LOCATION_GRAVE,0,2,nil)
end
-- 特殊召唤规则的目标：选择墓地中2只地属性怪兽并暂存
function c79080761.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足特殊召唤条件的地属性怪兽
	local g=Duel.GetMatchingGroup(c79080761.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的操作：将选中的怪兽除外
function c79080761.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的理由表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 触发条件：自己场上表侧表示的这张卡因卡的效果送去墓地
function c79080761.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤魔法·陷阱卡
function c79080761.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动的目标：获取对方场上的魔法·陷阱卡并设置破坏的操作信息
function c79080761.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c79080761.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏对方场上所有魔法·陷阱卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏对方场上所有的魔法·陷阱卡
function c79080761.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c79080761.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 因卡的效果破坏选中的卡片
	Duel.Destroy(g,REASON_EFFECT)
end
