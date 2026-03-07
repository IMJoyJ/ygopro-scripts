--E・HERO オーシャン
-- 效果：
-- ①：1回合1次，自己准备阶段以自己的场上·墓地1只「英雄」怪兽为对象才能发动。那只自己的「英雄」怪兽回到持有者手卡。
function c37195861.initial_effect(c)
	-- 效果原文内容：①：1回合1次，自己准备阶段以自己的场上·墓地1只「英雄」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37195861,0))  --"把1只名字带有「英雄」的怪兽回到持有者手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c37195861.con)
	e1:SetTarget(c37195861.tg)
	e1:SetOperation(c37195861.op)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为自己的准备阶段
function c37195861.con(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：当前回合玩家等于效果发动玩家
	return Duel.GetTurnPlayer()==tp
end
-- 效果作用：定义可选择的「英雄」怪兽过滤条件
function c37195861.filter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 效果作用：设置选择目标的处理逻辑
function c37195861.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(0x14) and chkc:IsControler(tp) and c37195861.filter(chkc) end
	-- 效果作用：判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c37195861.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 效果作用：选择满足条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c37195861.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 效果作用：设置连锁操作信息为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果作用：执行将目标怪兽送回手牌的操作
function c37195861.op(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
