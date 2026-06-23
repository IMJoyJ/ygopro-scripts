--捕食植物ビブリスプ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被送去墓地的场合才能发动。从卡组把「捕食植物 腺毛草胡蜂」以外的1只「捕食植物」怪兽加入手卡。
-- ②：这张卡在墓地存在，场上的怪兽有捕食指示物放置中的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 创建两个效果，分别对应卡片效果①和②的发动条件与处理
function c44932065.initial_effect(c)
	-- 效果①：这张卡被送去墓地的场合才能发动。从卡组把「捕食植物 腺毛草胡蜂」以外的1只「捕食植物」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44932065,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,44932065)
	e1:SetTarget(c44932065.thtg)
	e1:SetOperation(c44932065.thop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡在墓地存在，场上的怪兽有捕食指示物放置中的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44932065,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,44932065+o)
	e2:SetCondition(c44932065.spcon)
	e2:SetTarget(c44932065.sptg)
	e2:SetOperation(c44932065.spop)
	c:RegisterEffect(e2)
end
-- 检索过滤器，用于筛选「捕食植物」怪兽且不是自身且能加入手牌的卡片
function c44932065.thfilter(c)
	return c:IsSetCard(0x10f3) and c:IsType(TYPE_MONSTER) and not c:IsCode(44932065) and c:IsAbleToHand()
end
-- 效果①的发动时的处理函数，检查是否满足发动条件并设置操作信息
function c44932065.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「捕食植物」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44932065.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动处理函数，选择并把符合条件的卡加入手牌
function c44932065.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c44932065.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 特殊召唤条件过滤器，用于筛选场上存在捕食指示物的怪兽
function c44932065.cfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 效果②的发动条件函数，检查场上是否存在放置了捕食指示物的怪兽
function c44932065.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在放置了捕食指示物的怪兽
	return Duel.IsExistingMatchingCard(c44932065.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果②的发动时的处理函数，检查是否满足发动条件并设置操作信息
function c44932065.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的发动处理函数，特殊召唤此卡并设置离开场上的处理
function c44932065.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否可以特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 特殊召唤后设置此卡离开场上时被除外的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
