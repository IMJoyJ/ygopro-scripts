--エミ・ブリッツクリーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合，把这张卡给对方观看，以场上1张卡为对象才能发动。那张卡破坏，从手卡把1只雷族怪兽特殊召唤。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把1张「雷盟」陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的入口函数
function s.initial_effect(c)
	-- ①：这张卡用抽卡以外的方法加入手卡的场合，把这张卡给对方观看，以场上1张卡为对象才能发动。那张卡破坏，从手卡把1只雷族怪兽特殊召唤。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把1张「雷盟」陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 发动条件：这张卡用抽卡以外的方法加入手卡的场合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- 发动代价：把这张卡给对方观看
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤条件：场上的卡，且该卡被破坏后能满足特召所需的怪兽区域空位条件
function s.desfilter(c,e,tp)
	-- 判断目标卡片离开场上后是否能留出至少1个可用的怪兽区域
	return Duel.GetMZoneCount(tp,c)>0
end
-- 过滤条件：手卡中的雷族怪兽且可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果靶向：选择场上1张符合条件的卡作为对象，设置破坏和特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.desfilter(chkc,e,tp) end
	-- 判断场上是否存在符合被破坏条件的卡片作为效果的对象
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e,tp)
		-- 检查手卡中是否存在雷族怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e,tp)
	-- 设置操作信息：破坏选中的对象卡（1张）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：从手卡特殊召唤1只怪兽（1只）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：破坏选中的对象卡并从手卡特殊召唤雷族怪兽，同时施加本回合的特殊召唤限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsOnField()
		-- 如果成功将对象卡破坏，且自己场上依然存在空怪兽区域
		and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家选择手卡中1只符合条件的雷族怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 洗切玩家的手卡
			Duel.ShuffleHand(tp)
			-- 将选中的雷族怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册该回合的全局特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤效果怪兽（除非从手卡特殊召唤）
function s.splimit(e,c)
	return c:IsType(TYPE_EFFECT) and not c:IsLocation(LOCATION_HAND)
end
-- 过滤条件：因效果而被破坏的卡
function s.cfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- 发动条件：这张卡以外的卡被效果破坏的场合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
-- 过滤条件：卡组中的「雷盟」陷阱卡且可以加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1df) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果靶向：确认卡组存在符合检索条件的卡，并设置检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在符合条件的「雷盟」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组把1张「雷盟」陷阱卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择卡组中1张符合条件的「雷盟」陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的陷阱卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
