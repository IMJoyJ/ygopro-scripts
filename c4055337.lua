--オルフェゴール・トロイメア
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡不会被和连接怪兽的战斗破坏。
-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。从卡组把「自奏圣乐·梦幻崩影」以外的1只机械族·暗属性怪兽送去墓地，作为对象的怪兽的攻击力直到回合结束时上升送去墓地的怪兽的等级×100。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
function c4055337.initial_effect(c)
	-- ①：这张卡不会被和连接怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c4055337.indval)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以场上1只表侧表示怪兽为对象才能发动。从卡组把「自奏圣乐·梦幻崩影」以外的1只机械族·暗属性怪兽送去墓地，作为对象的怪兽的攻击力直到回合结束时上升送去墓地的怪兽的等级×100。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,4055337)
	e2:SetCondition(c4055337.atkcon1)
	-- 将此卡从墓地除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c4055337.atktg)
	e2:SetOperation(c4055337.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e3:SetCondition(c4055337.atkcon2)
	c:RegisterEffect(e3)
end
-- 当此卡为连接怪兽时，不会被战斗破坏
function c4055337.indval(e,c)
	return c:IsType(TYPE_LINK)
end
-- 当此卡不处于可发动诱发即时效果状态时，此效果可发动
function c4055337.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 当此卡不处于可发动诱发即时效果状态时，此效果可发动
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 当此卡处于可发动诱发即时效果状态且当前处于伤害步骤前时，此效果可发动
function c4055337.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当此卡处于可发动诱发即时效果状态且当前处于伤害步骤前时，此效果可发动
	return aux.dscon(e,tp,eg,ep,ev,re,r,rp) and aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 筛选场上的表侧表示怪兽
function c4055337.tgfilter(c)
	return c:IsFaceup()
end
-- 筛选卡组中非此卡的机械族暗属性怪兽
function c4055337.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave() and not c:IsCode(4055337)
end
-- 设定效果的筛选条件，需选择场上1只表侧表示怪兽和卡组1只符合条件的怪兽
function c4055337.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4055337.tgfilter(chkc) end
	-- 判断是否满足选择场上1只表侧表示怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(c4055337.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 判断是否满足选择卡组1只符合条件怪兽的条件
		and Duel.IsExistingMatchingCard(c4055337.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择场上1只表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c4055337.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将从卡组送去墓地1张符合条件的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动与结算
function c4055337.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只符合条件的怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c4055337.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		-- 确认送去墓地的卡已成功进入墓地且对象怪兽仍有效
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE)
			and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local lv=gc:GetLevel()
			-- 使对象怪兽的攻击力上升
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(lv*100)
			tc:RegisterEffect(e1)
		end
	end
	-- 使自己不能特殊召唤非暗属性怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c4055337.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使自己不能特殊召唤非暗属性怪兽
	Duel.RegisterEffect(e2,tp)
end
-- 限制特殊召唤的怪兽必须为暗属性
function c4055337.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
