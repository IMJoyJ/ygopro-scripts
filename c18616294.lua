--グレイレイヤー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放，把手卡1只机械族怪兽给对方观看才能发动。和给人观看的怪兽属性不同的1只机械族怪兽从卡组加入手卡。这个效果把攻击力1200以下的怪兽加入手卡的场合，可以再从手卡把1只机械族怪兽特殊召唤。
-- ②：这张卡在墓地存在的状态，自己怪兽被效果破坏的场合，把这张卡除外才能发动。场上1张卡破坏。
local s,id,o=GetID()
-- 注册卡片的初始化效果，包含解放自身并展示机械族怪兽进行检索和后续特殊召唤的效果，以及自己怪兽被效果破坏时除外自身破坏场上卡片的效果
function s.initial_effect(c)
	-- ①：把这张卡解放，把手卡1只机械族怪兽给对方观看才能发动。和给人观看的怪兽属性不同的1只机械族怪兽从卡组加入手卡。这个效果把攻击力1200以下的怪兽加入手卡的场合，可以再从手卡把1只机械族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己怪兽被效果破坏的场合，把这张卡除外才能发动。场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	-- 设定效果发动的代价：将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 展示怪兽过滤条件：手牌中未公开的机械族怪兽，并且卡组中存在与其属性不同的可检索机械族怪兽
function s.cfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and not c:IsPublic()
		-- 判断卡组中是否存在与展示怪兽属性不同的机械族怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- 检索卡片过滤条件：与展示卡属性不同的机械族怪兽，且可以加入手卡
function s.thfilter(c,att)
	return c:IsRace(RACE_MACHINE) and not c:IsAttribute(att)
		and c:IsAbleToHand()
end
-- 检索效果发动代价的合法性判定：检查自身是否可以被解放，并且手牌中是否存在可以用于展示的合适机械族怪兽
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 判断玩家手牌中是否存在可以展示的机械族怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 将自身解放作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 提示玩家选择给对方观看的手牌怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择1只手牌中需要展示给对方看的机械族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	-- 将选择的怪兽给对方玩家进行确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切展示卡片玩家的手牌
	Duel.ShuffleHand(tp)
	e:SetLabel(g:GetFirst():GetAttribute())
end
-- 检索效果发动的目标判定与准备：检查代价是否支付，并设置连锁操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置连锁的操作信息：预计将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 追加特召效果的怪兽过滤条件：手牌中可以被特殊召唤的机械族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索效果的具体处理：从卡组检索与展示属性不同的机械族怪兽加入手卡；若加入怪兽的攻击力在1200以下且满足特殊召唤条件，可选择从手牌特召1只机械族怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1只与展示卡片属性不同的机械族怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片给对方确认
		Duel.ConfirmCards(1-tp,g)
		if g:GetFirst():IsAttackBelow(1200)
			-- 判定自己主要怪兽区域是否有可用的空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手牌中是否存在可以特殊召唤的机械族怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 若满足特召条件，询问玩家是否进行特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤与之前的检索不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择手牌中需要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家选择1只手牌中的机械族怪兽进行特殊召唤
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 洗切选择特殊召唤后玩家的手牌
			Duel.ShuffleHand(tp)
			-- 将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 破坏判定过滤条件：自己被效果破坏的怪兽卡
function s.cfilter2(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and (not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsType(TYPE_MONSTER)
		or c:GetPreviousTypeOnField()&TYPE_MONSTER~=0)
end
-- 破坏效果的发动条件判定：这张卡已在墓地存在，且自己场上或持有的怪兽因效果被破坏
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter2,1,nil,tp)
end
-- 破坏效果的发动合法性判定与准备：检查场上是否存在可以被破坏的卡，并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置连锁的操作信息：预计破坏场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的具体处理：选择场上1张卡并将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择需要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上的1张卡片
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 手动为被选中的卡片显示选定动画效果
		Duel.HintSelection(g)
		-- 因效果破坏选中的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
