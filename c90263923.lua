--シャイニング・アブソーブ
-- 效果：
-- 选择对方场上表侧表示存在的1只光属性怪兽发动。自己场上表侧攻击表示存在的全部怪兽的攻击力直到结束阶段时上升选择的怪兽的攻击力数值。
function c90263923.initial_effect(c)
	-- 选择对方场上表侧表示存在的1只光属性怪兽发动。自己场上表侧攻击表示存在的全部怪兽的攻击力直到结束阶段时上升选择的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c90263923.target)
	e1:SetOperation(c90263923.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的光属性怪兽
function c90263923.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果发动的靶向检测与可行性判断（检查是否存在合法的对象和可受影响的怪兽）
function c90263923.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c90263923.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c90263923.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 以及自己场上是否存在表侧攻击表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_ATTACK) end
	-- 设置选择卡片时的提示信息为“请选择表侧表示的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的光属性怪兽作为效果对象
	Duel.SelectTarget(tp,c90263923.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使自己场上所有表侧攻击表示怪兽的攻击力上升对象怪兽的攻击力数值，直到结束阶段
function c90263923.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取自己场上当前所有表侧攻击表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEUP_ATTACK)
	if g:GetCount()>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local sc=g:GetFirst()
		local atk=tc:GetAttack()
		while sc do
			-- 自己场上表侧攻击表示存在的全部怪兽的攻击力直到结束阶段时上升选择的怪兽的攻击力数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(atk)
			sc:RegisterEffect(e1)
			sc=g:GetNext()
		end
	end
end
