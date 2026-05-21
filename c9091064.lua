--VS 蛟龍
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：自己为让「征服斗魂」卡的效果发动而把手卡给人观看的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●炎：场上1只怪兽的表示形式变更。
-- ●炎·炎：从卡组把「征服斗魂 蛟龙」以外的1张「征服斗魂」卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤效果、展示1只炎属性怪兽改变表示形式效果、以及展示2只炎属性怪兽检索「征服斗魂」卡的效果。
function s.initial_effect(c)
	-- ①：自己为让「征服斗魂」卡的效果发动而把手卡给人观看的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●炎：场上1只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"展示1只炎属性的怪兽"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetLabel(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))  --"展示2只炎属性的怪兽"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetLabel(2)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 检查触发事件是否为自己为了发动「征服斗魂」卡的效果而将手牌中的卡作为Cost展示。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) and r&REASON_COST>0 and re:IsActivated()
		and re:GetHandler():IsSetCard(0x195) and rp==tp
end
-- 特殊召唤效果的发动准备与可行性检测函数，包含怪兽区域空格、自身是否可特殊召唤，以及同一连锁限制的检测。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查当前连锁中是否尚未发动过该卡名的任何效果（用于落实“同一连锁上不能发动”的限制）。
		and Duel.GetFlagEffect(tp,id)==0 end
	-- 在当前连锁中注册该卡名已发动的标记，用于落实“同一连锁上不能发动”的限制。
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理函数，若自身仍在手牌则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手牌中未公开的炎属性怪兽。
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- 效果发动的Cost处理函数，要求玩家展示对应数量的手牌炎属性怪兽，并触发自定义的展示事件。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 检查手牌中是否存在足够数量 of 未公开炎属性怪兽作为Cost。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,ct,nil) end
	-- 提示玩家选择要给对方确认（展示）的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择指定数量的手牌炎属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,ct,ct,nil)
	-- 将选中的怪兽给对方玩家确认（展示）。
	Duel.ConfirmCards(1-tp,g)
	-- 触发自定义的展示手牌事件，用于触发此卡或其他「征服斗魂」卡的手牌特殊召唤效果。
	Duel.RaiseEvent(g,EVENT_CUSTOM+id,e,REASON_COST,tp,tp,0)
	-- 重新洗切手牌以重置手牌的公开状态。
	Duel.ShuffleHand(tp)
end
-- 改变表示形式效果的发动准备与可行性检测函数，包含场上是否存在可改变表示形式的怪兽，以及同一连锁限制的检测。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有可以改变表示形式的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查场上是否存在可改变表示形式的怪兽，且当前连锁中未发动过该卡名的效果。
	if chk==0 then return #g>0 and Duel.GetFlagEffect(tp,id)==0 end
	-- 在当前连锁中注册该卡名已发动的标记，用于落实“同一连锁上不能发动”的限制。
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置表示形式变更的操作信息，表示将改变1只怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 改变表示形式效果的处理函数，让玩家选择场上1只怪兽并改变其表示形式。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择场上1只可以改变表示形式的怪兽。
	local tc=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		-- 改变目标怪兽的表示形式（表侧攻击变表侧守备，里侧守备变表侧守备，表侧守备变表侧攻击等）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 过滤卡组中除「征服斗魂 蛟龙」以外的「征服斗魂」卡片。
function s.filter(c)
	return c:IsSetCard(0x195) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 检索效果的发动准备与可行性检测函数，包含卡组中是否存在可检索的卡，以及同一连锁限制的检测。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「征服斗魂」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		-- 检查当前连锁中是否尚未发动过该卡名的任何效果（用于落实“同一连锁上不能发动”的限制）。
		and Duel.GetFlagEffect(tp,id)==0 end
	-- 在当前连锁中注册该卡名已发动的标记，用于落实“同一连锁上不能发动”的限制。
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 设置检索的操作信息，表示将从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，从卡组将1张「征服斗魂」卡加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「征服斗魂」卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
