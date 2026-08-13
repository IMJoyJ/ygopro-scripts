--シャドール・ハウンド
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，以自己墓地1张「影依」卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡被效果送去墓地的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。这个时候，「影依」怪兽以外的反转怪兽的效果不发动。
function c52551211.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡反转的场合，以自己墓地1张「影依」卡为对象才能发动。那张卡加入手卡。
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
-- 筛选函数：对象必须是「影依」卡且可以被加入手卡（未受到“不能加入手卡”限制）。
function c52551211.filter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToHand()
end
-- ①效果的发动时点判定与目标选择：确认对象合法性后，从自己墓地选择1张符合条件的「影依」卡作为效果对象，并写入回手牌的操作信息。
function c52551211.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c52551211.filter(chkc) end
	-- 发动条件检查：自己墓地是否存在至少1张满足筛选条件且能被取为对象的「影依」卡。
	if chk==0 then return Duel.IsExistingTarget(c52551211.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 令玩家从自己墓地选择1张符合条件的「影依」卡，并将其登记为这次连锁的对象。
	local g=Duel.SelectTarget(tp,c52551211.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：本次处理将把对象卡（g中的1张）加入手牌，供后续时点/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的解决处理：取得对象卡，若该卡仍与效果关联（没有离开墓地/未被无效等），则将其加入持有者手牌。
function c52551211.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡（此时为墓地里的那张「影依」卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以「效果」为原因送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡被效果（REASON_EFFECT）送去墓地时才满足。
function c52551211.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 筛选函数：怪兽是否可以由效果改变表示形式（没有受到“不能改变表示形式”等限制）。
function c52551211.posfilter(c)
	return c:IsCanChangePosition()
end
-- ②效果的发动时点判定与目标选择：确认对象合法性后，从双方场上选择1只符合条件的怪兽作为效果对象，并写入变更表示形式的操作信息。
function c52551211.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c52551211.posfilter(chkc) end
	-- 发动条件检查：场上是否存在至少1只满足筛选条件且能被取为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c52551211.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示：请选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 令玩家从双方主要怪兽区选择1只符合条件的怪兽，并将其登记为这次连锁的对象。
	local g=Duel.SelectTarget(tp,c52551211.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：本次处理将把对象卡（g中的1只怪兽）变更表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果的解决处理：取得对象怪兽，若已不关联则直接结束；若对象为「影依」怪兽则正常变更表示形式，若对象不是「影依」怪兽则变更表示形式时不触发反转效果。
function c52551211.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsSetCard(0x9d) then
		-- 对「影依」对象怪兽进行表示形式变更（表侧攻击与表侧守备互换），保留反转效果触发（因此影依反转怪兽的效果可以发动）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	else
		-- 对非「影依」对象怪兽进行表示形式变更（表侧攻击与表侧守备互换），且 noflip=true，不触发该怪兽的反转效果。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
	end
end
