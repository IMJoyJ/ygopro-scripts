--ドラグニティナイト－ロムルス
-- 效果：
-- 衍生物以外的龙族·鸟兽族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「龙骑兵团」魔法·陷阱卡或「龙之溪谷」加入手卡。
-- ②：龙族怪兽从额外卡组往这张卡所连接区特殊召唤的场合才能发动。从手卡把1只龙族·鸟兽族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能作为连接素材。
function c11969228.initial_effect(c)
	-- 将卡号62265044（龙之溪谷）登记为这张卡的记述卡名，使此卡被视为记载着“龙之溪谷”的卡，用于配合检索判定。
	aux.AddCodeList(c,62265044)
	-- 设置此卡的连接召唤素材条件：使用2只满足mfilter（衍生物以外的龙族或鸟兽族怪兽）的怪兽作为连接素材。
	aux.AddLinkProcedure(c,c11969228.mfilter,2,2)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡连接召唤的场合才能发动。从卡组把1张「龙骑兵团」魔法·陷阱卡或「龙之溪谷」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11969228,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,11969228)
	e1:SetCondition(c11969228.thcon)
	e1:SetTarget(c11969228.thtg)
	e1:SetOperation(c11969228.thop)
	c:RegisterEffect(e1)
	-- ②：龙族怪兽从额外卡组往这张卡所连接区特殊召唤的场合才能发动。从手卡把1只龙族·鸟兽族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能作为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11969228,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11969229)
	e2:SetCondition(c11969228.spcon)
	e2:SetTarget(c11969228.sptg)
	e2:SetOperation(c11969228.spop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数：判定怪兽不是衍生物，且种族为龙族或鸟兽族，满足此卡连接素材要求（衍生物以外的龙族·鸟兽族怪兽2只）。
function c11969228.mfilter(c)
	return not c:IsLinkType(TYPE_TOKEN) and c:IsLinkRace(RACE_DRAGON+RACE_WINDBEAST)
end
-- ①效果的发动条件：仅当这张卡以连接召唤方式特殊召唤成功时，该效果才能发动。
function c11969228.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果的检索目标过滤：卡片为「龙骑兵团」魔法·陷阱卡或「龙之溪谷」，且能够加入手卡。
function c11969228.thfilter(c)
	return ((c:IsSetCard(0x29) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsCode(62265044)) and c:IsAbleToHand()
end
-- ①效果的发动时判定与操作信息登记：在chk==0时检查卡组是否存在可检索的卡，并登记“从卡组加入手卡”的处理信息。
function c11969228.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中至少存在1张满足thfilter的卡，否则不能发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c11969228.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：此次效果将把1张卡从卡组加入手卡（不取对象），供连锁和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的解决处理：从卡组选择1张符合条件的卡加入手卡，并向对方展示确认。
function c11969228.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中筛选并选择1张满足thfilter的卡。
	local g=Duel.SelectMatchingCard(tp,c11969228.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的那张卡送入其持有者的手卡（效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示被检索加入手卡的卡，以确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果触发判定辅助过滤：该特殊召唤的怪兽是龙族，且从额外卡组特殊召唤，并且位于这张卡的连接区。
function c11969228.cfilter(c,lg)
	return c:IsRace(RACE_DRAGON) and c:IsSummonLocation(LOCATION_EXTRA) and lg:IsContains(c)
end
-- ②效果的发动条件：本次特殊召唤的怪兽中存在龙族怪兽从额外卡组被特殊召唤到这张卡所连接区的场合，条件成立。
function c11969228.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c11969228.cfilter,1,nil,lg)
end
-- ②效果的特殊召唤目标过滤：手卡中的龙族或鸟兽族怪兽，能够以表侧守备表示被这张卡的效果特殊召唤。
function c11969228.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON+RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动时判定与操作信息登记：检查自己场上是否有空位、手卡是否有可特殊召唤目标，并登记特殊召唤操作信息。
function c11969228.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己主要怪兽区有可用空位，否则不能发动②效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：手卡中存在至少1只满足spfilter的怪兽，否则不能发动②效果。
		and Duel.IsExistingMatchingCard(c11969228.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：此次效果将从手卡特殊召唤1只怪兽（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的解决处理：选择手卡中的龙族·鸟兽族怪兽以表侧守备表示特殊召唤，并对其附加效果无效化、不能作为连接素材的限制。
function c11969228.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，若没有空位则终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1只满足spfilter的怪兽。
	local g=Duel.SelectMatchingCard(tp,c11969228.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选到怪兽，则将其以表侧守备表示作为分步特殊召唤的第一步进行特殊召唤（后续可继续附加效果）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽在这个回合效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽在这个回合效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 不能作为连接素材。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
	-- 完成分步特殊召唤处理，将之前经SpecialSummonStep的怪兽正式特殊召唤成功，并触发特殊召唤成功时点。
	Duel.SpecialSummonComplete()
end
