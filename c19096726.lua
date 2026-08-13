--鉄獣鳥 メルクーリエ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：需以「阿不思的落胤」为融合素材的融合怪兽在自己场上存在，对方把怪兽的效果发动时，把手卡·场上的这张卡送去墓地才能发动。那个效果无效。
-- ②：这张卡被除外的场合才能发动。除「铁兽鸟 墨丘利信使」外的1只「阿不思的落胤」或者有那个卡名记述的怪兽从卡组加入手卡。
function c19096726.initial_effect(c)
	-- 将卡名「阿不思的落胤」（68468459）登记到本卡的记述卡名列表中，用于后续判断那些卡被视为“有那个卡名记述的怪兽”。
	aux.AddCodeList(c,68468459)
	-- ①：需以「阿不思的落胤」为融合素材的融合怪兽在自己场上存在，对方把怪兽的效果发动时，把手卡·场上的这张卡送去墓地才能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCountLimit(1,19096726)
	e1:SetCondition(c19096726.discon)
	e1:SetCost(c19096726.discost)
	e1:SetTarget(c19096726.distg)
	e1:SetOperation(c19096726.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。除「铁兽鸟 墨丘利信使」外的1只「阿不思的落胤」或者有那个卡名记述的怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,19096727)
	e2:SetTarget(c19096726.thtg)
	e2:SetOperation(c19096726.thop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数 disfilter，用于检查场上是否存在满足条件的融合怪兽：是融合怪兽、融合素材包含「阿不思的落胤」、且表侧表示。
function c19096726.disfilter(c)
	-- 判断卡片是否为融合怪兽、其融合素材是否包含「阿不思的落胤」、且处于表侧表示。作为①效果的发动条件中“需以「阿不思的落胤」为融合素材的融合怪兽在自己场上存在”的判定。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsFaceup()
end
-- 定义①效果的发动条件函数。条件包括：自己场上存在满足上述筛选条件的融合怪兽；对方发动怪兽效果；该效果可被无效；且这张卡在手牌或场上（非战斗破坏状态）。同时满足才可发动。
function c19096726.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少1只符合条件的融合怪兽（以「阿不思的落胤」为素材且表侧表示的融合怪兽）。
	return Duel.IsExistingMatchingCard(c19096726.disfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查发动效果的是对方玩家（rp==1-tp），且该效果是怪兽效果，并且该连锁效果能够被无效化。确保满足“对方把怪兽的效果发动时”。
		and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and (c:IsLocation(LOCATION_MZONE) and not c:IsStatus(STATUS_BATTLE_DESTROYED) or c:IsLocation(LOCATION_HAND))
end
-- 定义①效果的代价函数。以将这张卡送去墓地为代价，在发动时支付。包括合法性检查和执行送墓。
function c19096726.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡本身从手卡·场上送去墓地，作为发动效果的代价（REASON_COST）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义①效果发动时的目标函数。不取对象，声明将无效该次对方怪兽效果；并设置操作信息为无效效果。
function c19096726.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁中对方发动的那个效果（eg）设置为要无效的对象，并写入操作信息，供后续连锁处理检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义①效果处理时的操作。实际执行无效对方那个怪兽效果。
function c19096726.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效连锁编号ev的效果，即令对方发动的那个怪兽效果无效。
	Duel.NegateEffect(ev)
end
-- 定义②效果检索的筛选函数。符合条件的卡片为：「阿不思的落胤」本身，或者效果文本中记述了「阿不思的落胤」且是怪兽卡的卡，并且不能是本卡「铁兽鸟 墨丘利信使」；同时该卡可以被加入手牌。
function c19096726.thfilter(c)
	-- 筛选条件主体：卡名是阿不思的落胤，或是记载了阿不思的落胤的怪兽卡，且排除自己（墨丘利信使）。
	return (c:IsCode(68468459) or aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER) and not c:IsCode(19096726))
		and c:IsAbleToHand()
end
-- 定义②效果发动时的目标函数。检查卡组中是否存在至少1张符合检索条件的卡，并设置操作信息为从卡组加入手牌。
function c19096726.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：卡组中是否存在满足thfilter的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c19096726.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次处理将从卡组把1张卡加入手牌（CATEGORY_TOHAND），检索数量为1，目标持有者为tp，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义②效果处理时的操作。执行检索：玩家选择1张符合条件的卡，加入手牌，并向对方确认。
function c19096726.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要加入手牌的卡”，引导玩家选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并让玩家选择1张满足thfilter的卡（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c19096726.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手牌（nil表示去持有者手牌），原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的那张卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
