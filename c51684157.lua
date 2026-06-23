--天幻の龍輪
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把自己场上1只幻龙族怪兽解放才能发动。从卡组把1只幻龙族怪兽加入手卡。把效果怪兽以外的怪兽解放来把这张卡发动的场合，也能不加入手卡把效果无效特殊召唤。
-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「天威」卡加入手卡。
function c51684157.initial_effect(c)
	-- ①：把自己场上1只幻龙族怪兽解放才能发动。从卡组把1只幻龙族怪兽加入手卡。把效果怪兽以外的怪兽解放来把这张卡发动的场合，也能不加入手卡把效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51684157,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,51684157)
	e1:SetCost(c51684157.cost)
	e1:SetTarget(c51684157.target)
	e1:SetOperation(c51684157.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「天威」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51684157,1))
	e2:SetCategory(CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51684157)
	e2:SetCondition(c51684157.thcon)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51684157.thtg)
	e2:SetOperation(c51684157.thop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的幻龙族怪兽，用于判断是否可以发动效果①
function c51684157.filter(c,e,tp,check)
	-- 检查卡组中是否存在可加入手牌的幻龙族怪兽
	return c:IsRace(RACE_WYRM) and (Duel.IsExistingMatchingCard(c51684157.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		or (check and not c:IsType(TYPE_EFFECT)
		-- 检查卡组中是否存在可特殊召唤的幻龙族怪兽且场上存在可用怪兽区
		and Duel.IsExistingMatchingCard(c51684157.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true)
		-- 检查场上是否存在可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0))
end
-- 过滤满足条件的幻龙族怪兽，用于选择目标
function c51684157.thfilter(c,e,tp,check)
	return c:IsRace(RACE_WYRM) and (c:IsAbleToHand() or (check and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 过滤满足条件的幻龙族怪兽，用于选择目标并考虑是否能特殊召唤
function c51684157.thfilter2(c,e,tp,ft,check)
	return c:IsRace(RACE_WYRM) and (c:IsAbleToHand() or (check and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0))
end
-- 效果①的发动费用处理函数，需要解放一只幻龙族怪兽
function c51684157.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 检查是否可以解放一只幻龙族怪兽作为费用
	if chk==0 then return Duel.CheckReleaseGroup(tp,c51684157.filter,1,nil,e,tp,true) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择一只幻龙族怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c51684157.filter,1,1,nil,e,tp,true)
	if not g:GetFirst():IsType(TYPE_EFFECT) then e:SetLabel(100,1) end
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 效果①的目标设定函数，根据是否满足特殊召唤条件设置处理类别
function c51684157.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=true
	local l1,l2=e:GetLabel()
	if chk==0 then
		if l1~=100 then check=false end
		e:SetLabel(0,0)
		-- 检查卡组中是否存在满足条件的幻龙族怪兽
		return Duel.IsExistingMatchingCard(c51684157.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
	if l2==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 设置连锁操作信息为将一张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	end
end
-- 效果①的发动处理函数，根据选择决定是加入手牌还是特殊召唤
function c51684157.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local check=false
	local l1,l2=e:GetLabel()
	if l2==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then check=true end
	-- 获取玩家场上可用的怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择一张幻龙族怪兽进行处理
	local g=Duel.SelectMatchingCard(tp,c51684157.thfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft,check)
	local tc=g:GetFirst()
	if tc then
		if not check or (tc:IsAbleToHand() and (ft<=0 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 当无法特殊召唤时，选择将卡加入手牌
			or Duel.SelectOption(tp,1190,1152)==0)) then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方看到该卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 尝试特殊召唤选中的卡
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 使特殊召唤的卡无效化
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 使特殊召唤的卡的效果无效化
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
			-- 完成特殊召唤流程
			Duel.SpecialSummonComplete()
		end
	end
end
-- 过滤场上表侧表示且非效果怪兽的怪兽
function c51684157.ffilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT)
end
-- 效果②的发动条件函数，检查自己场上是否存在表侧表示的非效果怪兽
function c51684157.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的非效果怪兽
	return Duel.IsExistingMatchingCard(c51684157.ffilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤「天威」卡，用于选择目标
function c51684157.cfilter(c)
	return c:IsSetCard(0x12c) and c:IsAbleToHand()
end
-- 效果②的目标设定函数，检查卡组中是否存在「天威」卡
function c51684157.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「天威」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c51684157.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为将一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的发动处理函数，从卡组选择一张「天威」卡加入手牌
function c51684157.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张「天威」卡
	local g=Duel.SelectMatchingCard(tp,c51684157.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到该卡
		Duel.ConfirmCards(1-tp,g)
	end
end
