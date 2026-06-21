--M・HERO ファーネス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不是「英雄」怪兽不能从额外卡组特殊召唤）。从卡组把1张「假面变化」或「融合」加入手卡。那之后，选自己1张手卡丢弃。
-- ②：自己把炎属性以外的「英雄」融合怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化卡片效果并注册额外特殊召唤限制计数器
function s.initial_effect(c)
	-- 记录卡片记有「假面变化」及「融合」的卡名信息
	aux.AddCodeList(c,21143940,24094653)
	-- 注册卡片是否已在墓地的状态检测效果
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不是「英雄」怪兽不能从额外卡组特殊召唤）。从卡组把1张「假面变化」或「融合」加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己把炎属性以外的「英雄」融合怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
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
	-- 注册关于从额外卡组特殊召唤非「英雄」怪兽的自定义活动计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 过滤函数，检查是否是非「英雄」怪兽从额外卡组特殊召唤
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x8) and c:IsFaceup()
end
-- 效果①的发动成本与检测：展示手卡中的这张卡，且本回合没有从额外卡组特殊召唤过非「英雄」怪兽
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查本回合至今从额外卡组特殊召唤非「英雄」怪兽的次数是否为0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的效果1回合各能使用1次。①：把手卡的这张卡给对方观看才能发动（这个效果发动的回合，自己不是「英雄」怪兽不能从额外卡组特殊召唤）。从卡组把1张「假面变化」或「融合」加入手卡。那之后，选自己1张手卡丢弃。②：自己把炎属性以外的「英雄」融合怪兽特殊召唤的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册不能从额外卡组特殊召唤非「英雄」怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制自己不能从额外卡组特殊召唤非「英雄」怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x8) and c:IsLocation(LOCATION_EXTRA)
end
-- 检索过滤：卡名是「假面变化」或「融合」且可以加入手牌的卡
function s.thfilter(c)
	return c:IsCode(21143940,24094653) and c:IsAbleToHand()
end
-- 效果①的目标判定：确认卡组存在符合条件的卡，并设置加入手牌和丢弃手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「假面变化」或「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：丢弃自己1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 效果①的执行：从卡组将「假面变化」或「融合」加入手卡，之后玩家选择并丢弃1张手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「假面变化」或「融合」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 提示玩家选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			-- 选择自己手牌中1张可丢弃的卡
			local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
			-- 中断效果处理，使得之后的手牌丢弃不与加入手牌同时处理
			Duel.BreakEffect()
			-- 洗切玩家的手牌
			Duel.ShuffleHand(tp)
			-- 将选中的手卡送去墓地并视为因效果丢弃
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 过滤条件：自己特殊召唤的、炎属性以外的、表侧表示「英雄」融合怪兽
function s.spfilter(c,tp,se)
	return c:IsSummonPlayer(tp) and not c:IsAttribute(ATTRIBUTE_FIRE) and c:IsSetCard(0x8) and c:IsType(TYPE_FUSION) and c:IsFaceup()
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果②的触发条件判定：检查特殊召唤的怪兽中是否存在炎属性以外的「英雄」融合怪兽，且不为该效果本身引起
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.spfilter,1,nil,tp,se)
end
-- 效果②的目标判定：检查自己场上是否有空闲怪兽区域，以及这张卡能否特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的空位数量是否大于0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的执行：特殊召唤这张卡，并注册离开场上时除外的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡与链锁相关且能特殊召唤，则将这张卡表侧表示特殊召唤
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
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
