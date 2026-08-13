--ドラグニティ－レムス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，把这张卡作为同调素材的场合，不是「龙骑兵团」怪兽的同调召唤不能使用。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「龙之溪谷」加入手卡。
-- ②：自己场上有「龙骑兵团」怪兽存在的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个回合，自己不是龙族怪兽不能从额外卡组特殊召唤。
function c26577155.initial_effect(c)
	-- 将卡名「龙之溪谷」(62265044)登记到这张卡的关联卡名列表中，使这张卡在规则上被视为记载了该卡名。
	aux.AddCodeList(c,62265044)
	-- 这个卡名的①②的效果1回合各能使用1次，把这张卡作为同调素材的场合，不是「龙骑兵团」怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c26577155.synlimit)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「龙之溪谷」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26577155,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,26577155)
	e2:SetCost(c26577155.thcost)
	e2:SetTarget(c26577155.thtg)
	e2:SetOperation(c26577155.thop)
	c:RegisterEffect(e2)
	-- ②：自己场上有「龙骑兵团」怪兽存在的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个回合，自己不是龙族怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26577155,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,26577156)
	e3:SetCondition(c26577155.spcon)
	e3:SetTarget(c26577155.sptg)
	e3:SetOperation(c26577155.spop)
	c:RegisterEffect(e3)
end
-- 作为同调素材限制的判定：若素材c不存在则返回false；若素材c不是「龙骑兵团」系列卡，则返回true，表示这张卡不能作为此次同调召唤的素材。
function c26577155.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x29)
end
-- ①的发动代价：先检查手卡中的这张卡能否丢弃；在确定发动后，将这张卡从手卡丢弃作为代价。
function c26577155.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 以『丢弃』且『代价』的原因把手卡的这张卡送去墓地，完成①的代价支付。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤条件：卡片必须是「龙之溪谷」(62265044)，并且能够加入手卡。
function c26577155.thfilter(c)
	return c:IsCode(62265044) and c:IsAbleToHand()
end
-- ①的发动目标/合法性：先检查卡组中是否存在至少1张满足条件的「龙之溪谷」，再登记本次操作为从卡组把1张卡加入手卡。
function c26577155.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认卡组中有1张以上可以作为检索对象的「龙之溪谷」。
	if chk==0 then return Duel.IsExistingMatchingCard(c26577155.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记处理信息：本次连锁的效果分类为回手卡/检索，预定从自己的卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①的结算：从卡组中选取第一张符合条件的「龙之溪谷」加入手卡，并向对方展示，完成检索。
function c26577155.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中找出第一张满足过滤条件的「龙之溪谷」，若存在则赋值给tg。
	local tg=Duel.GetFirstMatchingCard(c26577155.thfilter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的「龙之溪谷」加入其持有者的手卡（nil表示返回持有者手卡）。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对方玩家展示这张刚加入手卡的「龙之溪谷」，以确认检索的正确性。
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- ②发动条件的过滤函数：对象必须是自己场上表侧表示且属于「龙骑兵团」系列的怪兽。
function c26577155.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- ②的发动条件：检查自己场上是否存在至少1只表侧表示的「龙骑兵团」怪兽。
function c26577155.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 用过滤函数检查自己场上是否有1只以上满足「表侧表示且为龙骑兵团」的怪兽。
	return Duel.IsExistingMatchingCard(c26577155.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②的发动目标/合法性：检查自己场上有可用怪兽区空格，且墓地的这张卡满足特殊召唤条件；若满足则登记特殊召唤信息。
function c26577155.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己主要怪兽区存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记处理信息：本次操作是将墓地的这张卡特殊召唤，对象确定为e:GetHandler()。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②的结算：先判断这张卡是否仍与效果关联，若关联则将其特殊召唤；成功召唤后给它附加『离场时除外』的效果，并给这张卡的控制者附加本回合只能从额外卡组特殊召唤龙族怪兽的限制。
function c26577155.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与发动时的效果仍有联系，且以表侧表示特殊召唤成功时（返回值≠0），执行后续附加效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 这个回合，自己不是龙族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c26577155.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将『本回合不能从额外卡组特殊召唤龙族以外的怪兽』的永续效果注册给发动玩家tp，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃限制的判定：若要从额外卡组特殊召唤的怪兽不是龙族，则不允许特殊召唤；即本回合从额外卡组只能特殊召唤龙族怪兽。
function c26577155.splimit(e,c)
	return not c:IsRace(RACE_DRAGON) and c:IsLocation(LOCATION_EXTRA)
end
