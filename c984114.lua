--エクスプレスロイド
-- 效果：
-- ①：这张卡召唤·反转召唤·特殊召唤成功时，以「特快机人」以外的自己墓地2只「机人」怪兽为对象才能发动。那些怪兽加入手卡。
function c984114.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功时，以「特快机人」以外的自己墓地2只「机人」怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(984114,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c984114.target)
	e1:SetOperation(c984114.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤出「特快机人」以外的自己墓地中的「机人」怪兽，且该怪兽可以加入手卡
function c984114.filter(c)
	return c:IsSetCard(0x16) and not c:IsCode(984114) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的目标选择与操作信息设置
function c984114.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c984114.filter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在至少2只满足条件的「机人」怪兽
	if chk==0 then return Duel.IsExistingTarget(c984114.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向发动效果的玩家发送提示信息，要求选择加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地2只满足条件的「机人」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c984114.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果处理的操作信息为：将这2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理的执行函数，将仍存在于墓地的对象怪兽加入手牌并给对方确认
function c984114.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将这些对象怪兽因效果加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
