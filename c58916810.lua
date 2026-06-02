--クラック・ブリッツクリーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方回合，对方把场上的怪兽的效果发动时，把手卡的这张卡给对方观看才能发动。那只怪兽破坏，从手卡把1只雷族怪兽特殊召唤。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把1张「雷盟」魔法·陷阱卡送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果注册
function s.initial_effect(c)
	-- ①：对方回合，对方把场上的怪兽的效果发动时，把手卡的这张卡给对方观看才能发动。那只怪兽破坏，从手卡把1只雷族怪兽特殊召唤。这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把1张「雷盟」魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 效果①的触发条件函数，检查是否对方在场上发动怪兽效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re)
		-- 检查发动的效果是否为怪兽效果且当前为对方回合
		and re:IsActiveType(TYPE_MONSTER) and Duel.GetTurnPlayer()==1-tp
		and rp==1-tp
end
-- 效果①的cost函数，检查并确认这张卡在手卡且未给对方观看
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果①的特殊召唤过滤函数，筛选手卡中的雷族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的target函数，检查是否有可用区域及手卡是否有可召唤的怪兽，并设置破坏的连锁操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当该卡所连锁的怪兽离场后自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,re:GetHandler())>0
		-- 检查手卡中是否存在满足条件的雷族怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置破坏操作信息，表示破坏该发动效果的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 效果①的operation函数，处理怪兽破坏、从手卡特殊召唤雷族怪兽并注册特殊召唤限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToChain(ev) and re:GetHandler():IsType(TYPE_MONSTER)
		and re:GetHandler():IsLocation(LOCATION_MZONE)
		-- 检查该怪兽被效果破坏成功且自己场上仍有空余怪兽区域
		and Duel.Destroy(re:GetHandler(),REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1张满足条件的雷族怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 洗切玩家手牌
			Duel.ShuffleHand(tp)
			-- 特殊召唤选中的雷族怪兽
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是从手卡中不能把效果怪兽特殊召唤。②：这张卡在怪兽区域存在的状态，这张卡以外的卡被效果破坏的场合才能发动。从卡组把1张「雷盟」魔法·陷阱卡送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册不能从手卡以外特殊召唤效果怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤函数，限制自己不能特殊召唤手卡以外的效果怪兽
function s.splimit(e,c)
	return c:IsType(TYPE_EFFECT) and not c:IsLocation(LOCATION_HAND)
end
-- 效果②的被破坏卡片的过滤条件，筛选因效果破坏的卡片
function s.cfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- 效果②的触发条件函数，检查场上是否有除这张卡以外的卡被效果破坏
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler())
end
-- 效果②的送入墓地过滤函数，筛选卡组中的「雷盟」魔法·陷阱卡
function s.tgfilter(c)
	return c:IsSetCard(0x1df) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 效果②的target函数，检查卡组是否有满足条件的卡并设置送入墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以送去墓地的「雷盟」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置送入墓地操作信息，表示从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的operation函数，处理从卡组选择1张「雷盟」魔法·陷阱卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足条件的「雷盟」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
