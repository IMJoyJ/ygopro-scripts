--マドルチェ・メェプル
-- 效果：
-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。1回合1次，选择自己场上表侧攻击表示存在的1只名字带有「魔偶甜点」的怪兽和对方场上表侧攻击表示存在的1只怪兽才能发动。选择的2只怪兽变成表侧守备表示，直到下次的对方回合结束时，选择的怪兽不能把表示形式变更。
function c49374988.initial_effect(c)
	-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49374988,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c49374988.retcon)
	e1:SetTarget(c49374988.rettg)
	e1:SetOperation(c49374988.retop)
	c:RegisterEffect(e1)
	-- 1回合1次，选择自己场上表侧攻击表示存在的1只名字带有「魔偶甜点」的怪兽和对方场上表侧攻击表示存在的1只怪兽才能发动。选择的2只怪兽变成表侧守备表示，直到下次的对方回合结束时，选择的怪兽不能把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49374988,1))  --"变成表侧守备表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c49374988.postg)
	e2:SetOperation(c49374988.posop)
	c:RegisterEffect(e2)
end
-- 判断触发效果的条件：卡片因破坏被送入墓地、破坏者为对手、且破坏前控制者为自己。
function c49374988.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 设置效果处理时的操作信息：将自身送去卡组。
function c49374988.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息中涉及的卡片为自身，数量为1，类型为CATEGORY_TODECK（回卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行效果处理：若卡片与当前效果相关，则将其送入卡组并洗牌。
function c49374988.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 实际将卡片以效果原因送入卡组底部并洗牌。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 筛选自己场上表侧攻击表示且能改变表示形式、并且种族为「魔偶甜点」的怪兽。
function c49374988.filter1(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition() and c:IsSetCard(0x71)
end
-- 筛选对方场上表侧攻击表示且能改变表示形式的怪兽。
function c49374988.filter2(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 判断是否满足发动条件：自己场上存在符合条件的怪兽，对方场上也存在符合条件的怪兽。
function c49374988.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在符合条件的怪兽（名字带「魔偶甜点」的表侧攻击表示怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c49374988.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在符合条件的怪兽（表侧攻击表示怪兽）。
		and Duel.IsExistingTarget(c49374988.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从自己场上选择一只符合条件的怪兽作为目标。
	local g1=Duel.SelectTarget(tp,c49374988.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从对方场上选择一只符合条件的怪兽作为目标。
	local g2=Duel.SelectTarget(tp,c49374988.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理时的操作信息：将选择的两只怪兽变为守备表示。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,2,0,0)
end
-- 筛选参与效果处理的怪兽：必须是表侧攻击表示且与当前效果相关的怪兽。
function c49374988.pfilter(c,e)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e)
end
-- 执行效果处理：改变目标怪兽的表示形式为守备表示，并赋予其不能改变表示形式的效果。
function c49374988.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡片组，并筛选出与当前效果相关的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c49374988.pfilter,nil,e)
	if g:GetCount()>0 then
		-- 将目标怪兽全部变为表侧守备表示。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
		local tc=g:GetFirst()
		while tc do
			-- 创建一个永续效果，使目标怪兽在下次结束阶段后无法改变表示形式。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
