--のどかな埋葬
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只怪兽送去墓地。这个回合，自己不能作这个效果送去墓地的卡以及那些同名卡的效果的发动。
function c14055212.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只怪兽送去墓地。这个回合，自己不能作这个效果送去墓地的卡以及那些同名卡的效果的发动。
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
-- 定义过滤函数：选择卡组中1只满足“是怪兽且可以被送去墓地”的卡。
function c14055212.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 发动时的目标判定函数：检查发动条件，并设定效果操作信息为从卡组把1张卡送去墓地。
function c14055212.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己卡组存在至少1只符合条件的怪兽可以送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c14055212.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定本次效果的操作信息：把1张卡从卡组送去墓地，供连锁相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的执行函数：从卡组选择1只怪兽送去墓地，若该卡成功进入墓地，则本回合内自己不能发动该卡及同名卡的效果。
function c14055212.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c14055212.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_GRAVE) then
			-- 这个回合，自己不能作这个效果送去墓地的卡以及那些同名卡的效果的发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c14055212.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将上述禁止发动效果的永续效果注册给当前玩家，持续到本回合结束。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 限制条件判定：发动效果的卡的卡号与被送去墓地的卡（或同名卡）的卡号一致时，禁止其发动。
function c14055212.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
