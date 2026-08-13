--機巧牙－御神尊真神
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：除外的自己的卡是6张以上的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，从手卡丢弃1只怪兽才能发动。从卡组把「机巧牙-御神尊真神」以外的1只攻击力和守备力的数值相同的怪兽加入手卡。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。选除外的6张自己的卡回到卡组。
function c46809548.initial_effect(c)
	-- ①：除外的自己的卡是6张以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46809548,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c46809548.ntcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。②：这张卡召唤·特殊召唤成功的场合，从手卡丢弃1只怪兽才能发动。从卡组把「机巧牙-御神尊真神」以外的1只攻击力和守备力的数值相同的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46809548,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,46809548)
	e2:SetCost(c46809548.thcost)
	e2:SetTarget(c46809548.thtg)
	e2:SetOperation(c46809548.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这个卡名的②③的效果1回合各能使用1次。③：怪兽区域的这张卡被破坏的场合才能发动。选除外的6张自己的卡回到卡组。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(46809548,2))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,46809549)
	e4:SetCondition(c46809548.tdcon)
	e4:SetTarget(c46809548.tdtg)
	e4:SetOperation(c46809548.tdop)
	c:RegisterEffect(e4)
end
-- 作为①无解放召唤的召唤规则条件的判定函数：c为nil表示该规则效果可以被适用并返回true；否则需满足无解放、等级≥5、自己主要怪兽区有空位，以及自己除外区存在6张以上的卡。
function c46809548.ntcon(e,c,minc)
	if c==nil then return true end
	-- 无解放召唤的条件：本次召唤是不需要解放的召唤（minc==0），且这张卡等级为5星以上，同时自己场上主要怪兽区存在可用的空位。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 并且自己除外区存在至少6张卡（无其他筛选条件），满足①效果中“除外的自己的卡是6张以上”的要求。
		and Duel.IsExistingMatchingCard(nil,c:GetControler(),LOCATION_REMOVED,0,6,nil)
end
-- ②效果丢弃手牌作为发动代价的筛选函数：判断手牌中的这张卡是怪兽且可以被丢弃。
function c46809548.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- ②效果的发动代价：确认阶段检查手牌是否有符合条件的怪兽；实际支付时从手牌丢弃1只怪兽，丢弃原因同时标记为代价和丢弃。
function c46809548.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：在支付代价前，检查自己手牌中是否存在至少1只满足costfilter（怪兽且可丢弃）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c46809548.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手牌选择并丢弃1只怪兽（丢弃原因包含COST与DISCARD，因此既作为发动代价也作为丢弃处理）。
	Duel.DiscardHand(tp,c46809548.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 检索目标卡片的筛选函数：攻击力与守备力数值相同、卡名不是「机巧牙-御神尊真神」、并且能够加入手牌。
function c46809548.thfilter(c)
	-- 具体检索条件：攻击力=守备力（按当前值判定）、卡号不是46809548（本卡）、且可以加入手牌（不受“不能加入手牌”限制）。
	return aux.AtkEqualsDef(c) and not c:IsCode(46809548) and c:IsAbleToHand()
end
-- ②效果的发动目标：在发动时确认卡组存在符合条件的检索对象；并将本连锁的操作信息设置为“从卡组将1张卡加入手牌”。
function c46809548.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法检测：卡组中是否存在至少1张满足thfilter（攻守相同、不是本卡名、可加入手牌）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c46809548.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次处理预定从卡组将1张卡加入手牌（target为nil表示不取对象，数量1，位置为卡组），用于配合其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：提示玩家选择要加入手牌的卡，从卡组选择1张符合条件的怪兽，将其加入手牌并向对方展示。
function c46809548.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组选择1张符合thfilter的怪兽卡（不取对象效果，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c46809548.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入持有者的手牌，原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件：这张卡被破坏时，其被破坏前所在位置是怪兽区域（即这张卡在怪兽区域被破坏，而不是在手牌或魔法陷阱区域被破坏）。
function c46809548.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- ③效果的发动目标：确认除外区存在至少6张可返回卡组的卡；并设置操作信息为从除外区将6张卡返回卡组。
function c46809548.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法检测：自己的除外区是否存在至少6张能够返回卡组的卡（没有“不能返回卡组”的限制）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,6,nil) end
	-- 设置操作信息：本次处理预定将除外区的6张卡返回卡组（不取对象，数量6，范围为除外区）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,6,tp,LOCATION_REMOVED)
end
-- ③效果处理：提示玩家选择要返回卡组的卡，从自己的除外区选择6张，将它们返回持有者卡组并洗牌。
function c46809548.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己的除外区选择6张可以返回卡组的卡（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,6,6,nil)
	if #g==6 then
		-- 将选择的6张卡返回持有者卡组，并以SEQ_DECKSHUFFLE表示返回卡组后需要洗切。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
