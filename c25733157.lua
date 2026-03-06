--閃刀機－イーグルブースター
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不受自身以外的卡的效果影响。自己墓地有魔法卡3张以上存在的场合，再在这个回合让那只怪兽不会被战斗破坏。
function c25733157.initial_effect(c)
	-- 效果原文内容：①：自己的主要怪兽区域没有怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不受自身以外的卡的效果影响。自己墓地有魔法卡3张以上存在的场合，再在这个回合让那只怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c25733157.condition)
	e1:SetTarget(c25733157.target)
	e1:SetOperation(c25733157.activate)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查怪兽区域是否为空
function c25733157.cfilter(c)
	return c:GetSequence()<5
end
-- 规则层面操作：判断是否满足发动条件（主要怪兽区域没有怪兽）
function c25733157.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断主要怪兽区域是否没有怪兽
	return not Duel.IsExistingMatchingCard(c25733157.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 规则层面操作：设置效果目标选择函数
function c25733157.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 规则层面操作：检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 规则层面操作：提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面操作：选择目标怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 规则层面操作：处理效果发动后的具体操作
function c25733157.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 效果原文内容：这个回合，那只表侧表示怪兽不受自身以外的卡的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c25733157.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 规则层面操作：判断墓地魔法卡数量是否大于等于3
		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
			-- 效果原文内容：自己墓地有魔法卡3张以上存在的场合，再在这个回合让那只怪兽不会被战斗破坏。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 规则层面操作：设置免疫效果的过滤函数，排除自身效果
function c25733157.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
