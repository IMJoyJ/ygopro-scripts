--エターナル・カオス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。攻击力合计最多到那只怪兽的攻击力以下为止，从卡组把光属性和暗属性的怪兽各1只送去墓地。这张卡的发动后，直到回合结束时自己只能有1次把墓地的怪兽的效果发动。
function c25750986.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。攻击力合计最多到那只怪兽的攻击力以下为止，从卡组把光属性和暗属性的怪兽各1只送去墓地。这张卡的发动后，直到回合结束时自己只能有1次把墓地的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,25750986+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c25750986.target)
	e1:SetOperation(c25750986.activate)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否满足条件：表侧表示且其攻击力下可以找到满足条件的怪兽组合
function c25750986.tfilter(c,tp)
	-- 判断目标怪兽是否满足条件：表侧表示且其攻击力下可以找到满足条件的怪兽组合
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c25750986.tgfilter,tp,LOCATION_DECK,0,1,c,tp,c:GetAttack())
end
-- 筛选满足条件的怪兽：攻击力不超过目标攻击力、能送去墓地、属性为光或暗、且存在另一个满足条件的怪兽
function c25750986.tgfilter(c,tp,atk)
	return c:IsAttackBelow(atk) and c:IsAbleToGrave() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		-- 筛选满足条件的怪兽：攻击力不超过剩余攻击力、能送去墓地、属性为光或暗、且属性与第一个怪兽不同
		and Duel.IsExistingMatchingCard(c25750986.tgfilter1,tp,LOCATION_DECK,0,1,c,atk-c:GetAttack(),c:GetAttribute())
end
-- 筛选满足条件的怪兽：攻击力不超过剩余攻击力、能送去墓地、属性为光或暗、且属性与第一个怪兽不同
function c25750986.tgfilter1(c,atk,att)
	return c:IsAttackBelow(atk) and c:IsAbleToGrave() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and not c:IsAttribute(att)
end
-- 设置效果目标：选择对方场上1只表侧表示怪兽作为对象
function c25750986.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c25750986.tfilter(chkc,tp) end
	-- 检查是否满足发动条件：对方场上存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c25750986.tfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c25750986.tfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果处理信息：准备将2张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
-- 处理效果：选择并送去墓地的卡
function c25750986.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择满足条件的光属性或暗属性怪兽
		local g=Duel.SelectMatchingCard(tp,c25750986.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp,atk)
		local gc=g:GetFirst()
		if gc then
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 选择满足条件的光属性或暗属性怪兽（属性与第一个不同）
			local g1=Duel.SelectMatchingCard(tp,c25750986.tgfilter1,tp,LOCATION_DECK,0,1,1,gc,atk-gc:GetAttack(),gc:GetAttribute())
			g:Merge(g1)
			-- 将选中的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- ①：以对方场上1只表侧表示怪兽为对象才能发动。攻击力合计最多到那只怪兽的攻击力以下为止，从卡组把光属性和暗属性的怪兽各1只送去墓地。这张卡的发动后，直到回合结束时自己只能有1次把墓地的怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetCondition(c25750986.actcon)
		e1:SetValue(c25750986.actlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果：使自己不能发动墓地怪兽的效果
		Duel.RegisterEffect(e1,tp)
		-- ①：以对方场上1只表侧表示怪兽为对象才能发动。攻击力合计最多到那只怪兽的攻击力以下为止，从卡组把光属性和暗属性的怪兽各1只送去墓地。这张卡的发动后，直到回合结束时自己只能有1次把墓地的怪兽的效果发动。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_CHAINING)
		e2:SetOperation(c25750986.aclimit1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果：记录连锁发动的墓地怪兽效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断是否可以发动墓地怪兽效果
function c25750986.actcon(e)
	-- 判断是否可以发动墓地怪兽效果
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),25750986)~=0
end
-- 限制发动墓地怪兽效果的条件
function c25750986.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_GRAVE
end
-- 处理连锁发动的墓地怪兽效果
function c25750986.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	if ep~=tp or not re:IsActiveType(TYPE_MONSTER) or not re:GetActivateLocation()==LOCATION_GRAVE then return end
	-- 记录连锁发动的墓地怪兽效果
	Duel.RegisterFlagEffect(tp,25750986,RESET_PHASE+PHASE_END,0,1)
end
