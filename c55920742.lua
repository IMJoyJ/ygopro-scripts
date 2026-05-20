--No－P.U.N.K.フォクシー・チューン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只「朋克」怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：把手卡·场上的这张卡送去墓地才能发动。选自己1张手卡送去墓地，从卡组把1只8星以外的「朋克」怪兽特殊召唤。
-- ③：1回合1次，这张卡战斗破坏对方怪兽时才能发动。自己基本分回复那只怪兽的原本攻击力的数值。
function c55920742.initial_effect(c)
	-- ①：把自己场上1只「朋克」怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55920742,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,55920742)
	e1:SetCost(c55920742.spcost)
	e1:SetTarget(c55920742.sptg)
	e1:SetOperation(c55920742.spop)
	c:RegisterEffect(e1)
	-- ②：把手卡·场上的这张卡送去墓地才能发动。选自己1张手卡送去墓地，从卡组把1只8星以外的「朋克」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55920742,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,55920743)
	e2:SetCost(c55920742.spcost1)
	e2:SetTarget(c55920742.sptg1)
	e2:SetOperation(c55920742.spop1)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这张卡战斗破坏对方怪兽时才能发动。自己基本分回复那只怪兽的原本攻击力的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55920742,2))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1)
	-- 设置效果③的发动条件为这张卡战斗破坏对方怪兽时。
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c55920742.rctg)
	e3:SetOperation(c55920742.rcop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数：用于筛选场上可解放的「朋克」怪兽，且解放后能留出可用的怪兽区域。
function c55920742.rfilter(c,tp)
	-- 检查该卡解放后是否能让玩家场上留出至少1个怪兽区域，且该卡是「朋克」怪兽（若是场上的怪兽则必须表侧表示，若是自己控制的里侧表示怪兽也可以）。
	return Duel.GetMZoneCount(tp,c)>0 and c:IsSetCard(0x171) and (c:IsFaceup() or c:IsControler(tp))
end
-- 定义效果①的发动代价函数：解放自己场上1只「朋克」怪兽。
function c55920742.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：检查自己场上是否存在至少1只满足过滤条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c55920742.rfilter,1,nil,tp) end
	-- 发送提示信息：请选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只满足过滤条件的可解放怪兽。
	local g=Duel.SelectReleaseGroup(tp,c55920742.rfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 定义效果①的发动准备函数：检查自身是否能特殊召唤，并设置特殊召唤的操作信息。
function c55920742.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含特殊召唤自身1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果①的效果处理函数：将这张卡从手卡特殊召唤。
function c55920742.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义效果②的发动代价函数：把手卡·场上的这张卡送去墓地。
function c55920742.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义过滤函数：用于检索卡组中8星以外且可以特殊召唤的「朋克」怪兽。
function c55920742.spfilter(c,e,tp)
	return c:IsSetCard(0x171) and not c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果②的发动准备函数：检查怪兽区域空位、卡组中是否存在可特召的怪兽以及手卡中是否有可送去墓地的卡。
function c55920742.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：检查这张卡离开场上后，自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查阶段：检查卡组中是否存在至少1只满足过滤条件的「朋克」怪兽。
		and Duel.IsExistingMatchingCard(c55920742.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查阶段：检查手卡中是否存在至少1张可以送去墓地的卡（不含这张卡自身）。
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置特殊召唤的操作信息，包含从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果②的效果处理函数：选自己1张手卡送去墓地，并从卡组把1只8星以外的「朋克」怪兽特殊召唤。
function c55920742.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示信息：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择手卡中1张可以送去墓地的卡。
	local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil)
	if tg:GetCount()>0 then
		local tc=tg:GetFirst()
		-- 将选中的手卡送去墓地，若送去墓地失败或卡未到达墓地，则终止效果处理。
		if Duel.SendtoGrave(tg,REASON_EFFECT)==0 or not tc:IsLocation(LOCATION_GRAVE) then return end
		-- 检查自己场上是否有可用的怪兽区域，若无则终止效果处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 发送提示信息：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足过滤条件的「朋克」怪兽。
		local g=Duel.SelectMatchingCard(tp,c55920742.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己的怪兽区域。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义效果③的发动准备函数：获取被战斗破坏怪兽的原本攻击力，并设置回复生命值的操作信息。
function c55920742.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local dam=bc:GetBaseAttack()
	-- 设置回复生命值的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置回复生命值的数值为被破坏怪兽的原本攻击力。
	Duel.SetTargetParam(dam)
	-- 设置回复生命值的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,dam)
end
-- 定义效果③的效果处理函数：使自己回复被破坏怪兽原本攻击力数值的生命值。
function c55920742.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复生命值的处理。
	Duel.Recover(p,d,REASON_EFFECT)
end
