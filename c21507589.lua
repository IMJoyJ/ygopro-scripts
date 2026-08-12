--フィッシュアンドバックス
-- 效果：
-- 丢弃1张手卡，选择从游戏中除外的2只自己的鱼族·海龙族·水族怪兽才能发动。选择的怪兽加入手卡。
function c21507589.initial_effect(c)
	-- 创建效果对象并设置其分类为回手牌、取对象、发动类型为自由时点、设置费用、目标和发动处理
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c21507589.cost)
	e1:SetTarget(c21507589.target)
	e1:SetOperation(c21507589.activate)
	c:RegisterEffect(e1)
end
-- 丢弃1张手卡
function c21507589.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃1张手卡作为代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选场上正面表示的鱼族·水族·海龙族怪兽
function c21507589.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and c:IsAbleToHand()
end
-- 设置效果目标，选择2只除外区的符合条件的怪兽
function c21507589.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c21507589.filter(chkc) end
	-- 检查玩家除外区是否存在至少2只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c21507589.filter,tp,LOCATION_REMOVED,0,2,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择2只除外区的符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c21507589.filter,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设置效果操作信息，指定将2只怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 发动效果，将符合条件的怪兽送入手牌并确认对方查看
function c21507589.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的怪兽送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end
