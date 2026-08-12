--古代の整備場
-- 效果：
-- ①：以自己墓地1只「古代的机械」怪兽为对象才能发动。那只怪兽加入手卡。
function c59811955.initial_effect(c)
	-- ①：以自己墓地1只「古代的机械」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c59811955.target)
	e1:SetOperation(c59811955.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中卡名含有「古代的机械」且可以加入手牌的怪兽
function c59811955.filter(c)
	return c:IsSetCard(0x7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的对象选择与操作信息设置
function c59811955.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c59811955.filter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在符合条件的、可以作为效果对象的卡片
	if chk==0 then return Duel.IsExistingTarget(c59811955.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59811955.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理的执行函数
function c59811955.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果将目标怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
