--閃刀機－イーグルブースター
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不受自身以外的卡的效果影响。自己墓地有魔法卡3张以上存在的场合，再在这个回合让那只怪兽不会被战斗破坏。
function c25733157.initial_effect(c)
	-- 对应卡片效果原文：“①：自己的主要怪兽区域没有怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。这个回合，那只表侧表示怪兽不受自身以外的卡的效果影响。自己墓地有魔法卡3张以上存在的场合，再在这个回合让那只怪兽不会被战斗破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c25733157.condition)
	e1:SetTarget(c25733157.target)
	e1:SetOperation(c25733157.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡是否位于主要怪兽区域（序列号0-4），用于排除额外怪兽区域；满足条件返回true。
function c25733157.cfilter(c)
	return c:GetSequence()<5
end
-- 发动条件：自己主要怪兽区域没有怪兽存在时才可发动；通过检查场上是否存在满足cfilter的卡片来实现。
function c25733157.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测己方主要怪兽区域（LOCATION_MZONE且GetSequence()<5）是否不存在任何怪兽，若不存在则条件满足，返回true。
	return not Duel.IsExistingMatchingCard(c25733157.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 目标选择函数：以场上1只表侧表示怪兽为对象；处理连锁对象合法性验证、发动合法性检查，并提示玩家选择对象。
function c25733157.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 发动合法性检查：若为无连锁（chk==0），确认场上存在至少1只表侧表示怪兽可选作对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发送“请选择表侧表示的卡”的提示消息，用于卡牌选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从双方场上选择1只表侧表示怪兽，并将其设置为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：取得对象怪兽；若对象仍表侧且与效果关联，先赋予“不受自身以外的卡的效果影响”；若墓地魔法卡≥3，再追加“不会被战斗破坏”效果。
function c25733157.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡（取对象效果选择的那只表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 对应效果原文：“这个回合，那只表侧表示怪兽不受自身以外的卡的效果影响。”（通过EFFECT_IMMUNE_EFFECT实现）
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(c25733157.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 判断自己墓地是否存在3张以上魔法卡；若满足，则额外赋予战斗破坏免疫。
		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
			-- 对应效果原文：“自己墓地有魔法卡3张以上存在的场合，再在这个回合让那只怪兽不会被战斗破坏。”
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 免疫效果的判定函数：当所产生的效果来源（re:GetOwner()）不是被保护怪兽自身（e:GetHandler()）时，返回true，从而实现“不受自身以外的卡的效果影响”。
function c25733157.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
