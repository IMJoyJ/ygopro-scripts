--ジョーカーズ・ストレート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：选自己1张手卡丢弃，从卡组把1只「王后骑士」特殊召唤，从卡组把「国王骑士」「卫兵骑士」之内1只加入手卡。那之后，可以把1只怪兽召唤。这个回合，自己不是战士族·光属性怪兽不能从额外卡组特殊召唤。
-- ②：自己·对方的结束阶段，以自己墓地1只战士族·光属性怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡加入手卡。
function c92067220.initial_effect(c)
	-- 注册卡片记有「王后骑士」、「国王骑士」、「卫兵骑士」的卡片密码列表
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- ①：选自己1张手卡丢弃，从卡组把1只「王后骑士」特殊召唤，从卡组把「国王骑士」「卫兵骑士」之内1只加入手卡。那之后，可以把1只怪兽召唤。这个回合，自己不是战士族·光属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92067220,0))
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,92067220)
	e1:SetTarget(c92067220.sptg)
	e1:SetOperation(c92067220.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，以自己墓地1只战士族·光属性怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92067220,2))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,92067221)
	e2:SetTarget(c92067220.tdtg)
	e2:SetOperation(c92067220.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数：从卡组特殊召唤「王后骑士」的条件判定
function c92067220.spfilter(c,e,tp)
	return c:IsCode(25652259) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：从卡组把「国王骑士」或「卫兵骑士」加入手卡的条件判定
function c92067220.thfilter(c)
	return c:IsCode(64788463,90876561) and c:IsAbleToHand()
end
-- 效果①的发动准备（Target阶段），检查手卡数量、怪兽区域空格以及卡组中是否存在可特殊召唤和检索的卡
function c92067220.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在至少1张除这张卡以外的卡（用于丢弃）
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查卡组中是否存在可以特殊召唤的「王后骑士」
		and Duel.IsExistingMatchingCard(c92067220.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查卡组中是否存在可以加入手卡的「国王骑士」或「卫兵骑士」
		and Duel.IsExistingMatchingCard(c92067220.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：进行怪兽的通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,0,0)
end
-- 效果①的执行阶段（Operation阶段）：丢弃手卡，特殊召唤「王后骑士」，检索「国王骑士」或「卫兵骑士」，之后可进行召唤，并适用额外卡组特殊召唤限制
function c92067220.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让玩家选择并丢弃1张手卡，判断是否成功丢弃
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)>0
		-- 再次确认自己场上是否有可用于特殊召唤的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足特殊召唤条件的「王后骑士」
		local g1=Duel.SelectMatchingCard(tp,c92067220.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将选中的「王后骑士」以表侧表示特殊召唤，并判断是否特殊召唤成功
		if g1:GetCount()>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组选择1只「国王骑士」或「卫兵骑士」
			local g2=Duel.SelectMatchingCard(tp,c92067220.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if g2:GetCount()>0 then
				-- 将选中的怪兽加入玩家手卡
				Duel.SendtoHand(g2,tp,REASON_EFFECT)
				-- 向对方玩家展示加入手卡的卡
				Duel.ConfirmCards(1-tp,g2)
				-- 检查手卡或场上是否存在可以进行通常召唤的怪兽
				if Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,true,nil)
					-- 询问玩家是否选择进行怪兽的通常召唤
					and Duel.SelectYesNo(tp,aux.Stringid(92067220,1)) then  --"是否把1只怪兽召唤？"
					-- 中断当前效果处理，使后续的召唤处理与前面的效果处理不视为同时进行
					Duel.BreakEffect()
					-- 洗切玩家的手卡
					Duel.ShuffleHand(tp)
					-- 提示玩家选择要召唤的怪兽
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
					-- 从手卡或场上选择1只可以进行通常召唤的怪兽
					local sg=Duel.SelectMatchingCard(tp,Card.IsSummonable,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,true,nil)
					-- 忽略每回合通常召唤次数限制，对选中的怪兽进行通常召唤
					Duel.Summon(tp,sg:GetFirst(),true,nil)
				end
			end
		end
	end
	-- 这个回合，自己不是战士族·光属性怪兽不能从额外卡组特殊召唤。②：自己·对方的结束阶段，以自己墓地1只战士族·光属性怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c92067220.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内限制从额外卡组特殊召唤非战士族·光属性怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：限制从额外卡组特殊召唤非战士族·光属性的怪兽
function c92067220.splimit(e,c)
	return not (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：用于选择墓地中可以回到卡组的战士族·光属性怪兽
function c92067220.tdfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
-- 效果②的发动准备（Target阶段），检查墓地中是否存在战士族·光属性怪兽，以及墓地的这张卡是否能加入手卡，并进行取对象操作
function c92067220.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c92067220.tdfilter(chkc) end
	-- 检查自己墓地中是否存在至少1只战士族·光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c92067220.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and e:GetHandler():IsAbleToHand() end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只战士族·光属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c92067220.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的墓地怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的执行阶段（Operation阶段）：使作为对象的墓地怪兽回到卡组，若成功则将墓地的这张卡加入手卡
function c92067220.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②发动的取对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍适用该效果，并将其送回卡组（洗切），确认其是否成功回到卡组或额外卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		and c:IsRelateToEffect(e) then
		-- 将墓地的这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
