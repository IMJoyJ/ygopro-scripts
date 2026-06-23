--氷の女王
-- 效果：
-- 这张卡不能作从墓地的特殊召唤。自己场上表侧表示存在的这张卡被破坏送去墓地时，自己墓地的魔法师族怪兽是3只以上的场合，可以从自己墓地选择1张魔法卡加入手卡。
function c14462257.initial_effect(c)
	-- 这张卡不能作从墓地的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法从墓地特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的这张卡被破坏送去墓地时，自己墓地的魔法师族怪兽是3只以上的场合，可以从自己墓地选择1张魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14462257,0))  --"墓地1张魔法卡加入手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c14462257.condition)
	e2:SetTarget(c14462257.target)
	e2:SetOperation(c14462257.operation)
	c:RegisterEffect(e2)
end
-- 判断触发条件是否满足
function c14462257.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		-- 检查自己墓地是否存在至少3只魔法师族怪兽
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,3,nil,RACE_SPELLCASTER)
end
-- 过滤函数，用于筛选墓地中的魔法卡
function c14462257.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置选择目标时的处理函数
function c14462257.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14462257.filter(chkc) end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c14462257.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择一张满足条件的魔法卡作为目标
	local g=Duel.SelectTarget(tp,c14462257.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，指定将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 设置效果发动后的处理函数
function c14462257.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认被加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end
