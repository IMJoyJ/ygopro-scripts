--S－Force ナイトスレイヤー
-- 效果：
-- 包含「治安战警队」怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「治安战警队」魔法·陷阱卡加入手卡。
-- ②：自己·对方回合，把场上的这张卡和手卡1张「治安战警队」卡除外才能发动。从卡组·额外卡组把「治安战警队 黑夜杀戮者」以外的1只「治安战警队」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册「治安战警队 黑夜杀戮者」效果的 initial_effect 函数
function s.initial_effect(c)
	-- 添加连接召唤手续（包含「治安战警队」怪兽的的怪兽2只）
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「治安战警队」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把场上的这张卡和手卡1张「治安战警队」卡除外才能发动。从卡组·额外卡组把「治安战警队 黑夜杀戮者」以外的1只「治安战警队」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 连接召唤素材的过滤条件判定函数（必须包含「治安战警队」怪兽）
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x156)
end
-- 过滤可以加入手卡的「治安战警队」魔法、陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x156) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①（特殊召唤成功检索魔陷）的发动准备与检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时，检查卡组是否存在可加入手卡的「治安战警队」魔法、陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（特殊召唤成功检索魔陷）的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足条件的「治安战警队」魔法、陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片送入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤作为发动cost被除外/送墓的「治安战警队」卡片
function s.costfilter(c,e,tp)
	local ec=e:GetHandler()
	if c:IsHasEffect(55049722,tp) then
		return ec:IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	elseif c:IsHasEffect(11642993,tp) then
		return ec:IsSetCard(0x156) and not c:IsCode(11642993)
			and c:IsSetCard(0x156) and c:IsAbleToGraveAsCost()
			-- 检查卡组或额外卡组中是否存在可以被特殊召唤的「治安战警队」怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,c,e,tp,ec)
	elseif c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x156) and c:IsAbleToRemoveAsCost()
	end
end
-- 效果②的发动cost与条件检测函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时，检查手卡或卡组中是否存在可用于发动cost的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp)
		-- 检查场上的这张卡是否可以因发动cost而被除外
		and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) end
	-- 将场上的这张卡作为发动cost而除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡、墓地、卡组中符合作为代用cost被操作的卡片组
	local cg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp)
	if cg:IsExists(Card.IsHasEffect,1,nil,11642993,tp) then
		-- 提示玩家选择要操作的卡片（使用代用送墓效果）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	else
		-- 提示玩家选择要除外的卡片作为cost
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	end
	-- 玩家选择1张符合条件的卡片作为发动cost
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
	local te=tg:GetFirst():IsHasEffect(11642993,tp)
	if te then
		-- 展示特定代用卡片的卡片发动提示
		Duel.Hint(HINT_CARD,0,11642993)
		te:UseCountLimit(tp)
		-- 将代用卡片送去墓地作为cost
		Duel.SendtoGrave(tg,REASON_COST+REASON_REPLACE)
	else
		local te2=tg:GetFirst():IsHasEffect(55049722,tp)
		if te2 then
			te2:UseCountLimit(tp)
			-- 将代用卡片除外作为cost
			Duel.Remove(tg,POS_FACEUP,REASON_COST+REASON_REPLACE)
		else
			-- 将选择的手卡中的卡片正常除外作为cost
			Duel.Remove(tg,POS_FACEUP,REASON_COST)
		end
	end
end
-- 过滤可以从卡组或额外卡组特殊召唤的「治安战警队」怪兽
function s.spfilter(c,e,tp,ec)
	return not c:IsCode(id) and c:IsSetCard(0x156) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若从卡组特殊召唤，检查自己场上的怪兽区域是否有可用的空位（包含离场的这张卡所空出的怪兽区）
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,ec)>0
			-- 若从额外卡组特殊召唤，检查自己额外怪兽区域或连接指向区域是否有可用的空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0)
end
-- 效果②（特殊召唤治安战警队怪兽）的发动准备与检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时，检查卡组或额外卡组中是否存在符合条件的特殊召唤怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置从卡组或额外卡组将1只怪兽特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果②（特殊召唤治安战警队怪兽）的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组或额外卡组中选择1只可以特殊召唤的「治安战警队」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将所选怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
