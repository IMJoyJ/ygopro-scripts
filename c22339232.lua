--ワイトメア
-- 效果：
-- 这张卡的卡名只要在墓地存在当作「白骨」使用。此外，可以把这张卡从手卡丢弃从以下效果选择1个发动。
-- ●选择从游戏中除外的1只自己的「白骨」或者「白骨梦魇」回到自己墓地。
-- ●选择从游戏中除外的1只自己的「白骨夫人」或者「白骨王」在场上特殊召唤。
function c22339232.initial_effect(c)
	-- 为这张卡注册在墓地时卡名当作「白骨」处理的效果。
	aux.EnableChangeCode(c,32274490,LOCATION_GRAVE)
	-- 可以把这张卡从手卡丢弃从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(c22339232.cost)
	e2:SetTarget(c22339232.tgtg)
	e2:SetOperation(c22339232.tgop)
	c:RegisterEffect(e2)
end
-- 代价函数：检测这张卡在手牌是否可以被丢弃作为发动代价。
function c22339232.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将手卡的这张卡丢弃送去墓地，作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤函数：选择除外区表侧表示且卡名为「白骨」或「白骨梦魇」的卡。
function c22339232.tgfilter(c)
	return c:IsFaceup() and c:IsCode(32274490,22339232)
end
-- 过滤函数：选择除外区表侧表示且卡名为「白骨夫人」或「白骨王」，并满足特殊召唤条件的卡。
function c22339232.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(36021814,40991587) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择与效果发动时的处理函数：根据之前选择的选项，选择对应类型的除外区卡片作为对象，并设置操作信息。
function c22339232.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c22339232.tgfilter(chkc)
		else
			return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c22339232.spfilter(chkc,e,tp)
		end
	end
	-- 检查除外区是否存在至少1张自己的「白骨」或「白骨梦魇」，用于回墓地选项的发动条件。
	local b1=Duel.IsExistingTarget(c22339232.tgfilter,tp,LOCATION_REMOVED,0,1,nil)
	-- 检查自己主要怪兽区是否有空位，且除外区是否存在至少1张满足特殊召唤条件的「白骨夫人」或「白骨王」，用于特殊召唤选项的发动条件。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c22339232.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个选项均可用时，弹出选择菜单让玩家选择发动「回到墓地」或「特殊召唤」效果。
		op=Duel.SelectOption(tp,aux.Stringid(22339232,0),aux.Stringid(22339232,1))  --"「白骨」或者「白骨梦魇」回到墓地/「白骨夫人」或者「白骨王」特殊召唤"
	elseif b1 then
		-- 仅有回墓地选项可用时，弹出该选项。
		op=Duel.SelectOption(tp,aux.Stringid(22339232,0))  --"「白骨」或者「白骨梦魇」回到墓地"
	else
		-- 仅有特殊召唤选项可用时，弹出该选项并将op设为1，对应效果标签。
		op=Duel.SelectOption(tp,aux.Stringid(22339232,1))+1  --"「白骨夫人」或者「白骨王」特殊召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择1张除外区自己的「白骨」或「白骨梦魇」作为回墓地的对象。
		local g=Duel.SelectTarget(tp,c22339232.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		-- 设置操作信息，标记将对象卡送去墓地（即回到墓地）。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1张除外区自己的「白骨夫人」或「白骨王」作为特殊召唤的对象。
		local g=Duel.SelectTarget(tp,c22339232.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		-- 设置操作信息，标记将对象卡特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果处理函数：根据效果标签（op）选择将对象卡送回墓地或特殊召唤到场上。
function c22339232.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		if tc:IsRelateToEffect(e) then
			-- 将对象卡以效果原因和回到墓地原因送去墓地，即回到自己墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
		end
	else
		if tc:IsRelateToEffect(e) then
			-- 将对象卡以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
