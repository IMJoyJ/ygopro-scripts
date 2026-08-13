--大霊術－「一輪」
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有守备力1500的魔法师族怪兽存在，对方发动的怪兽的效果1回合只有1次无效化。
-- ②：自己主要阶段才能发动。手卡1只魔法师族怪兽给对方观看，和那只怪兽相同属性而攻击力1500/守备力200的1只怪兽从卡组加入手卡，给人观看的怪兽回到卡组。
function c38057522.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要自己场上有守备力1500的魔法师族怪兽存在，对方发动的怪兽的效果1回合只有1次无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c38057522.discon)
	e1:SetOperation(c38057522.disop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。手卡1只魔法师族怪兽给对方观看，和那只怪兽相同属性而攻击力1500/守备力200的1只怪兽从卡组加入手卡，给人观看的怪兽回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38057522,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,38057522)
	e2:SetTarget(c38057522.thtg)
	e2:SetOperation(c38057522.thop)
	c:RegisterEffect(e2)
end
-- 该过滤器用于判断场上是否存在表侧表示、种族为魔法师族且守备力为1500的怪兽，即①效果的发动/适用条件。
function c38057522.disfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsDefense(1500)
end
-- ①效果的发动条件：自己场上有满足disfilter的怪兽（表侧表示·魔法师族·守备力1500）存在，并且当前连锁上发动效果的是对方玩家的怪兽效果。
function c38057522.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足disfilter的怪兽，即①效果生效所需的前置条件。
	return Duel.IsExistingMatchingCard(c38057522.disfilter,tp,LOCATION_MZONE,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- ①效果的处理：无效对方发动的那个怪兽效果。
function c38057522.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 给对方玩家展示卡牌动画，提示正在发动“大灵术-「一轮」”的①效果。
	Duel.Hint(HINT_CARD,0,38057522)
	-- 将当前连锁上对方发动的怪兽效果无效化。
	Duel.NegateEffect(ev)
end
-- ②效果选择手卡怪兽的过滤器：该手卡怪兽必须是魔法师族、未公开、可以返回卡组，且卡组中存在与之相同属性的检索目标。
function c38057522.tdfilter(c,tp)
	return c:IsRace(RACE_SPELLCASTER) and not c:IsPublic() and c:IsAbleToDeck()
		-- 进一步确认卡组中存在与手卡怪兽相同属性、且攻击力1500/守备力200的怪兽可加入手卡，保证效果处理时能完成检索。
		and Duel.IsExistingMatchingCard(c38057522.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
-- ②效果检索目标的过滤器：攻击力1500、守备力200、与展示怪兽属性相同、并且可以加入手卡的怪兽。
function c38057522.thfilter(c,attr)
	return c:IsAttack(1500) and c:IsDefense(200) and c:IsAttribute(attr) and c:IsAbleToHand()
end
-- ②效果发动时判定：手牌中存在满足tdfilter的魔法师族怪兽；同时设置本次操作涉及从卡组加入手牌和从手牌返回卡组。
function c38057522.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己手牌中是否存在1张可以展示并返回卡组、且卡组中有对应检索目标的魔法师族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c38057522.tdfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 设置操作信息：本次效果可能从卡组将1只怪兽加入手卡（用于触发如星尘龙等效果的检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本次效果可能将1张手卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- ②效果处理：展示手卡1只魔法师族怪兽，从卡组检索相同属性的1500/200怪兽加入手牌，并将展示怪兽洗回卡组。
function c38057522.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择一张要展示给对方确认的手卡怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从手牌中选择1张满足tdfilter的魔法师族怪兽作为展示对象。
	local g=Duel.SelectMatchingCard(tp,c38057522.tdfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的手卡怪兽展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		local attr=tc:GetAttribute()
		-- 弹出选择提示，让玩家选择一张要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组中选择1张满足thfilter（相同属性、攻击力1500、守备力200）的怪兽作为检索目标。
		local hg=Duel.SelectMatchingCard(tp,c38057522.thfilter,tp,LOCATION_DECK,0,1,1,nil,attr)
		local hc=hg:GetFirst()
		-- 将检索到的卡加入手牌；若加入成功且该卡确实到了手牌，则继续处理展示怪兽回卡组。
		if hc and Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 then
			-- 将检索加入手卡的怪兽展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,hc)
			if hc:IsLocation(LOCATION_HAND) then
				-- 将展示的手卡怪兽以效果洗回持有者卡组。
				Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end
