--サイバース・シンクロン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，以自己场上1只4星以下的怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升那个原本等级数值。
-- ②：额外怪兽区域的自己怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c86784733.initial_effect(c)
	-- ①：1回合1次，以自己场上1只4星以下的怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升那个原本等级数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c86784733.target)
	e1:SetOperation(c86784733.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：额外怪兽区域的自己怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,86784733)
	e2:SetTarget(c86784733.reptg)
	e2:SetValue(c86784733.repval)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示且等级在4星以下的怪兽
function c86784733.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
-- ①号效果的发动准备与目标选择
function c86784733.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c86784733.filter(chkc) end
	-- 检查自己场上是否存在满足条件的、可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c86784733.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示且4星以下的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c86784733.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- ①号效果的实际处理，使目标怪兽的等级上升其原本等级数值
function c86784733.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的等级直到回合结束时上升那个原本等级数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc:GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤额外怪兽区域中被战斗或效果破坏的自己怪兽
function c86784733.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()>=5 and c:IsControler(tp)
		and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ②号效果的代替破坏效果的目标判定与处理
function c86784733.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c86784733.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 将墓地的这张卡除外
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
-- 确定被代替破坏的怪兽是否符合条件
function c86784733.repval(e,c)
	return c86784733.repfilter(c,e:GetHandlerPlayer())
end
