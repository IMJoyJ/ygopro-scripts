--ナチュラル・チューン
-- 效果：
-- 选择自己场上表侧表示存在的1只4星以下的通常怪兽发动。选择怪兽只要在场上表侧表示存在当作调整使用。
function c62896588.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只4星以下的通常怪兽发动。选择怪兽只要在场上表侧表示存在当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c62896588.target)
	e1:SetOperation(c62896588.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的、4星以下的、非调整的通常怪兽
function c62896588.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and not c:IsType(TYPE_TUNER)
end
-- 效果发动时的对象选择处理
function c62896588.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c62896588.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在符合条件的、可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c62896588.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c62896588.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的对象怪兽在场上表侧表示存在期间当作调整使用
function c62896588.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c62896588.filter(tc) then
		-- 选择怪兽只要在场上表侧表示存在当作调整使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
