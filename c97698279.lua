--竜騎兵ガーゴイルⅡ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把自己场上1张表侧表示的「百夫长骑士」卡送去墓地才能发动。这张卡从手卡特殊召唤。这个回合，自己不能把「龙骑兵 石像怪2」特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。这张卡加入手卡。
-- ③：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。那之后，可以让这张卡的等级下降4星。
local s,id,o=GetID()
-- 初始化卡片效果（注册①②③效果）
function s.initial_effect(c)
	-- ①：把自己场上1张表侧表示的「百夫长骑士」卡送去墓地才能发动。这张卡从手卡特殊召唤。这个回合，自己不能把「龙骑兵 石像怪2」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。那之后，可以让这张卡的等级下降4星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id+o*2)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示、送去墓地后能腾出怪兽区域、可以作为Cost送去墓地的「百夫长骑士」卡
function s.cfilter(c,tp)
	-- 检查卡片是否表侧表示、送去墓地后是否能留出可用的怪兽区域、是否能作为Cost送去墓地
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGraveAsCost()
		and c:IsSetCard(0x1a2)
end
-- 效果①的发动代价（Cost）处理：将自己场上1张表侧表示的「百夫长骑士」卡送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足送墓条件的「百夫长骑士」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张满足条件的「百夫长骑士」卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选中的卡作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动准备（Target）处理：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（Operation）：特殊召唤自身，并添加本回合不能特殊召唤「龙骑兵 石像怪2」的玩家限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从手卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不能把「龙骑兵 石像怪2」特殊召唤。②：这张卡作为同调素材送去墓地的场合才能发动。这张卡加入手卡。③：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。那之后，可以让这张卡的等级下降4星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制特殊召唤的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的卡片过滤：卡名与本卡相同（「龙骑兵 石像怪2」）
function s.splimit(e,c)
	return c:IsCode(id)
end
-- 效果②的发动条件：这张卡在墓地存在，且作为同调素材送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果②的发动准备（Target）处理：检查自身是否能加入手卡，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将自身加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（Operation）：将自身加入手卡并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 效果③的发动条件：在自己或对方的主要阶段，且这张卡当作永续陷阱卡使用（在魔法与陷阱区域表侧表示存在）
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 效果③的发动准备（Target）处理：检查怪兽区域是否有空位，以及玩家是否能特殊召唤该怪兽，并设置特殊召唤的操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能特殊召唤这张卡（作为暗属性、龙族、8星、攻击力2000/守备力3000的效果怪兽）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a2,TYPE_MONSTER+TYPE_EFFECT,2000,3000,8,RACE_DRAGON,ATTRIBUTE_DARK) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理（Operation）：特殊召唤自身，之后可以由玩家选择是否让这张卡的等级下降4星
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 成功特殊召唤自身后，若其等级在5星以上，玩家可以选择是否发动等级下降的效果
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsLevelAbove(5) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否下降等级？"
		-- 中断当前效果，使后续的等级下降处理与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 那之后，可以让这张卡的等级下降4星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-4)
		c:RegisterEffect(e1)
	end
end
