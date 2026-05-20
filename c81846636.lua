--ジェムナイト・ラズリー
-- 效果：
-- ①：这张卡被效果送去墓地的场合，以自己墓地1只通常怪兽为对象才能发动。那只怪兽加入手卡。
function c81846636.initial_effect(c)
	-- ①：这张卡被效果送去墓地的场合，以自己墓地1只通常怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81846636,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c81846636.condition)
	e1:SetTarget(c81846636.target)
	e1:SetOperation(c81846636.operation)
	c:RegisterEffect(e1)
end
-- 判定是否因效果送去墓地（且不是回到墓地）
function c81846636.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_RETURN)==0 and bit.band(r,REASON_EFFECT)~=0
end
-- 过滤墓地中可以加入手牌的通常怪兽
function c81846636.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 效果发动的对象选择与合法性检测
function c81846636.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c81846636.filter(chkc) end
	-- 在发动阶段检测自己墓地是否存在符合条件的通常怪兽
	if chk==0 then return Duel.IsExistingTarget(c81846636.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只通常怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c81846636.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理的执行函数
function c81846636.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
