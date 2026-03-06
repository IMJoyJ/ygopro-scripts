--マドルチェ・ピョコレート
-- 效果：
-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。此外，1回合1次，这张卡在场上表侧表示存在，自己场上的名字带有「魔偶甜点」的怪兽的表示形式变更时才能发动。选择场上1只怪兽变成表侧守备表示，那只怪兽是名字带有「魔偶甜点」的怪兽以外的场合，那只怪兽不能攻击，效果无效化。
function c26570480.initial_effect(c)
	-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26570480,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c26570480.retcon)
	e1:SetTarget(c26570480.rettg)
	e1:SetOperation(c26570480.retop)
	c:RegisterEffect(e1)
	-- 1回合1次，这张卡在场上表侧表示存在，自己场上的名字带有「魔偶甜点」的怪兽的表示形式变更时才能发动。选择场上1只怪兽变成表侧守备表示，那只怪兽是名字带有「魔偶甜点」的怪兽以外的场合，那只怪兽不能攻击，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26570480,1))  --"改变表示形式"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c26570480.poscon)
	e2:SetTarget(c26570480.postg)
	e2:SetOperation(c26570480.posop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否因破坏而送去墓地且为对方破坏，且此卡在破坏前属于玩家控制。
function c26570480.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 设置效果处理时将此卡送回卡组的操作信息。
function c26570480.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将此卡送回卡组的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 当此卡因效果送回卡组时，执行送回卡组的操作。
function c26570480.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以效果原因送回卡组并洗牌。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 用于判断是否满足触发条件的过滤器函数，检查目标怪兽是否为魔偶甜点族且表示形式发生改变。
function c26570480.cfilter(c,tp,ec)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	if c==ec then
		return ((np==POS_FACEUP_DEFENSE and pp==POS_FACEUP_ATTACK) or (np==POS_FACEUP_ATTACK and pp==POS_FACEUP_DEFENSE))
			and c:IsControler(tp) and c:IsSetCard(0x71)
	else
		return ((np==POS_FACEUP_DEFENSE and pp==POS_FACEUP_ATTACK) or (np==POS_FACEUP_ATTACK and pp&POS_DEFENSE~=0))
			and c:IsControler(tp) and c:IsSetCard(0x71)
	end
end
-- 判断是否满足触发条件，即场上是否存在魔偶甜点族怪兽表示形式变更。
function c26570480.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26570480.cfilter,1,nil,tp,e:GetHandler())
end
-- 用于筛选可以改变表示形式的怪兽的过滤器函数。
function c26570480.filter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
-- 设置选择目标怪兽的处理逻辑，提示玩家选择要改变表示形式的怪兽。
function c26570480.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c26570480.filter(chkc) end
	-- 检查是否有满足条件的怪兽可作为目标。
	if chk==0 then return Duel.IsExistingTarget(c26570480.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上一只可以改变表示形式的怪兽作为目标。
	Duel.SelectTarget(tp,c26570480.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理效果发动后执行的操作，将目标怪兽变为表侧守备表示，并对非魔偶甜点族怪兽施加不能攻击、效果无效化等效果。
function c26570480.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_FACEUP_DEFENSE) then
		-- 将目标怪兽变为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		if not tc:IsSetCard(0x71) then
			-- 对非魔偶甜点族怪兽施加不能攻击的效果。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 对非魔偶甜点族怪兽施加效果无效化的效果。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 对非魔偶甜点族怪兽施加效果无效化的效果。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
