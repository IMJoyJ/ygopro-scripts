--ギガンテス
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只地属性怪兽除外的场合可以特殊召唤。
-- ①：这张卡被战斗破坏送去墓地的场合发动。场上的魔法·陷阱卡全部破坏。
function c47606319.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把1只地属性怪兽除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c47606319.spcon)
	e1:SetTarget(c47606319.sptg)
	e1:SetOperation(c47606319.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡被战斗破坏送去墓地的场合发动。场上的魔法·陷阱卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47606319,0))  --"魔法·陷阱卡全部破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c47606319.condition)
	e2:SetTarget(c47606319.target)
	e2:SetOperation(c47606319.operation)
	c:RegisterEffect(e2)
end
-- 检索用过滤函数：筛选出属性为地且可以作为除外代价从墓地除外的怪兽。
function c47606319.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则效果的条件：自己场上有可用怪兽区域，且墓地存在满足条件的1只地属性怪兽可供除外。
function c47606319.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足spfilter过滤条件的地属性怪兽。
		and Duel.IsExistingMatchingCard(c47606319.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤规则效果的目标选择：从自己墓地选择1只满足条件的地属性怪兽作为除外代价，并将选择结果保存到效果对象中；若成功选择则返回true，否则返回false。
function c47606319.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中全部满足spfilter过滤条件（地属性且可作为代价除外）的怪兽集合。
	local g=Duel.GetMatchingGroup(c47606319.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 弹出选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则效果的操作：取出之前选择保存的墓地地属性怪兽，将其除外以完成特殊召唤手续。
function c47606319.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的地属性怪兽以表侧表示除外，作为这次特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- ①效果的发动条件：这张卡被战斗破坏后处于墓地，且破坏原因为战斗破坏。
function c47606319.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：筛选场上的魔法·陷阱卡（包含魔法卡和陷阱卡）。
function c47606319.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的发动时目标设定：不需取对象，效果处理时破坏场上所有魔法·陷阱卡；此处登记破坏信息。
function c47606319.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上全部魔法·陷阱卡（此时不取对象，在效果处理时才确定要破坏的卡）。
	local g=Duel.GetMatchingGroup(c47606319.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，登记该效果将破坏场上这些魔法·陷阱卡，破坏数量为获取到的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果处理：获取双方场上全部魔法·陷阱卡并将其全部破坏。
function c47606319.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取双方场上的全部魔法·陷阱卡，作为实际破坏的对象。
	local g=Duel.GetMatchingGroup(c47606319.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将这些魔法·陷阱卡以效果破坏送去墓地。
	Duel.Destroy(g,REASON_EFFECT)
end
