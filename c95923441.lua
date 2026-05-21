--トラミッド・ハンター
-- 效果：
-- ①：场地魔法卡表侧表示存在的场合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只岩石族怪兽召唤。
-- ②：对方回合1次，以自己场上1张「三形金字塔」场地魔法卡为对象才能发动。那张卡送去墓地，从卡组把和那张卡卡名不同的1张「三形金字塔」场地魔法卡发动。
function c95923441.initial_effect(c)
	-- ①：场地魔法卡表侧表示存在的场合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只岩石族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95923441,1))  --"使用「三形金字塔的猎人」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetCondition(c95923441.sumcon)
	-- 设置增加召唤次数效果的对象为岩石族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ROCK))
	c:RegisterEffect(e1)
	-- ②：对方回合1次，以自己场上1张「三形金字塔」场地魔法卡为对象才能发动。那张卡送去墓地，从卡组把和那张卡卡名不同的1张「三形金字塔」场地魔法卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95923441,0))  --"场地魔法卡发动"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c95923441.condition)
	e2:SetTarget(c95923441.target)
	e2:SetOperation(c95923441.operation)
	c:RegisterEffect(e2)
end
-- 效果①的召唤次数增加效果的允许条件函数
function c95923441.sumcon(e)
	-- 检查场上（双方场地区域）是否存在表侧表示的卡（即表侧表示的场地魔法卡）
	return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 过滤卡组中与当前场地卡卡名不同、且可以发动的「三形金字塔」场地魔法卡
function c95923441.filter(c,tp,code)
	return c:IsType(TYPE_FIELD) and c:IsSetCard(0xe2) and c:GetActivateEffect():IsActivatable(tp,true,true) and not c:IsCode(code)
end
-- 效果②的发动条件函数
function c95923441.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的发动准备与目标选择函数
function c95923441.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场地区域的卡
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if chkc then return false end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsSetCard(0xe2) and tc:IsAbleToGrave() and tc:IsCanBeEffectTarget(e)
		-- 并且卡组中存在至少1张满足过滤条件（卡名不同且可发动）的「三形金字塔」场地魔法卡
		and Duel.IsExistingMatchingCard(c95923441.filter,tp,LOCATION_DECK,0,1,nil,tp,tc:GetCode()) end
	-- 将自己场上的「三形金字塔」场地魔法卡设为效果处理的对象
	Duel.SetTargetCard(tc)
	-- 设置效果处理信息，表示该效果包含将1张对象卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
end
-- 效果②的效果处理（操作）函数
function c95923441.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「三形金字塔」场地魔法卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍在该效果的连锁中，则将其因效果送去墓地，并确认是否成功送去墓地
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 让玩家从卡组选择1张与送去墓地的卡卡名不同的「三形金字塔」场地魔法卡
		local g=Duel.SelectMatchingCard(tp,c95923441.filter,tp,LOCATION_DECK,0,1,1,nil,tp,tc:GetCode())
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 将选中的场地魔法卡表侧表示移动到自己的场地区域（即发动该卡）
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 触发场地魔法卡发动的相关时点（事件）
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
