--EMジンライノ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方不能选择其他的「娱乐伙伴」怪兽作为攻击对象。
-- ②：这张卡在墓地存在，「娱乐伙伴 迅雷犀牛」以外的自己场上的「娱乐伙伴」卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c70458081.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方不能选择其他的「娱乐伙伴」怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c70458081.atlimit)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，「娱乐伙伴 迅雷犀牛」以外的自己场上的「娱乐伙伴」卡被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c70458081.reptg)
	e2:SetValue(c70458081.repval)
	e2:SetOperation(c70458081.repop)
	c:RegisterEffect(e2)
end
-- 限制攻击目标：筛选场上表侧表示的、自身以外的「娱乐伙伴」怪兽。
function c70458081.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c~=e:GetHandler()
end
-- 过滤需要代替破坏的卡：自己场上表侧表示的、自身以外的、因战斗或效果将被破坏的「娱乐伙伴」卡。
function c70458081.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x9f) and not c:IsCode(70458081)
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的Target函数：检查墓地的这张卡是否可以除外，以及场上是否有满足条件的「娱乐伙伴」卡将被破坏，并询问玩家是否发动。
function c70458081.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c70458081.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的Value函数：确定被破坏的卡是否符合代替破坏的过滤条件。
function c70458081.repval(e,c)
	return c70458081.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的Operation函数：执行代替破坏的操作，将墓地的这张卡除外。
function c70458081.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
