--ナナナ
-- 效果：
-- ①：以自己场上1只7星或者7阶怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升700。
function c98931003.initial_effect(c)
	-- ①：以自己场上1只7星或者7阶怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c98931003.target)
	e1:SetOperation(c98931003.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的7星或者7阶怪兽
function c98931003.filter(c)
	return c:IsFaceup() and (c:IsLevel(7) or c:IsRank(7))
end
-- 效果发动的对象选择处理
function c98931003.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c98931003.filter(chkc) end
	-- 检查自己场上是否存在满足条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c98931003.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的7星或者7阶怪兽作为效果对象
	Duel.SelectTarget(tp,c98931003.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使作为对象的怪兽攻击力·守备力直到回合结束时上升700
function c98931003.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到回合结束时上升700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
