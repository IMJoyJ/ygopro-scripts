--ドラグニティ－レムス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，把这张卡作为同调素材的场合，不是「龙骑兵团」怪兽的同调召唤不能使用。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「龙之溪谷」加入手卡。
-- ②：自己场上有「龙骑兵团」怪兽存在的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个回合，自己不是龙族怪兽不能从额外卡组特殊召唤。
function c26577155.initial_effect(c)
	-- 记录该卡牌具有「龙之溪谷」这张卡的名称
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
-- 设置该卡不能被用作同调素材，除非是龙骑兵团卡组的怪兽
function c26577155.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x29)
end
-- 支付将此卡从手牌丢弃作为代价
function c26577155.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡从手牌丢入墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 定义检索目标为「龙之溪谷」卡
function c26577155.thfilter(c)
	return c:IsCode(62265044) and c:IsAbleToHand()
end
-- 设置效果处理时的卡组检索操作信息
function c26577155.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「龙之溪谷」
	if chk==0 then return Duel.IsExistingMatchingCard(c26577155.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的卡组检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行将「龙之溪谷」从卡组加入手牌的操作
function c26577155.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中检索符合条件的第一张「龙之溪谷」
	local tg=Duel.GetFirstMatchingCard(c26577155.thfilter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将检索到的「龙之溪谷」加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 向对手确认加入手牌的「龙之溪谷」
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 定义场上存在的龙骑兵团怪兽的过滤条件
function c26577155.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- 判断场上是否存在龙骑兵团怪兽
function c26577155.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在龙骑兵团怪兽
	return Duel.IsExistingMatchingCard(c26577155.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置特殊召唤的条件
function c26577155.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作并设置效果
function c26577155.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否可以特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置特殊召唤后离场时的重新指定去向效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 设置本回合不能从额外卡组特殊召唤非龙族怪兽的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c26577155.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制非龙族怪兽从额外卡组特殊召唤
function c26577155.splimit(e,c)
	return not c:IsRace(RACE_DRAGON) and c:IsLocation(LOCATION_EXTRA)
end
