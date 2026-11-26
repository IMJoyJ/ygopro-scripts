--天幻の龍輪
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把自己场上1只幻龙族怪兽解放才能发动。从卡组把1只幻龙族怪兽加入手卡。把效果怪兽以外的怪兽解放来把这张卡发动的场合，也能不加入手卡把效果无效特殊召唤。
-- ②：自己场上有效果怪兽以外的表侧表示怪兽存在的场合，自己主要阶段把墓地的这张卡除外才能发动。从卡组把1张「天威」卡加入手卡。
function c51684157.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：把自己场上1只幻龙族怪兽解放才能发动。从卡组把1只幻龙族怪兽加入手卡。把效果怪兽以外的怪兽解放来把这张卡发动的场合，也能不加入手卡特殊召唤。
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
	-- 设置效果②的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51684157.thtg)
	e2:SetOperation(c51684157.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选己方场上可解放的幻龙族怪兽，且解放后卡组中存在可加入手卡的幻龙族怪兽（若解放非效果怪兽，也可检查卡组存在可特召的幻龙族怪兽及离场后怪兽区空位）
function c51684157.filter(c,e,tp,check)
	-- 检查待解放怪兽是否为幻龙族，且卡组中是否存在可加入手卡的幻龙族怪兽
	return c:IsRace(RACE_WYRM) and (Duel.IsExistingMatchingCard(c51684157.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		or (check and not c:IsType(TYPE_EFFECT)
		-- 或者检查若解放非效果怪兽，卡组中是否存在可加入手卡或可特殊召唤的幻龙族怪兽
		and Duel.IsExistingMatchingCard(c51684157.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true)
		-- 且将该怪兽从己方场上解放后，己方主要怪兽区仍有至少1个可用空位
		and Duel.GetMZoneCount(tp,c)>0))
end
-- 过滤函数（Target检测用）：筛选卡组中幻龙族怪兽，要求可加入手卡或在check为真时可特殊召唤
function c51684157.thfilter(c,e,tp,check)
	return c:IsRace(RACE_WYRM) and (c:IsAbleToHand() or (check and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 过滤函数（效果处理用）：筛选卡组中幻龙族怪兽，要求可加入手卡或在check为真且场上仍有空位ft>0时可特殊召唤
function c51684157.thfilter2(c,e,tp,ft,check)
	return c:IsRace(RACE_WYRM) and (c:IsAbleToHand() or (check and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0))
end
-- 效果①的Cost函数：检查并选择己方场上1只符合条件的幻龙族怪兽解放，若解放的是非效果怪兽则在Label记录标记1
function c51684157.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 发动检测时确认己方场上存在至少1只满足条件的幻龙族怪兽可以解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c51684157.filter,1,nil,e,tp,true) end
	-- 向己方玩家发送选择要解放的怪兽提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从己方场上选择1只符合条件的幻龙族怪兽用于解放
	local g=Duel.SelectReleaseGroup(tp,c51684157.filter,1,1,nil,e,tp,true)
	if not g:GetFirst():IsType(TYPE_EFFECT) then e:SetLabel(100,1) end
	-- 将选中的幻龙族怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 效果①的Target函数：验证已通过Cost检查或卡组有可检索的幻龙族怪兽，并根据是否解放了非效果怪兽动态设置效果分类与操作信息
function c51684157.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=true
	local l1,l2=e:GetLabel()
	if chk==0 then
		if l1~=100 then check=false end
		e:SetLabel(0,0)
		-- 发动检测时确认己方卡组中存在至少1只满足检索或特召条件的幻龙族怪兽
		return Duel.IsExistingMatchingCard(c51684157.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
	if l2==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		-- 当解放的不是非效果怪兽时，设置从己方卡组把1张卡加入手卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	end
end
-- 效果①的Operation函数：从卡组选1只幻龙族怪兽加入手卡；若发动时解放了非效果怪兽，也可选择将其效果无效并表侧特殊召唤
function c51684157.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local check=false
	local l1,l2=e:GetLabel()
	if l2==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then check=true end
	-- 获取己方主要怪兽区当前的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 向己方玩家发送选择要操作的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从己方卡组中选择1只符合条件的幻龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c51684157.thfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft,check)
	local tc=g:GetFirst()
	if tc then
		if not check or (tc:IsAbleToHand() and (ft<=0 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 或者玩家在加入手卡(1190)与特殊召唤(1152)两个选项之间选择了加入手卡
			or Duel.SelectOption(tp,1190,1152)==0)) then
			-- 以效果将选中的幻龙族怪兽加入持有者（己方）手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家公开确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 以分步特殊召唤方式将选中的幻龙族怪兽表侧特殊召唤到己方场上
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 效果无效（针对怪兽本身的效果无效）
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 效果无效（针对发动与适用中的效果无效）
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
			-- 统一完成本次分步特殊召唤流程并触发相关时点
			Duel.SpecialSummonComplete()
		end
	end
end
-- 过滤函数：筛选场上表侧表示的非效果怪兽
function c51684157.ffilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT)
end
-- 效果②的Condition函数：检查己方怪兽区是否存在表侧表示的非效果怪兽
function c51684157.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方怪兽区是否存在至少1只表侧表示的非效果怪兽
	return Duel.IsExistingMatchingCard(c51684157.ffilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：筛选卡组中属于「天威」(0x12c)字段且可加入手卡的卡片
function c51684157.cfilter(c)
	return c:IsSetCard(0x12c) and c:IsAbleToHand()
end
-- 效果②的Target函数：检测己方卡组中存在可检索的「天威」卡，并设置从卡组把1张卡加入手卡的操作信息
function c51684157.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方卡组中存在至少1张可加入手卡的「天威」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c51684157.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从己方卡组把1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的Operation函数：从己方卡组选择1张「天威」卡加入手卡并向对方确认
function c51684157.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方玩家发送选择要加入手卡的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张可加入手卡的「天威」卡
	local g=Duel.SelectMatchingCard(tp,c51684157.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果将选中的「天威」卡加入持有者（己方）手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的「天威」卡
		Duel.ConfirmCards(1-tp,g)
	end
end
