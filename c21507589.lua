--フィッシュアンドバックス
-- 效果：
-- 丢弃1张手卡，选择从游戏中除外的2只自己的鱼族·海龙族·水族怪兽才能发动。选择的怪兽加入手卡。
function c21507589.initial_effect(c)
	-- 丢弃1张手卡，选择从游戏中除外的2只自己的鱼族·海龙族·水族怪兽才能发动。选择的怪兽加入手卡。
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
-- 作为发动代价，玩家需从手卡丢弃1张卡；该函数在检查阶段确认有可丢弃的手卡，在支付阶段执行丢弃。
function c21507589.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认玩家手牌中是否存在至少1张可丢弃的卡（此处排除效果持有者自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 支付代价：从手卡选择1张可丢弃的卡丢弃，丢弃原因设为COST+DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选条件：表侧除外的自己的鱼族·海龙族·水族怪兽，且能被加入手卡。
function c21507589.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and c:IsAbleToHand()
end
-- 发动时选择：选择从游戏中除外的2只自己的鱼族·海龙族·水族怪兽作为对象，并设置操作信息为回手牌。
function c21507589.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c21507589.filter(chkc) end
	-- 取对象检查：确认自己除外区是否存在至少2只符合筛选条件的怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c21507589.filter,tp,LOCATION_REMOVED,0,2,nil) end
	-- 向玩家显示要选择加入手牌的提示信息（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由玩家选择2只符合条件的除外区怪兽，并将它们设为效果的对象。
	local g=Duel.SelectTarget(tp,c21507589.filter,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设置操作信息：将效果分类设为CATEGORY_TOHAND，目标为已选择的2张卡，用于后续处理判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理：将选择的对象怪兽加入手牌，并向对方展示。
function c21507589.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁的效果对象卡组（发动时选择的目标）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍然与该效果相关的对象卡送入其持有者的手卡（回手牌）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对手确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
