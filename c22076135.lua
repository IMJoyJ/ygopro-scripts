--水精鱗－アビスタージ
-- 效果：
-- 这张卡召唤·特殊召唤成功时，把手卡1只水属性怪兽丢弃去墓地才能发动。从自己墓地选择1只3星以下的水属性怪兽加入手卡。「水精鳞-深渊鲟鱼兵」的效果1回合只能使用1次。
function c22076135.initial_effect(c)
	-- 效果原文内容：这张卡召唤·特殊召唤成功时，把手卡1只水属性怪兽丢弃去墓地才能发动。从自己墓地选择1只3星以下的水属性怪兽加入手卡。「水精鳞-深渊鲟鱼兵」的效果1回合只能使用1次。
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
-- 效果作用：设置用于判断是否满足丢弃条件的水属性怪兽过滤器
function c22076135.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 效果作用：检查手牌是否存在满足条件的水属性怪兽并将其丢弃
function c22076135.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断手牌中是否存在满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c22076135.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 效果作用：从手牌中丢弃1只满足条件的水属性怪兽
	Duel.DiscardHand(tp,c22076135.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：设置用于检索墓地满足条件的水属性怪兽的过滤器
function c22076135.filter(c)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 效果作用：设置效果的发动目标选择逻辑
function c22076135.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22076135.filter(chkc) end
	-- 效果作用：判断墓地中是否存在满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c22076135.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择满足条件的墓地水属性怪兽作为目标
	local g=Duel.SelectTarget(tp,c22076135.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 效果作用：设置连锁操作信息，指定将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果作用：处理效果的发动效果
function c22076135.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 效果作用：向对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
