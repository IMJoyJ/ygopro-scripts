--水精鱗－アビスタージ
-- 效果：
-- 这张卡召唤·特殊召唤成功时，把手卡1只水属性怪兽丢弃去墓地才能发动。从自己墓地选择1只3星以下的水属性怪兽加入手卡。「水精鳞-深渊鲟鱼兵」的效果1回合只能使用1次。
function c22076135.initial_effect(c)
	-- 这张卡召唤·特殊召唤成功时，把手卡1只水属性怪兽丢弃去墓地才能发动。从自己墓地选择1只3星以下的水属性怪兽加入手卡。「水精鳞-深渊鲟鱼兵」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22076135,0))  --"回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,22076135)
	e1:SetCost(c22076135.thcost)
	e1:SetTarget(c22076135.thtg)
	e1:SetOperation(c22076135.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 筛选可用于作为COST丢弃的水属性手卡怪兽：需满足水属性、可以丢弃（通常手牌怪兽都满足）且能作为COST送去墓地。
function c22076135.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 定义发动代价：效果发动前必须从手卡丢弃1只水属性怪兽；先确认可行，再执行丢弃。
function c22076135.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：从手牌中检索是否存在1只满足条件的水属性怪兽可作为COST（不含效果持有者自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(c22076135.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行COST：由玩家tp选择1张满足条件的手卡水属性怪兽丢弃去墓地，丢弃原因记为COST+丢弃。
	Duel.DiscardHand(tp,c22076135.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选墓地中满足条件的对象：3星以下、水属性、且可以加入手卡的怪兽，用于回手牌效果的选择。
function c22076135.filter(c)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 设定效果发动时的对象选择：从自己墓地选择1只3星以下的水属性怪兽为对象，并设置回手牌的操作信息。
function c22076135.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22076135.filter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1只满足条件的3星以下水属性怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c22076135.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家tp弹出选择提示消息，提示内容是“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由玩家tp从自己墓地选择1张满足条件的怪兽卡作为效果对象（取对象效果），该选择被记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c22076135.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次操作信息：将把1张卡加入手牌（CATEGORY_TOHAND），后续可作为“加入手牌”类效果检测的依据。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将从墓地选出的对象加入手牌，并让对方确认那张卡。
function c22076135.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时当前连锁所选择的对象卡（此前设定的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的对象卡加入其持有者的手牌，原因记为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认刚刚加入手牌的那张卡（游戏王规则中回手牌后要公开确认）。
		Duel.ConfirmCards(1-tp,tc)
	end
end
