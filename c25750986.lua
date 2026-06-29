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
-- 作为效果对象的对方场上怪兽的过滤条件（其当前攻击力需大于等于卡组中两只怪兽的最小攻击力合计值）
function c25750986.tfilter(c,tp)
	-- 判断怪兽是否表侧表示且卡组中存在可以送去墓地的光与暗属性怪兽组合
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c25750986.tgfilter,tp,LOCATION_DECK,0,1,c,tp,c:GetAttack())
end
-- 从卡组选择的第一只光或暗属性怪兽的过滤条件
function c25750986.tgfilter(c,tp,atk)
	return c:IsAttackBelow(atk) and c:IsAbleToGrave() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		-- 验证该怪兽是否能在攻击力额度内送去墓地且卡组中存在与之属性相反的另一只怪兽
		and Duel.IsExistingMatchingCard(c25750986.tgfilter1,tp,LOCATION_DECK,0,1,c,atk-c:GetAttack(),c:GetAttribute())
end
-- 从卡组选择的第二只属性相反的怪兽过滤条件
function c25750986.tgfilter1(c,atk,att)
	return c:IsAttackBelow(atk) and c:IsAbleToGrave() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and not c:IsAttribute(att)
end
-- 送墓效果的发动准备与对象选择
function c25750986.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c25750986.tfilter(chkc,tp) end
	-- 检查对方场上是否存在满足过滤条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c25750986.tfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 向玩家发送提示，请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只怪兽作为效果对象
	Duel.SelectTarget(tp,c25750986.tfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息为从卡组将2张怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
-- 送墓及墓地发动限制效果的执行
function c25750986.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择的对方怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 向玩家发送提示，请选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择第1只符合条件制造的第一只光或暗属性怪兽
		local g=Duel.SelectMatchingCard(tp,c25750986.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp,atk)
		local gc=g:GetFirst()
		if gc then
			-- 向玩家发送提示，请选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 从卡组选择第2只符合条件且属性相反的怪兽
			local g1=Duel.SelectMatchingCard(tp,c25750986.tgfilter1,tp,LOCATION_DECK,0,1,1,gc,atk-gc:GetAttack(),gc:GetAttribute())
			g:Merge(g1)
			-- 将这2只怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己只能有1次把墓地的怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetCondition(c25750986.actcon)
		e1:SetValue(c25750986.actlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 当自己本回合在墓地发动过怪兽效果后，注册禁止继续在墓地发动怪兽效果的限制
		Duel.RegisterEffect(e1,tp)
		-- 注册用于记录和计数自己本回合在墓地发动怪兽效果次数的全局持续效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_CHAINING)
		e2:SetOperation(c25750986.aclimit1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将用于记录墓地怪兽效果发动的全局监听事件注册给系统
		Duel.RegisterEffect(e2,tp)
	end
end
-- 当且仅当自己在墓地发动过怪兽效果时（即标志数不为0），禁止继续发动
function c25750986.actcon(e)
	-- 检查自己本回合是否已经在墓地发动过怪兽效果
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),25750986)~=0
end
-- 限制在墓地发动的怪兽效果
function c25750986.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_GRAVE
end
-- 当自己在墓地发动怪兽效果时，在玩家身上标记标志效果
function c25750986.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandlerPlayer()
	if ep~=p or not re:IsActiveType(TYPE_MONSTER) or re:GetActivateLocation()~=LOCATION_GRAVE then return end
	-- 在自己玩家身上打上标志以记录已使用完仅有的1次墓地效果发动额度
	Duel.RegisterFlagEffect(p,25750986,RESET_PHASE+PHASE_END,0,1)
end
