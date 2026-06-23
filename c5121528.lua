--巨大戦艦 デリンジャー・コア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只其他的「巨大战舰」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。那之后，给这张卡放置3个指示物。
-- ②：自己·对方的主要阶段，可以把这张卡1个指示物取除，从以下效果选择1个发动。
-- ●把1张「头目连战」或者有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
-- ●从自己墓地把1只9星以下的「巨大战舰」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：①特殊召唤并放置指示物；②主要阶段时消耗指示物选择检索或特殊召唤效果
function s.initial_effect(c)
	-- 记录该卡具有「头目连战」的卡名信息，用于后续效果判断
	aux.AddCodeList(c,66947414)
	c:EnableCounterPermit(0x1f)
	-- 效果①：把手卡1只其他的「巨大战舰」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。那之后，给这张卡放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果②：自己·对方的主要阶段，可以把这张卡1个指示物取除，从以下效果选择1个发动。●把1张「头目连战」或者有那个卡名记述的魔法·陷阱卡从卡组加入手卡。●从自己墓地把1只9星以下的「巨大战舰」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选择效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查手牌中是否含有其他「巨大战舰」怪兽且未公开
function s.cfilter(c)
	return c:IsSetCard(0x15) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果①的费用处理：选择并确认一张手牌中的其他「巨大战舰」怪兽，然后洗切手牌
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果①的费用条件：是否存在符合条件的手牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择符合条件的手牌
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 效果①的目标处理：判断是否可以特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以特殊召唤自身
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果①的处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理过程：特殊召唤自身并放置3个指示物
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain()
		-- 判断是否成功特殊召唤自身
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		and c:IsCanAddCounter(0x1f,3) then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		c:AddCounter(0x1f,3)
	end
end
-- 效果②的发动条件：必须在主要阶段时才能发动
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 效果②的费用处理：移除自身1个指示物作为费用
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1f,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1f,1,REASON_COST)
end
-- 检索过滤函数：检查卡组中是否有「头目连战」或其记述的魔法·陷阱卡且可加入手牌
function s.thfilter(c)
	-- 判断是否为「头目连战」或其记述的魔法·陷阱卡且可加入手牌
	return (c:IsCode(66947414) or aux.IsCodeOrListed(c,66947414) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- 特殊召唤过滤函数：检查墓地中是否有9星以下的「巨大战舰」怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x15) and c:IsLevelBelow(9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标处理：判断是否可以选择检索或特殊召唤效果
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在符合条件的魔法·陷阱卡
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 判断自己场上是否有空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 选择效果选项
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"检索效果"
			{b2,aux.Stringid(id,3),2})  --"特殊召唤"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		end
		-- 设置效果②的处理信息：将卡组中的卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置效果②的处理信息：特殊召唤墓地中的怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 效果②的处理过程：根据选择的效果进行检索或特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择符合条件的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认所选的卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择符合条件的墓地怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
