--BK グラスジョー
-- 效果：
-- ①：这张卡被选择作为攻击对象的场合发动。这张卡破坏。
-- ②：这张卡被效果送去墓地时，以「燃烧拳击手 不堪一击拳手」以外的自己墓地1只「燃烧拳击手」怪兽为对象才能发动。那只怪兽加入手卡。
function c5361647.initial_effect(c)
	-- ①：这张卡被选择作为攻击对象的场合发动。这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5361647,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(c5361647.destg)
	e1:SetOperation(c5361647.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地时，以「燃烧拳击手 不堪一击拳手」以外的自己墓地1只「燃烧拳击手」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5361647,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c5361647.thcon)
	e2:SetTarget(c5361647.thtg)
	e2:SetOperation(c5361647.thop)
	c:RegisterEffect(e2)
end
-- 设置破坏效果的处理目标为自身
function c5361647.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为破坏效果，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 处理破坏效果的执行逻辑
function c5361647.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以效果原因破坏
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 判断此卡是否因效果而送去墓地
function c5361647.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 筛选墓地符合条件的「燃烧拳击手」怪兽（排除自身）
function c5361647.filter(c)
	return c:IsSetCard(0x1084) and not c:IsCode(5361647) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置加入手牌效果的处理目标为符合条件的墓地怪兽
function c5361647.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c5361647.filter(chkc) end
	-- 检查是否存在符合条件的墓地目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c5361647.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一个符合条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c5361647.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息为回手牌效果，目标为选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理加入手牌效果的执行逻辑
function c5361647.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认目标怪兽加入手牌
		Duel.ConfirmCards(1-tp,tc)
	end
end
