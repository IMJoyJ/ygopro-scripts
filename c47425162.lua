--R－ACEクイック・アタッカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·场上（表侧表示）让这张卡以外的1张「救援ACE队」卡回到卡组才能发动。这张卡从手卡特殊召唤。
-- ②：把这张卡解放才能发动。从卡组把1只「救援ACE队」怪兽加入手卡。那之后，只有对方场上才有怪兽存在的场合，可以把加入手卡的那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是炎属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果，①效果为手牌特殊召唤，②效果为解放场上的卡进行检索并可能特殊召唤
function s.initial_effect(c)
	-- ①：从自己的手卡·场上（表侧表示）让这张卡以外的1张「救援ACE队」卡回到卡组才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从卡组把1只「救援ACE队」怪兽加入手卡。那之后，只有对方场上才有怪兽存在的场合，可以把加入手卡的那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是炎属性怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 定义用于判断是否可以作为①效果的cost的卡片过滤器
function s.cfilter(c,tp)
	-- 满足「救援ACE队」卡族、表侧表示、可以送入卡组作为cost且场上存在可用怪兽区
	return c:IsSetCard(0x18b) and c:IsFaceupEx() and c:IsAbleToDeckAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的费用处理函数，选择1张符合条件的卡送入卡组
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果的费用条件，即是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要送入卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张符合条件的卡作为①效果的费用
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler(),tp)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 向对方确认被选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) then
		-- 显示被选中的卡的动画效果
		Duel.HintSelection(g)
	end
	-- 将选中的卡送入卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- ①效果的目标处理函数，设置特殊召唤的目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数，将自身特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的费用处理函数，解放自身作为费用
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义用于检索「救援ACE队」怪兽的过滤器
function s.thfilter(c)
	return c:IsSetCard(0x18b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的目标处理函数，设置检索目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果的发动条件，即卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为检索
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数，检索并可能特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张符合条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被选中的卡
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		-- 判断对方场上是否存在怪兽
		if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
			-- 判断己方场上不存在怪兽
			and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			-- 判断己方场上存在可用怪兽区
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问玩家是否特殊召唤该怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 将选中的卡特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- ②效果的后效处理，设置自己不能从额外卡组特殊召唤非炎属性怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制特殊召唤的过滤函数，禁止非炎属性怪兽从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLocation(LOCATION_EXTRA)
end
