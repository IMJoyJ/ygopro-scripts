--砂漠の守護者
-- 效果：
-- 这张卡的守备力上升场上存在的魔法·陷阱卡数量×300的数值。自己场上存在的昆虫族怪兽被破坏的场合，可以作为代替把这张卡破坏。
function c38981606.initial_effect(c)
	-- 这张卡的守备力上升场上存在的魔法·陷阱卡数量×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c38981606.val)
	c:RegisterEffect(e1)
	-- 自己场上存在的昆虫族怪兽被破坏的场合，可以作为代替把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c38981606.destg)
	e2:SetValue(c38981606.value)
	e2:SetOperation(c38981606.desop)
	c:RegisterEffect(e2)
end
-- 计算场上魔法·陷阱卡的数量并乘以300作为守备力上升值
function c38981606.val(e,c)
	-- 检索场上存在的魔法·陷阱卡数量并乘以300
	return Duel.GetMatchingGroupCount(Card.IsType,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)*300
end
-- 判断目标怪兽是否为昆虫族且在场上表侧表示且不是代替破坏且是自己的怪兽
function c38981606.dfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_INSECT)
		and not c:IsReason(REASON_REPLACE) and c:IsControler(tp)
end
-- 判断破坏对象中是否存在符合条件的昆虫族怪兽
function c38981606.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not eg:IsContains(e:GetHandler())
		and eg:IsExists(c38981606.dfilter,1,nil,tp) end
	-- 询问玩家是否发动效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		return true
	else return false end
end
-- 判断是否为自己的昆虫族怪兽且在场上表侧表示且不是代替破坏
function c38981606.value(e,c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_INSECT)
		and not c:IsReason(REASON_REPLACE) and c:IsControler(e:GetHandlerPlayer())
end
-- 将自身破坏
function c38981606.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身因效果破坏且为代替破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
