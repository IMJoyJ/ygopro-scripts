--虚無空間
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，双方不能把怪兽特殊召唤。
-- ②：从卡组或者场上有卡被送去自己墓地的场合发动。这张卡破坏。
function c5851097.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)
	-- ②：从卡组或者场上有卡被送去自己墓地的场合发动。这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5851097,0))  --"这张卡破坏"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c5851097.descon)
	e3:SetTarget(c5851097.destg)
	e3:SetOperation(c5851097.desop)
	c:RegisterEffect(e3)
end
-- 过滤出从卡组或者场上送去自己墓地的卡的过滤函数
function c5851097.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK+LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
end
-- 判断是否有满足条件的卡送去自己墓地，且这张卡已在场上准备就绪
function c5851097.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5851097.filter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 破坏效果的发动检测与效果处理信息设置，防止在同一连锁中重复发动
function c5851097.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 设置当前连锁的操作信息为破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 破坏效果的执行函数，若这张卡在场则将其破坏
function c5851097.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
