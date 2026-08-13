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
-- 计算场上魔法·陷阱卡数量并乘以300，作为这张卡的守备力上升数值。
function c38981606.val(e,c)
	-- 统计双方场上的魔法·陷阱卡数量（不取对象，仅筛选类型），乘以300作为守备力上升值。
	return Duel.GetMatchingGroupCount(Card.IsType,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)*300
end
-- 筛选被破坏的昆虫族怪兽：位于主要怪兽区、表侧表示、昆虫族、破坏原因不是代替破坏、且控制者为这张卡的控制者。
function c38981606.dfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_INSECT)
		and not c:IsReason(REASON_REPLACE) and c:IsControler(tp)
end
-- 作为代替破坏效果的发动条件检查：被破坏的怪兽集合中不能包含这张卡自身，且存在1只满足条件的己方昆虫族怪兽。
function c38981606.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not eg:IsContains(e:GetHandler())
		and eg:IsExists(c38981606.dfilter,1,nil,tp) end
	-- 弹出发动确认框，询问这张卡的控制者是否用这张卡代替昆虫族怪兽破坏。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		return true
	else return false end
end
-- 代替破坏效果的判定函数：被破坏的卡必须是己方场上表侧表示的昆虫族怪兽，且破坏原因不是代替破坏。
function c38981606.value(e,c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_INSECT)
		and not c:IsReason(REASON_REPLACE) and c:IsControler(e:GetHandlerPlayer())
end
-- 代替破坏的处理：将这张卡本身破坏（破坏原因包含效果和代替）。
function c38981606.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 把这张卡破坏，破坏原因为效果破坏并带有代替标记。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
