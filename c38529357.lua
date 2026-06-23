--命の代行者 ネプチューン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从自己的手卡·墓地选「命之代行者 尼普顿」以外的1只「代行者」怪兽特殊召唤。场上或者墓地有「天空的圣域」存在的场合，可以把特殊召唤的怪兽改成1只「许珀里翁」怪兽。直到对方回合结束时，双方不能把这个效果特殊召唤的怪兽解放。
-- ②：这张卡被除外的场合才能发动。从卡组把1张「天空的圣域」加入手卡。
function c38529357.initial_effect(c)
	-- 注册此卡牌的额外卡名代码，用于识别其关联的「天空的圣域」卡
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
-- 设置效果发动的代价为将此卡从手卡丢弃
function c38529357.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡送入墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义特殊召唤目标怪兽的过滤条件，排除自身并限定为「代行者」或「许珀里翁」系列且可特殊召唤
function c38529357.spfilter(c,e,tp,check)
	return not c:IsCode(38529357) and (c:IsSetCard(0x44) or check and c:IsSetCard(0x16f)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的发动条件，检查是否有符合条件的怪兽可特殊召唤
function c38529357.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 判断当前场上或墓地是否存在「天空的圣域」场地卡
		local check=Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
		-- 检查手牌或墓地是否存在满足条件的怪兽
		return Duel.IsExistingMatchingCard(c38529357.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp,check)
	end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤操作，选择目标怪兽并进行特殊召唤
function c38529357.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断当前场上或墓地是否存在「天空的圣域」场地卡
	local check=Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 根据过滤条件选择要特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38529357.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		-- 尝试特殊召唤选定的怪兽
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 为特殊召唤的怪兽添加效果，使其在对方回合结束前无法被解放
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
		-- 完成特殊召唤流程的收尾工作
		Duel.SpecialSummonComplete()
	end
end
-- 定义检索目标卡的过滤条件，限定为「天空的圣域」且可加入手牌
function c38529357.thfilter(c)
	return c:IsCode(56433456) and c:IsAbleToHand()
end
-- 判断是否满足检索「天空的圣域」的发动条件
function c38529357.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「天空的圣域」
	if chk==0 then return Duel.IsExistingMatchingCard(c38529357.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的操作
function c38529357.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 根据过滤条件选择要加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,c38529357.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
