--シャドール・ハウンド
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以自己墓地1张「影依」卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡被效果送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。这个时候，「影依」怪兽以外的反转怪兽的效果不发动。
function c52551211.initial_effect(c)
	-- ①：这张卡反转的场合，以自己墓地1张「影依」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52551211,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,52551211)
	e1:SetTarget(c52551211.thtg)
	e1:SetOperation(c52551211.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。这个时候，「影依」怪兽以外的反转怪兽的效果不发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52551211,1))  --"表示形式变更"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,52551211)
	e2:SetCondition(c52551211.poscon)
	e2:SetTarget(c52551211.postg)
	e2:SetOperation(c52551211.posop)
	c:RegisterEffect(e2)
	c52551211.shadoll_flip_effect=e1
end
-- 过滤满足条件的「影依」卡（可加入手牌）
function c52551211.filter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToHand()
end
-- 设置效果目标：选择自己墓地1张「影依」卡作为对象
function c52551211.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c52551211.filter(chkc) end
	-- 判断是否满足发动条件：自己墓地是否存在1张「影依」卡
	if chk==0 then return Duel.IsExistingTarget(c52551211.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张墓地「影依」卡作为效果对象
	local g=Duel.SelectTarget(tp,c52551211.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果：将目标卡加入手牌
function c52551211.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断此效果是否因效果送去墓地而触发
function c52551211.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤场上可改变表示形式的怪兽
function c52551211.posfilter(c)
	return c:IsCanChangePosition()
end
-- 设置效果目标：选择场上1只怪兽作为对象
function c52551211.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c52551211.posfilter(chkc) end
	-- 判断是否满足发动条件：场上是否存在1只可改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(c52551211.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只可改变表示形式的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c52551211.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将选中的怪兽改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理效果：改变目标怪兽的表示形式
function c52551211.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsSetCard(0x9d) then
		-- 将目标怪兽变为表侧守备表示（非影依怪兽）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	else
		-- 将目标怪兽变为表侧守备表示（影依怪兽），且不触发反转效果
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
	end
end
