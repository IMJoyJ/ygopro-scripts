--うにの軍貫
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡以外的手卡1张「军贯」卡给对方观看才能发动。这张卡从手卡特殊召唤。那之后，给人观看的卡的以下效果适用。
-- ●「舍利军贯」：可以把给人观看的怪兽特殊召唤。
-- ●那以外：给人观看的卡回到卡组最下面。
-- ②：以自己场上1只「军贯」怪兽为对象才能发动。那只怪兽的等级变成4星或者5星。那之后，可以从卡组把1只「舍利军贯」加入手卡。
function c42377643.initial_effect(c)
	-- ①：把这张卡以外的手卡1张「军贯」卡给对方观看才能发动。这张卡从手卡特殊召唤。那之后，给人观看的卡的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42377643,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,42377643)
	e1:SetCost(c42377643.spcost)
	e1:SetTarget(c42377643.sptg)
	e1:SetOperation(c42377643.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「军贯」怪兽为对象才能发动。那只怪兽的等级变成4星或者5星。那之后，可以从卡组把1只「舍利军贯」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42377643,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,42377644)
	e2:SetTarget(c42377643.lvltg)
	e2:SetOperation(c42377643.lvlop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选手牌中未公开的「军贯」卡
function c42377643.cfilter(c)
	return c:IsSetCard(0x166) and not c:IsPublic()
end
-- 效果处理：检查手牌是否存在未公开的「军贯」卡，若存在则选择一张给对方确认并洗切手牌
function c42377643.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否存在未公开的「军贯」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42377643.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择一张要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择一张手牌中满足条件的「军贯」卡
	local g=Duel.SelectMatchingCard(tp,c42377643.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家的手牌洗切
	Duel.ShuffleHand(tp)
	local tc=g:GetFirst()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
end
-- ①效果的发动条件判断：检查玩家场上是否有空位且此卡可特殊召唤
function c42377643.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将此卡特殊召唤，然后根据所选卡的卡号决定其效果
function c42377643.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=e:GetLabelObject()
		if not tc:IsRelateToEffect(e) then return end
		if tc:IsCode(24639891) then
			-- 判断所选卡是否可以特殊召唤
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 询问玩家是否将所选卡特殊召唤
				and Duel.SelectYesNo(tp,aux.Stringid(42377643,2)) then  --"是否把把给人观看的怪兽特殊召唤？"
				-- 中断当前效果处理，使后续处理视为不同时处理
				Duel.BreakEffect()
				-- 将所选卡特殊召唤
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将所选卡送回卡组底端
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于筛选场上表侧表示的「军贯」怪兽
function c42377643.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x166) and c:IsLevelAbove(0)
end
-- ②效果的发动条件判断：选择一只自己场上的「军贯」怪兽作为对象
function c42377643.lvltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42377643.filter(chkc) end
	-- 检查自己场上是否存在满足条件的「军贯」怪兽
	if chk==0 then return Duel.IsExistingTarget(c42377643.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择一只表侧表示的「军贯」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一只自己场上的「军贯」怪兽作为对象
	Duel.SelectTarget(tp,c42377643.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤函数，用于筛选「舍利军贯」卡
function c42377643.thfilter(c)
	return c:IsCode(24639891) and c:IsAbleToHand()
end
-- ②效果的处理：改变对象怪兽的等级，并可从卡组检索「舍利军贯」加入手牌
function c42377643.lvlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	local sel=0
	if tc:IsLevel(4) then
		-- 若目标怪兽为4星，则选择将其变为5星
		sel=Duel.SelectOption(tp,aux.Stringid(42377643,4))+1  --"变成5星"
	elseif tc:IsLevel(5) then
		-- 若目标怪兽为5星，则选择将其变为4星
		sel=Duel.SelectOption(tp,aux.Stringid(42377643,3))  --"变成4星"
	else
		-- 若目标怪兽为其他等级，则选择变为4星或5星
		sel=Duel.SelectOption(tp,aux.Stringid(42377643,3),aux.Stringid(42377643,4))  --"变成4星/变成5星"
	end
	-- 创建等级变更效果，设置目标怪兽等级为4或5
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	if sel==0 then
		e1:SetValue(4)
	else
		e1:SetValue(5)
	end
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	-- 检查卡组中是否存在「舍利军贯」
	if Duel.IsExistingMatchingCard(c42377643.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否从卡组检索「舍利军贯」加入手牌
		and Duel.SelectYesNo(tp,aux.Stringid(42377643,5)) then  --"是否从卡组把「舍利军贯」加入手卡？"
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择一张「舍利军贯」加入手牌
		local g=Duel.SelectMatchingCard(tp,c42377643.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将所选卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡
		Duel.ConfirmCards(1-tp,g)
	end
end
