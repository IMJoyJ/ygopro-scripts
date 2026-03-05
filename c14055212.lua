--のどかな埋葬
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只怪兽送去墓地。这个回合，自己不能作这个效果送去墓地的卡以及那些同名卡的效果的发动。
function c14055212.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14055212+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c14055212.target)
	e1:SetOperation(c14055212.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡组中是否存在满足条件的怪兽卡
function c14055212.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果的发动时点处理函数，用于判断是否可以发动此效果
function c14055212.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在卡组中是否存在至少1只怪兽卡可以送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c14055212.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果发动时的操作信息，表示将从卡组选择1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，用于执行效果的主要操作
function c14055212.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组中选择1只满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,c14055212.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_GRAVE) then
			-- 效果原文内容：①：从卡组把1只怪兽送去墓地。这个回合，自己不能作这个效果送去墓地的卡以及那些同名卡的效果的发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c14055212.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将效果注册到全局环境，使该效果生效
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 用于限制发动的条件，判断是否为同名卡的效果
function c14055212.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
