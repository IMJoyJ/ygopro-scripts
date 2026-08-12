--ワイトメア
-- 效果：
-- 这张卡的卡名只要在墓地存在当作「白骨」使用。此外，可以把这张卡从手卡丢弃从以下效果选择1个发动。
-- ●选择从游戏中除外的1只自己的「白骨」或者「白骨梦魇」回到自己墓地。
-- ●选择从游戏中除外的1只自己的「白骨夫人」或者「白骨王」在场上特殊召唤。
function c22339232.initial_effect(c)
	-- 使该卡在墓地时视为「白骨」卡名
	aux.EnableChangeCode(c,32274490,LOCATION_GRAVE)
	-- 这张卡的卡名只要在墓地存在当作「白骨」使用。此外，可以把这张卡从手卡丢弃从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(c22339232.cost)
	e2:SetTarget(c22339232.tgtg)
	e2:SetOperation(c22339232.tgop)
	c:RegisterEffect(e2)
end
-- 支付将此卡从手卡丢弃的代价
function c22339232.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手卡丢弃至墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 筛选符合条件的「白骨」或「白骨梦魇」怪兽
function c22339232.tgfilter(c)
	return c:IsFaceup() and c:IsCode(32274490,22339232)
end
-- 筛选符合条件的「白骨夫人」或「白骨王」怪兽
function c22339232.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(36021814,40991587) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择效果的处理逻辑
function c22339232.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c22339232.tgfilter(chkc)
		else
			return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c22339232.spfilter(chkc,e,tp)
		end
	end
	-- 检测是否存在符合条件的「白骨」或「白骨梦魇」怪兽
	local b1=Duel.IsExistingTarget(c22339232.tgfilter,tp,LOCATION_REMOVED,0,1,nil)
	-- 检测是否存在符合条件的「白骨夫人」或「白骨王」怪兽
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c22339232.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 选择发动效果的选项：「白骨」或者「白骨梦魇」回到墓地/「白骨夫人」或者「白骨王」特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(22339232,0),aux.Stringid(22339232,1))  --"「白骨」或者「白骨梦魇」回到墓地/「白骨夫人」或者「白骨王」特殊召唤"
	elseif b1 then
		-- 选择发动效果的选项：「白骨」或者「白骨梦魇」回到墓地
		op=Duel.SelectOption(tp,aux.Stringid(22339232,0))  --"「白骨」或者「白骨梦魇」回到墓地"
	else
		-- 选择发动效果的选项：「白骨夫人」或者「白骨王」特殊召唤
		op=Duel.SelectOption(tp,aux.Stringid(22339232,1))+1  --"「白骨夫人」或者「白骨王」特殊召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择目标怪兽：「白骨」或「白骨梦魇」
		local g=Duel.SelectTarget(tp,c22339232.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		-- 设置操作信息为送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择目标怪兽：「白骨夫人」或「白骨王」
		local g=Duel.SelectTarget(tp,c22339232.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		-- 设置操作信息为特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 执行选择效果的处理
function c22339232.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==0 then
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽送入墓地
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
		end
	else
		if tc:IsRelateToEffect(e) then
			-- 将目标怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
