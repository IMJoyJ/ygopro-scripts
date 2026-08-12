--ラミア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只爬虫类族·8星怪兽加入手卡。
-- ②：这张卡被除外的场合，以自己场上1只爬虫类族怪兽为对象才能发动。那只怪兽直到下个回合的结束时不会被效果破坏。
function c84900597.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只爬虫类族·8星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84900597,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,84900597)
	e1:SetTarget(c84900597.thtg)
	e1:SetOperation(c84900597.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的场合，以自己场上1只爬虫类族怪兽为对象才能发动。那只怪兽直到下个回合的结束时不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84900597,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,84900598)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c84900597.indtg)
	e3:SetOperation(c84900597.indop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中满足“爬虫类族、8星、且能加入手卡”条件的卡片
function c84900597.thfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsLevel(8) and c:IsAbleToHand()
end
-- ①号效果的发动准备，检查卡组中是否存在符合条件的卡，并设置检索操作信息
function c84900597.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组中是否存在至少1只满足条件的爬虫类族·8星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84900597.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的执行，从卡组选择1只满足条件的怪兽加入手卡并给对方确认
function c84900597.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的爬虫类族·8星怪兽
	local g=Duel.SelectMatchingCard(tp,c84900597.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上表侧表示的爬虫类族怪兽
function c84900597.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_REPTILE)
end
-- ②号效果的发动准备，检查并选择自己场上1只表侧表示的爬虫类族怪兽作为效果对象
function c84900597.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c84900597.filter(chkc) end
	-- 在发动时检查自己场上是否存在可以作为效果对象的表侧表示爬虫类族怪兽
	if chk==0 then return Duel.IsExistingTarget(c84900597.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧表示的爬虫类族怪兽作为效果对象
	Duel.SelectTarget(tp,c84900597.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②号效果的执行，给作为对象的怪兽赋予直到下个回合结束时不会被效果破坏的抗性
function c84900597.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽直到下个回合的结束时不会被效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end
