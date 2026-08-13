--E・HERO オーシャン
-- 效果：
-- ①：1回合1次，自己准备阶段以自己的场上·墓地1只「英雄」怪兽为对象才能发动。那只自己的「英雄」怪兽回到持有者手卡。
function c37195861.initial_effect(c)
	-- ①：1回合1次，自己准备阶段以自己的场上·墓地1只「英雄」怪兽为对象才能发动。那只自己的「英雄」怪兽回到持有者手卡。
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
-- 发动条件函数：限定效果只能在效果持有者自己的准备阶段发动（此时当前回合玩家等于效果控制者tp）。
function c37195861.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己（tp），用于确保只有在自己的准备阶段才满足发动条件。
	return Duel.GetTurnPlayer()==tp
end
-- 定义可选目标：满足「英雄」字段、为怪兽卡、可以加入手卡，且位于自己墓地或是自己场上表侧表示的怪兽。
function c37195861.filter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 效果的目标处理：在发动时选择自己场上表侧表示或墓地的1只「英雄」怪兽作为对象，并设置回手牌的操作信息；若被连锁要求检查对象合法性，则验证该对象是否满足条件。
function c37195861.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(0x14) and chkc:IsControler(tp) and c37195861.filter(chkc) end
	-- 发动合法性检查：若不存在至少1只满足条件的「英雄」怪兽，则不能发动效果。
	if chk==0 then return Duel.IsExistingTarget(c37195861.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择提示“请选择要返回手牌的卡”的UI消息，不影响效果本身。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上表侧表示或自己墓地的怪兽中选择1只满足条件的「英雄」怪兽，并将它登记为本次效果的对象。
	local g=Duel.SelectTarget(tp,c37195861.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 设定操作信息：将本次处理登记为“回手牌”分类，对象为已选择的目标g，数量为1，用于后续时点检测与互动。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：取得效果对象，若对象仍与效果保持关联，则将其送回持有者手牌。
function c37195861.op(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时所选择的第一张对象卡（本效果只选1张）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送回其持有者手卡（第二参数nil表示返回持有者手牌）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
