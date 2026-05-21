--ジェット・シンクロン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1只「废品」怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c9742784.initial_effect(c)
	-- ①：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1只「废品」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,9742784)
	e1:SetCondition(c9742784.thcon)
	e1:SetTarget(c9742784.thtg)
	e1:SetOperation(c9742784.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把1张手卡送去墓地才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,9742784)
	e2:SetCost(c9742784.spcost)
	e2:SetTarget(c9742784.sptg)
	e2:SetOperation(c9742784.spop)
	c:RegisterEffect(e2)
end
-- 判断发动条件：这张卡作为同调素材送去墓地
function c9742784.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤条件：卡组中的「废品」怪兽
function c9742784.filter(c)
	return c:IsSetCard(0x43) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果1的发动准备（检查卡组是否存在符合条件的卡并设置操作信息）
function c9742784.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可以加入手卡的「废品」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9742784.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1的处理：从卡组将1只「废品」怪兽加入手卡并给对方确认
function c9742784.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只符合条件的「废品」怪兽
	local g=Duel.SelectMatchingCard(tp,c9742784.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果2的发动代价：将1张手卡送去墓地
function c9742784.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 效果2的发动准备（检查怪兽区域空位及自身是否能特殊召唤）
function c9742784.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果2的处理：将自身特殊召唤，并添加离场时除外的效果
function c9742784.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其以表侧表示特殊召唤
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
end
