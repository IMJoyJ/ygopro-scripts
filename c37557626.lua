--リチュア・キラー
-- 效果：
-- 这张卡召唤·反转召唤成功时，自己场上有这张卡以外的名字带有「遗式」的怪兽表侧表示存在的场合，可以选择这张卡以外的自己场上存在的1只怪兽回到手卡。
function c37557626.initial_effect(c)
	-- 这张卡召唤·反转召唤成功时，自己场上有这张卡以外的名字带有「遗式」的怪兽表侧表示存在的场合，可以选择这张卡以外的自己场上存在的1只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37557626,0))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c37557626.condition)
	e1:SetTarget(c37557626.target)
	e1:SetOperation(c37557626.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡是否为表侧表示且名字带有「遗式」字段，用于筛选符合条件的「遗式」怪兽。
function c37557626.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3a)
end
-- 发动条件：召唤·反转召唤成功时，检查自己场上是否存在这张卡以外的表侧表示的「遗式」怪兽，若存在则满足发动条件。
function c37557626.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索判定：确认自己场上主要怪兽区存在至少1张不是本卡自身的表侧「遗式」怪兽，存在则条件成立。
	return Duel.IsExistingMatchingCard(c37557626.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果发动时的目标选择与操作信息登记：设置取对象效果，选择自己场上这张卡以外的1只可以回手卡的怪兽作为对象，并登记回手卡的操作信息。
function c37557626.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 发动合法性检查：自己场上是否存在这张卡以外的1只可以送去手卡的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家显示选择提示框，提示“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上选择1张这张卡以外且可以回手卡的怪兽作为效果对象，且必须选择1张。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 登记本连锁的回手卡操作信息，声明效果将把对象卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：先确认场上仍存在其他表侧「遗式」怪兽，若存在则将发动时选择的对象卡返回持有者手卡。
function c37557626.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认：若场上已没有这张卡以外的表侧「遗式」怪兽，则本次效果不处理。
	if not Duel.IsExistingMatchingCard(c37557626.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return end
	-- 取出发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回持有者手卡（以效果原因加入手卡）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
