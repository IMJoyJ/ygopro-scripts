--極星霊デックアールヴ
-- 效果：
-- 这张卡召唤成功时，可以选择自己墓地存在的1只名字带有「极星」的怪兽加入手卡。
function c77060848.initial_effect(c)
	-- 这张卡召唤成功时，可以选择自己墓地存在的1只名字带有「极星」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77060848,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c77060848.thtg)
	e1:SetOperation(c77060848.thop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中名字带有「极星」的怪兽，且该卡可以加入手牌
function c77060848.filter(c)
	return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的目标选择与处理信息设置（检测墓地是否存在符合条件的卡，并选择该卡作为效果对象）
function c77060848.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c77060848.filter(chkc) end
	-- 在效果发动阶段，检查自己墓地是否存在至少1只满足过滤条件的「极星」怪兽
	if chk==0 then return Duel.IsExistingTarget(c77060848.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足过滤条件的「极星」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77060848.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表示该效果会把选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将选中的对象怪兽加入手牌，并向对方玩家确认
function c77060848.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
