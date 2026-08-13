--見えざる手ヤドエル
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。这张卡回到卡组。那之后，从卡组把1张「不可见之手」魔法·陷阱卡加入手卡。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：这张卡被送去墓地的场合，以自己墓地1张「不可见之手」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
local s,id,o=GetID()
-- 为整个卡片注册三个效果：e1为①检索效果（手卡展示自身回卡组并检索「不可见之手」魔陷），e2为②战斗抗性效果（与怪兽战斗时双方不会被战破），e3为③墓地盖放效果（被送去墓地时盖放墓地1张「不可见之手」魔陷），各自设置对应的类型、范围、次数限制、条件和处理函数。
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。这张卡回到卡组。那之后，从卡组把1张「不可见之手」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以自己墓地1张「不可见之手」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价判定：检查手卡的这张卡当前为非公开状态，满足‘把手卡的这张卡给对方观看’的展示条件。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检索过滤条件：满足卡名包含「不可见之手」（设定字段0x1d3）的魔法·陷阱卡，并且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1d3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动条件判定：卡组存在1张以上可检索的「不可见之手」魔陷，且这张卡自身能够回到卡组，才能发动。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组是否存在至少1张满足s.thfilter过滤条件的卡，作为发动①效果的先决条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and c:IsAbleToDeck() end
	-- 设置操作信息：本次处理预计将1张卡从卡组加入手卡（用于配合将卡组洗回等连锁检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：若这张卡仍与连锁相关，将其送回卡组并洗牌，成功且位于卡组后，选择1张「不可见之手」魔陷加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与当前连锁相关，并且被成功送回卡组（返回非0表示操作成功）。
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_DECK) then
		-- 给当前玩家显示选择提示，要求选择1张要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足s.thfilter条件的「不可见之手」魔陷。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果，使后续加入手卡的处理与之前的回卡组处理视为不同时处理，以对应‘那之后’的时点。
			Duel.BreakEffect()
			-- 将选择的卡加入持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对手确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的适用对象判定：返回战斗的这两只怪兽（此卡自身以及此卡的战斗对象），使它们都不会被那次战斗破坏。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 墓地盖放过滤条件：满足「不可见之手」字段的魔法·陷阱卡，且当前可以被盖放。
function s.setfilter(c)
	return c:IsSetCard(0x1d3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ③效果的发动判定与选对象：确认墓地存在1张可盖放的「不可见之手」魔陷，选择其中1张作为对象，并设置操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.setfilter(chkc) end
	-- 检查墓地是否存在至少1张满足s.setfilter条件的卡，作为③效果的发动条件。
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给当前玩家显示选择提示，要求选择1张要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地选择1张满足条件的「不可见之手」魔陷作为对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次处理会使对象离开墓地，用于与王家长眠之谷等涉及墓地效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ③效果的处理：取得对象卡，若对象仍与连锁相关且不受王家长眠之谷影响，则将其盖放在自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍与当前连锁相关，且没有受到王家长眠之谷等效果影响而不能从墓地移动。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象卡以里侧表示盖放在自己场上。
		Duel.SSet(tp,tc)
	end
end
