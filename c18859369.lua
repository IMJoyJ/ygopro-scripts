--カオス・グレファー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」使用。
-- ②：从手卡丢弃1只光属性或者暗属性的怪兽才能发动。和丢弃的怪兽属性不同的1只光·暗属性怪兽从卡组送去墓地。这个回合，自己不能把这个效果送去墓地的怪兽以及那些同名怪兽特殊召唤。
function c18859369.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：从手卡丢弃1只光属性或者暗属性的怪兽才能发动。和丢弃的怪兽属性不同的1只光·暗属性怪兽从卡组送去墓地。这个回合，自己不能把这个效果送去墓地的怪兽以及那些同名怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18859369,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,18859369)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c18859369.sgcost)
	e2:SetTarget(c18859369.sgtg)
	e2:SetOperation(c18859369.sgop)
	c:RegisterEffect(e2)
end
-- ②效果的发动代价判定：将效果标签设为100以标记已满足丢弃手卡怪兽的代价，并允许发动。
function c18859369.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 筛选可作为代价从手卡丢弃的光/暗属性怪兽，同时需确认卡组中存在与它属性不同的光/暗怪兽可供送去墓地。
function c18859369.tgfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsDiscardable()
		-- 确认卡组中存在满足条件的、与候选丢弃怪兽属性不同的1只光/暗怪兽，保证后续处理可行。
		and Duel.IsExistingMatchingCard(c18859369.tgfilter2,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- 筛选卡组中可送去墓地的光/暗属性怪兽，且属性必须与已丢弃的怪兽不同。
function c18859369.tgfilter2(c,attr)
	return c:IsAbleToGrave() and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT)
		and not c:IsAttribute(attr)
end
-- ②效果发动时的目标与代价处理：先检查是否已支付代价标签，再选择并丢弃1只光/暗手卡怪兽，记录其属性，并设置将卡组怪兽送去墓地的操作信息。
function c18859369.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查己方手卡是否存在可作为代价丢弃且满足条件的光/暗属性怪兽。
		return Duel.IsExistingMatchingCard(c18859369.tgfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 给玩家显示“请选择要丢弃的手牌”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 从手卡选择1只满足tgfilter的光/暗属性怪兽作为发动代价。
	local tc=Duel.SelectMatchingCard(tp,c18859369.tgfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetAttribute())
	-- 将选中的手卡怪兽以丢弃代价（REASON_DISCARD+REASON_COST）送去墓地。
	Duel.SendtoGrave(tc,REASON_DISCARD+REASON_COST)
	-- 设置操作信息：本次效果处理将从卡组把1只怪兽送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只与丢弃怪兽属性不同的光/暗怪兽送去墓地；若成功，则给己方附加本回合不能特殊召唤该怪兽及其同名怪兽的限制。
function c18859369.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只满足tgfilter2（可送去墓地且与丢弃属性不同）的光/暗怪兽。
	local g=Duel.SelectMatchingCard(tp,c18859369.tgfilter2,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	local tc=g:GetFirst()
	-- 如果选中的卡被成功送去墓地且仍位于墓地，则创建并注册对应的不能特殊召唤限制。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 这个回合，自己不能把这个效果送去墓地的怪兽以及那些同名怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetLabel(tc:GetCode())
		e1:SetTarget(c18859369.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 向当前玩家注册这个不能特殊召唤的限制效果，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的条件：要特殊召唤的怪兽卡号与记录的被送去墓地的怪兽卡号相同（含同名卡）时，禁止特殊召唤。
function c18859369.splimit(e,c)
	return c:IsCode(e:GetLabel())
end
