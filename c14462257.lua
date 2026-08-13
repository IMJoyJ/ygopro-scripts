--氷の女王
-- 效果：
-- 这张卡不能作从墓地的特殊召唤。自己场上表侧表示存在的这张卡被破坏送去墓地时，自己墓地的魔法师族怪兽是3只以上的场合，可以从自己墓地选择1张魔法卡加入手卡。
function c14462257.initial_effect(c)
	-- 这张卡不能从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件效果的判定值设为false，使该卡永远无法满足从墓地特殊召唤的条件，即禁止从墓地特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示的这张卡被破坏送去墓地时，以自己墓地1张魔法卡为对象才能发动（这个效果在自己墓地的魔法师族怪兽是3只以上的场合才能发动和处理）。那张卡加入手卡。
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
-- 诱发效果的发动条件判定：这张卡是被破坏后送去墓地，且破坏前在自己场上表侧表示、控制者为发动者，并且自己墓地存在至少3只魔法师族怪兽。
function c14462257.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		-- 检查自己墓地是否存在至少3只魔法师族怪兽，作为效果发动和处理的条件之一。
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,3,nil,RACE_SPELLCASTER)
end
-- 定义可以选择的对象卡：必须是魔法卡，且能被加入手卡。
function c14462257.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果发动时的对象选择处理：校验对象是否合法，检查是否存在可选目标，提示玩家选择1张墓地魔法卡，并设置回手牌的操作信息。
function c14462257.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14462257.filter(chkc) end
	-- 在效果发动时检查是否存在至少1张满足筛选条件的魔法卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c14462257.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的魔法卡作为效果对象，并自动建立该卡与当前连锁的联系。
	local g=Duel.SelectTarget(tp,c14462257.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，声明本效果将把对象卡加入手牌，处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时的执行操作：取得对象卡，若该卡仍然与效果关联，则将其加入手牌并让对方确认。
function c14462257.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个效果对象卡（本例即选择的那张墓地魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，原因记为效果处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对手确认这张被加入手卡的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
