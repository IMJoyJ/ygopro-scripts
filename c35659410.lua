--青き眼の幻出
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡也能把手卡1只「青眼白龙」给人观看来发动。那个场合，从手卡把1只怪兽特殊召唤。
-- ②：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽回到持有者手卡。那之后，可以让回到手卡的卡的原本卡名的以下效果适用。
-- ●「青眼白龙」：从手卡把1只怪兽特殊召唤。
-- ●那以外：从手卡把1只「青眼」怪兽特殊召唤。
function c35659410.initial_effect(c)
	-- 记录此卡具有「青眼白龙」的卡名
	aux.AddCodeList(c,89631139)
	-- ①：这张卡也能把手卡1只「青眼白龙」给人观看来发动。那个场合，从手卡把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35659410+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c35659410.target)
	e1:SetOperation(c35659410.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽回到持有者手卡。那之后，可以让回到手卡的卡的原本卡名的以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c35659410.sptg)
	e2:SetOperation(c35659410.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否有未公开的「青眼白龙」
function c35659410.showfilter(c)
	return c:IsCode(89631139) and not c:IsPublic()
end
-- 过滤函数，用于判断手卡中是否有可以特殊召唤的怪兽
function c35659410.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位、手卡有「青眼白龙」、手卡有可特殊召唤的怪兽
function c35659410.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 判断场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡是否存在「青眼白龙」
		and Duel.IsExistingMatchingCard(c35659410.showfilter,tp,LOCATION_HAND,0,1,nil)
		-- 判断手卡是否存在可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c35659410.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 询问玩家是否发动效果
		and Duel.SelectYesNo(tp,aux.Stringid(35659410,0)) then  --"是否展示「青眼白龙」并从手卡特殊召唤怪兽？"
		-- 提示玩家选择要确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择一张手卡中的「青眼白龙」
		local g=Duel.SelectMatchingCard(tp,c35659410.showfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 向对方确认所选的「青眼白龙」
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		e:SetLabel(1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置效果处理信息，准备特殊召唤怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		e:SetLabel(0)
		e:SetCategory(0)
	end
end
-- 发动效果时的处理函数，用于特殊召唤怪兽
function c35659410.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择一张手卡中的可特殊召唤怪兽
		local sg=Duel.SelectMatchingCard(tp,c35659410.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将所选怪兽特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤函数，用于判断场上表侧表示的怪兽是否可以送回手牌
function c35659410.thfilter(c)
	return c:IsAbleToHand() and c:IsFaceup()
end
-- 过滤函数，用于判断手卡中是否有「青眼」怪兽
function c35659410.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0xdd)
end
-- 设置效果处理信息，准备选择目标怪兽并送回手牌
function c35659410.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c35659410.thfilter(chkc) end
	-- 判断场上是否存在可作为目标的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c35659410.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c35659410.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，准备将目标怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 发动效果时的处理函数，用于将目标怪兽送回手牌并触发后续效果
function c35659410.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local code=tc:GetOriginalCode()
	-- 判断目标怪兽是否有效且已送回手牌
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取手卡中所有可特殊召唤的怪兽
		local g1=Duel.GetMatchingGroup(c35659410.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if code==89631139 and #g1>0
			-- 询问玩家是否发动特殊召唤效果
			and Duel.SelectYesNo(tp,aux.Stringid(35659410,1)) then  --"是否从手卡特殊召唤怪兽？"
			-- 中断当前效果，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg1=g1:Select(tp,1,1,nil)
			-- 将所选怪兽特殊召唤到场上
			Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 获取手卡中所有可特殊召唤的「青眼」怪兽
		local g2=Duel.GetMatchingGroup(c35659410.spfilter2,tp,LOCATION_HAND,0,nil,e,tp)
		if code~=89631139 and #g2>0
			-- 询问玩家是否发动特殊召唤效果
			and Duel.SelectYesNo(tp,aux.Stringid(35659410,1)) then  --"是否从手卡特殊召唤怪兽？"
			-- 中断当前效果，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg2=g2:Select(tp,1,1,nil)
			-- 将所选怪兽特殊召唤到场上
			Duel.SpecialSummon(sg2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
