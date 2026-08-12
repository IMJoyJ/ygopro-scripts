--エターナル・カオス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。攻击力合计最多到那只怪兽的攻击力以下为止，从卡组把光属性和暗属性的怪兽各1只送去墓地。这张卡的发动后，直到回合结束时自己只能有1次把墓地的怪兽的效果发动。
function c25750986.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1只表侧表示怪兽为对象才能发动。攻击力合计最多到那只怪兽的攻击力以下为止，从卡组把光属性和暗属性的怪兽各1只送去墓地。
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
-- 对象候选过滤函数：该怪兽需为表侧表示，且自己卡组存在可送去墓地的目标组合
function c25750986.tfilter(c,tp)
	-- 确认该怪兽表侧表示，且卡组中存在攻击力合计不超过其攻击力的光·暗属性怪兽各1只可送去墓地
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c25750986.tgfilter,tp,LOCATION_DECK,0,1,c,tp,c:GetAttack())
end
-- 送去墓地的第一张卡的过滤函数：攻击力不超过对象怪兽攻击力、可送去墓地、光或暗属性，且卡组中还存在与之配对的另一张
function c25750986.tgfilter(c,tp,atk)
	return c:IsAttackBelow(atk) and c:IsAbleToGrave() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		-- 并确认卡组中还存在攻击力不超过剩余攻击力差值、属性不同且可送去墓地的另一只光·暗属性怪兽
		and Duel.IsExistingMatchingCard(c25750986.tgfilter1,tp,LOCATION_DECK,0,1,c,atk-c:GetAttack(),c:GetAttribute())
end
-- 送去墓地的第二张卡的过滤函数：攻击力不超过剩余差值、可送去墓地、光或暗属性且与第一张属性不同
function c25750986.tgfilter1(c,atk,att)
	return c:IsAttackBelow(atk) and c:IsAbleToGrave() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and not c:IsAttribute(att)
end
-- 效果对象处理：以对方场上1只符合条件的表侧表示怪兽为对象，并设置从卡组送2张卡去墓地的操作信息
function c25750986.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c25750986.tfilter(chkc,tp) end
	-- 发动条件检测：确认对方场上存在1只可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c25750986.tfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上1只符合条件的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c25750986.tfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：将把自己卡组2张卡送去墓地（CATEGORY_TOGRAVE）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选光·暗属性怪兽各1只送去墓地，并在发动后注册直到回合结束自己只能有1次发动墓地怪兽效果的限制
function c25750986.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只攻击力不超过对象怪兽攻击力的光或暗属性怪兽
		local g=Duel.SelectMatchingCard(tp,c25750986.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp,atk)
		local gc=g:GetFirst()
		if gc then
			-- 提示玩家继续选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			-- 从卡组选择1只攻击力不超过剩余差值、属性与第一只不同的光或暗属性怪兽
			local g1=Duel.SelectMatchingCard(tp,c25750986.tgfilter1,tp,LOCATION_DECK,0,1,1,gc,atk-gc:GetAttack(),gc:GetAttribute())
			g:Merge(g1)
			-- 把选中的2只怪兽以效果原因送去墓地
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
		-- 把禁止发动墓地怪兽效果的永续型效果注册给自己（回合结束重置）
		Duel.RegisterEffect(e1,tp)
		-- 这张卡的发动后，直到回合结束时自己只能有1次把墓地的怪兽的效果发动。（通过持续监测连锁发动并计数实现）
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_CHAINING)
		e2:SetOperation(c25750986.aclimit1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 把监测墓地怪兽效果发动次数的持续型效果注册给自己（回合结束重置）
		Duel.RegisterEffect(e2,tp)
	end
end
-- 发动限制条件的判断函数：本回合是否已经发动过1次墓地的怪兽效果
function c25750986.actcon(e)
	-- 检查自己是否已有本回合发动过墓地怪兽效果的计数标识，有则禁止再发动
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),25750986)~=0
end
-- 限制范围的判断函数：只针对在墓地发动的怪兽效果
function c25750986.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_GRAVE
end
-- 持续监测函数：当自己把墓地的怪兽效果发动时进行计数登记
function c25750986.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandlerPlayer()
	if ep~=p or not re:IsActiveType(TYPE_MONSTER) or re:GetActivateLocation()~=LOCATION_GRAVE then return end
	-- 为自己注册本回合已发动过墓地怪兽效果的计数标识（回合结束重置）
	Duel.RegisterFlagEffect(p,25750986,RESET_PHASE+PHASE_END,0,1)
end
