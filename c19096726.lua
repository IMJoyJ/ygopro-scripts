--鉄獣鳥 メルクーリエ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：需以「阿不思的落胤」为融合素材的融合怪兽在自己场上存在，对方把怪兽的效果发动时，把手卡·场上的这张卡送去墓地才能发动。那个效果无效。
-- ②：这张卡被除外的场合才能发动。除「铁兽鸟 墨丘利信使」外的1只「阿不思的落胤」或者有那个卡名记述的怪兽从卡组加入手卡。
function c19096726.initial_effect(c)
	-- 注册此卡具有「阿不思的落胤」的卡名记载
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
-- 过滤函数，用于检测场上是否存在以「阿不思的落胤」为融合素材的融合怪兽
function c19096726.disfilter(c)
	-- 检测怪兽是否为融合怪兽且以「阿不思的落胤」为素材且表侧表示
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsFaceup()
end
-- 判断是否满足①效果的发动条件：场上存在以「阿不思的落胤」为融合素材的融合怪兽，对方发动怪兽效果，且此卡在手牌或未被战斗破坏的怪兽区
function c19096726.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查场上是否存在满足条件的融合怪兽
	return Duel.IsExistingMatchingCard(c19096726.disfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断是否为对方发动的怪兽效果且该连锁可被无效
		and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
		and (c:IsLocation(LOCATION_MZONE) and not c:IsStatus(STATUS_BATTLE_DESTROYED) or c:IsLocation(LOCATION_HAND))
end
-- 设置①效果的发动费用：将此卡送去墓地
function c19096726.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为①效果的发动费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置①效果的发动目标：使对方效果无效
function c19096726.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将使对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 执行①效果：使对方效果无效
function c19096726.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
-- 过滤函数，用于检索卡组中符合条件的「阿不思的落胤」相关怪兽
function c19096726.thfilter(c)
	-- 检测怪兽是否为「阿不思的落胤」或具有其卡名记述且为怪兽卡且不是此卡本身
	return (c:IsCode(68468459) or aux.IsCodeListed(c,68468459) and c:IsType(TYPE_MONSTER) and not c:IsCode(19096726))
		and c:IsAbleToHand()
end
-- 设置②效果的发动目标：从卡组检索符合条件的卡加入手牌
function c19096726.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c19096726.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行②效果：从卡组检索符合条件的卡加入手牌并确认
function c19096726.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c19096726.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
