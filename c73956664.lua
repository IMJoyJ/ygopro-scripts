--ティアラメンツ・レイノハート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「珠泪哀歌族·雷诺哈特」以外的1只「珠泪哀歌族」怪兽送去墓地。
-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤，从自己手卡选1张「珠泪哀歌族」卡送去墓地。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c73956664.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「珠泪哀歌族·雷诺哈特」以外的1只「珠泪哀歌族」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73956664,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,73956664)
	e1:SetTarget(c73956664.target)
	e1:SetOperation(c73956664.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤，从自己手卡选1张「珠泪哀歌族」卡送去墓地。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(73956664,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,73956665)
	e3:SetCondition(c73956664.spcon)
	e3:SetTarget(c73956664.sptg)
	e3:SetOperation(c73956664.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「珠泪哀歌族·雷诺哈特」以外的「珠泪哀歌族」怪兽且能送去墓地的卡片
function c73956664.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x181) and not c:IsCode(73956664) and c:IsAbleToGrave()
end
-- 效果①的发动准备，检查卡组中是否存在符合条件的卡，并设置送去墓地的操作信息
function c73956664.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「珠泪哀歌族·雷诺哈特」以外的「珠泪哀歌族」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73956664.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理，从卡组选择1张符合条件的卡送去墓地
function c73956664.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张「珠泪哀歌族·雷诺哈特」以外的「珠泪哀歌族」怪兽
	local g=Duel.SelectMatchingCard(tp,c73956664.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡因效果被送去墓地
function c73956664.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤手卡中可以送去墓地的「珠泪哀歌族」卡片
function c73956664.tgfilter2(c)
	return c:IsSetCard(0x181) and c:IsAbleToGrave()
end
-- 效果②的发动准备，检查怪兽区域是否有空位、这张卡是否能特殊召唤，以及手卡中是否有「珠泪哀歌族」卡片
function c73956664.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且检查手卡中是否存在可以送去墓地的「珠泪哀歌族」卡片
		and Duel.IsExistingMatchingCard(c73956664.tgfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置连锁的操作信息，表示该效果会将手卡的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理，将这张卡特殊召唤，并添加离场除外的约束，然后从手卡选择1张「珠泪哀歌族」卡送去墓地
function c73956664.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与连锁相关，并将其以表侧表示特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 从自己手卡选1张「珠泪哀歌族」卡送去墓地。这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从手卡选择1张「珠泪哀歌族」卡片
		local g=Duel.SelectMatchingCard(tp,c73956664.tgfilter2,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			-- 将选择的手卡因效果送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
