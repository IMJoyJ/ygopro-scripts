--チューナーズ・バリア
-- 效果：
-- 选择自己场上表侧表示存在的1只调整发动。直到下个回合的结束阶段时，选择的1只调整不会被战斗或者卡的效果破坏。
function c5609226.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只调整发动。直到下个回合的结束阶段时，选择的1只调整不会被战斗或者卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c5609226.target)
	e1:SetOperation(c5609226.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的调整怪兽
function c5609226.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 效果发动时的对象选择与合法性检查
function c5609226.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c5609226.filter(chkc) end
	-- 检查自己场上是否存在符合条件的表侧表示调整怪兽
	if chk==0 then return Duel.IsExistingTarget(c5609226.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的调整怪兽作为效果的对象
	Duel.SelectTarget(tp,c5609226.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理，使选择的对象怪兽直到下个回合的结束阶段时获得战斗与效果破坏抗性
function c5609226.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 直到下个回合的结束阶段时，选择的1只调整不会被战斗...破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 直到下个回合的结束阶段时，选择的1只调整不会被...卡的效果破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
	end
end
