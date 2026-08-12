--魔装聖龍 イーサルウェポン
-- 效果：
-- 「魔装圣龙 以太神兵龙」的效果1回合只能使用1次。
-- ①：这张卡灵摆召唤成功时，以场上1张卡为对象才能发动。那张卡回到持有者手卡。
function c56804361.initial_effect(c)
	-- 「魔装圣龙 以太神兵龙」的效果1回合只能使用1次。①：这张卡灵摆召唤成功时，以场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56804361,0))  --"回到手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,56804361)
	e1:SetCondition(c56804361.condition)
	e1:SetTarget(c56804361.target)
	e1:SetOperation(c56804361.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否是通过灵摆召唤成功特殊召唤
function c56804361.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 效果发动的对象选择与合法性检测，确认场上是否存在可以回到手牌的卡，并将其作为效果对象
function c56804361.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查双方场上是否存在至少1张可以回到手牌的卡作为合法的效果对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让发动效果的玩家选择场上1张可以回到手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁信息，表明此效果的操作分类为“返回手牌”，操作对象为选中的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理，获取选中的对象卡片，若其仍存在于场上且与效果相关联，则将其送回持有者手牌
function c56804361.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果处理将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
