--M・HERO ファーネス
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 建立卡片与「假面变化」和「形态变化」的关联，用于卡片检索和相关效果判定。
	aux.AddCodeList(c,21143940,24094653)
	-- 注册用于检测此卡在特殊召唤发生前是否已存在于墓地的状态监听效果。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：把手卡的这张卡给双方确认才能发动。从卡组把1张「マスク・チェンジ」或「フォーム・チェンジ」加入手卡。那之后，选1张手卡丢弃。这个效果的发动后，直到回合结束时自己不是「HERO」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有炎属性以外的「HERO」融合怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetLabelObject(e0)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 注册自定义特殊召唤计数器，用于检测本回合是否从额外卡组特殊召唤过「HERO」以外的怪兽。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：非额外卡组特殊召唤的怪兽，或者属于「HERO」字段的怪兽不计入限制。
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x8)
end
-- 检索效果的发动代价：确认手卡的这张卡，且本回合不能有不符合限制的特殊召唤。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查本回合是否未进行过「HERO」以外的额外卡组怪兽的特殊召唤。
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果的发动后，直到回合结束时自己不是「HERO」怪兽不能从额外卡组特殊召唤。从卡组把1张「マスク・チェンジ」或「フォーム・チェンジ」加入手卡。那之后，选1张手卡丢弃。自己场上有炎属性以外的「HERO」融合怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能从额外卡组特殊召唤「HERO」以外怪兽的约束效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能从额外卡组特殊召唤「HERO」以外的怪兽。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x8) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤卡组中卡名为「假面变化」或「形态变化」且可以加入手卡的卡。
function s.thfilter(c)
	return c:IsCode(21143940,24094653) and c:IsAbleToHand()
end
-- 检索并丢弃效果的发动准备：检查卡组中是否存在目标卡，并设置检索和丢弃手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「假面变化」或「形态变化」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 检索并丢弃效果的处理：将卡加入手卡，确认后，再选择1张手卡丢弃。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「假面变化」或「形态变化」。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 提示玩家选择要丢弃的手牌。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			-- 让玩家选择1张可以丢弃的手牌。
			local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
			-- 中断效果处理，使后续的丢弃手卡不与加入手卡视为同时处理。
			Duel.BreakEffect()
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(tp)
			-- 将选择的手牌送入墓地（视为因效果丢弃）。
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 过滤在自己场上特殊召唤的、炎属性以外的「HERO」融合怪兽。
function s.spfilter(c,tp,se)
	return c:IsSummonPlayer(tp) and not c:IsAttribute(ATTRIBUTE_FIRE) and c:IsSetCard(0x8) and c:IsType(TYPE_FUSION) and c:IsFaceup()
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 特殊召唤效果的发动条件：自己场上有炎属性以外的「HERO」融合怪兽特殊召唤，且若此卡在墓地，需在特殊召唤前已存在于墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfilter,1,nil,tp,se)
end
-- 特殊召唤效果的发动准备：检查怪兽区域是否有空位，以及此卡是否可以特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤，并添加离场时除外的约束。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与连锁相关、不受墓地限制影响，并尝试将其以表侧表示特殊召唤。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤的流程。
	Duel.SpecialSummonComplete()
end
