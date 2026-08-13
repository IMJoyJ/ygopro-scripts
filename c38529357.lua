--命の代行者 ネプチューン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从自己的手卡·墓地选「命之代行者 尼普顿」以外的1只「代行者」怪兽特殊召唤。场上或者墓地有「天空的圣域」存在的场合，可以把特殊召唤的怪兽改成1只「许珀里翁」怪兽。直到对方回合结束时，双方不能把这个效果特殊召唤的怪兽解放。
-- ②：这张卡被除外的场合才能发动。从卡组把1张「天空的圣域」加入手卡。
function c38529357.initial_effect(c)
	-- 将卡号56433456（天空的圣域）记录到本卡的代码列表中，用于表示这张卡的效果文内有记载该卡名，便于涉及“记载有卡名”的判定。
	aux.AddCodeList(c,56433456)
	-- ①：把这张卡从手卡丢弃才能发动。从自己的手卡·墓地选「命之代行者 尼普顿」以外的1只「代行者」怪兽特殊召唤。场上或者墓地有「天空的圣域」存在的场合，可以把特殊召唤的怪兽改成1只「许珀里翁」怪兽。直到对方回合结束时，双方不能把这个效果特殊召唤的怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38529357,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,38529357)
	e1:SetCost(c38529357.spcost)
	e1:SetTarget(c38529357.sptg)
	e1:SetOperation(c38529357.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。从卡组把1张「天空的圣域」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38529357,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,38529358)
	e2:SetTarget(c38529357.thtg)
	e2:SetOperation(c38529357.thop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动代价：检测自己手卡中的这张卡能否被丢弃，并在发动时将其丢弃作为代价。
function c38529357.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手卡以丢弃代价（代价且丢弃）送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义特殊召唤对象的过滤条件：不是卡名“命之代行者 尼普顿”，而是「代行者」系列怪兽；若场上有「天空的圣域」（check为真），也可选择「许珀里翁」系列怪兽，且该怪兽必须能被特殊召唤。
function c38529357.spfilter(c,e,tp,check)
	return not c:IsCode(38529357) and (c:IsSetCard(0x44) or check and c:IsSetCard(0x16f)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义①效果的发动目标：检查自己是否有可用的怪兽区以及是否存在符合条件的特殊召唤对象，并设置进行特殊召唤的操作信息。
function c38529357.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 发动时如果自己没有可用主要怪兽区，则不能发动。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 检查场上或墓地是否存在「天空的圣域」，以此决定可选的怪兽范围是否扩展到「许珀里翁」系列。
		local check=Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
		-- 确认自己手卡·墓地存在至少1张符合条件的特殊召唤对象（排除本卡）。
		return Duel.IsExistingMatchingCard(c38529357.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp,check)
	end
	-- 设置操作信息：本次效果将特殊召唤1只怪兽，且来源可能为手卡或墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义①效果处理：实际选择要特殊召唤的怪兽，进行特殊召唤，并给特殊召唤的怪兽附加不能被解放的限制。
function c38529357.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若已经没有可用主要怪兽区，则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时再次确认场上或墓地是否有「天空的圣域」，以决定此时可选的怪兽范围。
	local check=Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 弹出提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1只符合条件的怪兽（经过王家长眠之谷相关过滤），作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38529357.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		-- 对选中的怪兽进行特殊召唤的分步处理，以表侧表示特殊召唤到自己场上。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 直到对方回合结束时，双方不能把这个效果特殊召唤的怪兽解放。②：这张卡被除外的场合才能发动。从卡组把1张「天空的圣域」加入手卡。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			tc:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			tc:RegisterEffect(e2,true)
		end
		-- 完成上述特殊召唤的分步处理，正式确认特殊召唤成功。
		Duel.SpecialSummonComplete()
	end
end
-- 定义②效果的检索过滤条件：卡名是「天空的圣域」且可以被加入手卡。
function c38529357.thfilter(c)
	return c:IsCode(56433456) and c:IsAbleToHand()
end
-- 定义②效果的发动目标：确认卡组中存在「天空的圣域」，并设置检索加入手卡的操作信息。
function c38529357.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「天空的圣域」。
	if chk==0 then return Duel.IsExistingMatchingCard(c38529357.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把1张卡的卡片加入手卡，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义②效果处理：从卡组选择1张「天空的圣域」加入手卡，并向对手确认。
function c38529357.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出提示，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「天空的圣域」。
	local g=Duel.SelectMatchingCard(tp,c38529357.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入其持有者的手卡，操作原因是效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
