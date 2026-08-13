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
	-- 此外，1回合1次，这张卡在场上表侧表示存在，自己场上的名字带有「魔偶甜点」的怪兽的表示形式变更时才能发动。选择场上1只怪兽变成表侧守备表示，那只怪兽是名字带有「魔偶甜点」的怪兽以外的场合，那只怪兽不能攻击，效果无效化。
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
-- 判断是否满足“这张卡被对方破坏送去墓地”的触发条件：该卡因破坏被送去墓地，破坏者是对方玩家，且该卡被破坏前的控制者是自己。
function c26570480.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 效果发动时点处理：本效果无需额外选择对象，直接允许发动；并向系统登记将自身回到卡组的操作信息。
function c26570480.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：宣告本效果处理时将这张卡返回卡组（CATEGORY_TODECK），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与当前效果关联，则将其返回持有者卡组并洗牌。
function c26570480.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡送去持有者卡组，并洗牌（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤函数：用于判断表示形式变更事件中是否存在自己场上的名字带有「魔偶甜点」的怪兽发生了攻击表示与守备表示之间的变更；若变更者正是本卡，则仅限表侧攻击/表侧守备的互相转换。
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
-- 触发条件：本次表示形式变更事件中，存在至少1只自己场上名字带有「魔偶甜点」的怪兽发生了满足条件的表示形式变更。
function c26570480.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c26570480.cfilter,1,nil,tp,e:GetHandler())
end
-- 对象筛选条件：该怪兽不是表侧守备表示，且能够变更表示形式。
function c26570480.filter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
-- 效果发动与选对象处理：先确认存在合法目标，再提示玩家选择，并将选择的1只怪兽设为效果对象。
function c26570480.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c26570480.filter(chkc) end
	-- 检查场上是否存在至少1只满足筛选条件且能成为此效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c26570480.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要改变表示形式的怪兽”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从双方主要怪兽区选择1只符合条件的怪兽作为此效果的对象（取对象）。
	Duel.SelectTarget(tp,c26570480.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将对象怪兽变为表侧守备表示；若该怪兽不是名字带有「魔偶甜点」的怪兽，则使其不能攻击、效果无效化。
function c26570480.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得此效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_FACEUP_DEFENSE) then
		-- 将对象怪兽的表示形式变为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		if not tc:IsSetCard(0x71) then
			-- 那只怪兽不能攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 效果无效化。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
