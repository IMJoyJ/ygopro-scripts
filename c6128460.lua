--ワイトベイキング
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在墓地存在当作「白骨」使用。
-- ②：自己场上的3星以下的不死族怪兽被战斗·效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把以下怪兽合计2只加入手卡（同名卡最多1张）。那之后，选1张手卡丢弃。
-- ●「白骨」
-- ●「白骨烤王」以外的有「白骨」的卡名记述的怪兽
function c6128460.initial_effect(c)
	-- 使这张卡在墓地存在时卡名当作「白骨」使用。
	aux.EnableChangeCode(c,32274490,LOCATION_GRAVE)
	-- ②：自己场上的3星以下的不死族怪兽被战斗·效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_HAND)
	e2:SetTarget(c6128460.reptg)
	e2:SetValue(c6128460.repval)
	e2:SetOperation(c6128460.repop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把以下怪兽合计2只加入手卡（同名卡最多1张）。那之后，选1张手卡丢弃。●「白骨」●「白骨烤王」以外的有「白骨」的卡名记述的怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES_SELF)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,6128460)
	e3:SetTarget(c6128460.thtg)
	e3:SetOperation(c6128460.thop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上因战斗或效果破坏的表侧表示的3星以下不死族怪兽。
function c6128460.repfilter(c,tp)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsRace(RACE_ZOMBIE) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动条件判定：检查手牌的这张卡是否可以丢弃，且场上是否有符合条件的怪兽将被破坏。
function c6128460.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c6128460.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏效果的适用对象（即符合过滤条件的怪兽）。
function c6128460.repval(e,c)
	return c6128460.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的执行函数：将手牌的这张卡送去墓地。
function c6128460.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将作为代替的这张卡作为效果丢弃送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD)
end
-- 过滤卡组中除「白骨烤王」以外、卡名是「白骨」或记述了「白骨」卡名的怪兽。
function c6128460.thfilter(c)
	-- 检查卡片是否为怪兽、可加入手牌、不是「白骨烤王」且自身卡名是「白骨」或记述了「白骨」卡名。
	return aux.IsCodeOrListed(c,32274490) and not c:IsCode(6128460) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动条件与靶指向：检查卡组中是否存在至少2种符合条件的怪兽，并设置检索的操作信息。
function c6128460.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有符合检索条件的怪兽。
		local g=Duel.GetMatchingGroup(c6128460.thfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置连锁处理的操作信息：从卡组将2张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 检索效果的执行函数：从卡组选择2张不同名的符合条件的怪兽加入手牌，之后丢弃1张手牌。
function c6128460.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取卡组中所有符合检索条件的怪兽。
	local g=Duel.GetMatchingGroup(c6128460.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从符合条件的卡中选择2张卡名不同的卡。
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的2张卡加入玩家手牌。
	Duel.SendtoHand(tg1,nil,REASON_EFFECT)
	-- 让对方玩家确认加入手牌的卡。
	Duel.ConfirmCards(1-tp,tg1)
	-- 洗切玩家的手牌。
	Duel.ShuffleHand(tp)
	-- 中断当前效果，使后续的丢弃手牌处理与加入手牌不视为同时进行。
	Duel.BreakEffect()
	-- 让玩家选择并丢弃1张手牌。
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
end
