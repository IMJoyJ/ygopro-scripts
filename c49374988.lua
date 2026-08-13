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
-- 判定诱发条件：这张卡被对方（1-tp）破坏送去墓地，且破坏前控制权属于自己（IsPreviousControler(tp)）。
function c49374988.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 作为无对象的诱发效果，发动时直接判定为可以发动，并登记效果处理时要把这张卡返回卡组的操作信息。
function c49374988.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次效果处理时将使这张卡返回卡组的操作信息，供连锁判定及后续处理参考。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果相关联，则将其返回持有者卡组并进行洗牌，完成“回到卡组”处理。
function c49374988.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因把这张卡返回持有者卡组，并洗切卡组（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 筛选自己场上可作为对象的“魔偶甜点”怪兽：表侧攻击表示，可以变更表示形式，且持有「魔偶甜点」字段。
function c49374988.filter1(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition() and c:IsSetCard(0x71)
end
-- 筛选对方场上可作为对象的怪兽：表侧攻击表示，且可以变更表示形式。
function c49374988.filter2(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 起动效果的目标选择函数：效果处理外不认可chkc，发动时确认自己场上与对方场上各有1只满足条件的怪兽存在，才能进行后续选择。
function c49374988.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在至少1只满足filter1的“魔偶甜点”怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c49374988.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查对方场上是否存在至少1只满足filter2的怪兽可作为对象；两者都满足才允许发动。
		and Duel.IsExistingTarget(c49374988.filter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示“选择要改变表示形式的怪兽”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 令操作者选择自己场上1只满足filter1的怪兽，并将其登记为这张效果的取对象目标。
	local g1=Duel.SelectTarget(tp,c49374988.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次显示“选择要改变表示形式的怪兽”的提示信息，用于选择对方场上的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 令操作者选择对方场上1只满足filter2的怪兽，并将其登记为这张效果的取对象目标。
	local g2=Duel.SelectTarget(tp,c49374988.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 把两个选择目标合并为一组，并登记将变更2只怪兽表示形式的操作信息，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,2,0,0)
end
-- 效果处理时筛选对象怪兽：仍然处于表侧攻击表示并且与这张效果存在关联。
function c49374988.pfilter(c,e)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRelateToEffect(e)
end
-- 效果处理：从连锁对象中筛出仍符合条件的怪兽，将它们变为表侧守备表示，并给每只怪兽附加“不能变更表示形式”的持续效果，持续到下次对方回合结束。
function c49374988.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取得本效果的全部对象卡，再用pfilter过滤掉不在表侧攻击表示或已失去关联的卡，得到实际处理组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c49374988.pfilter,nil,e)
	if g:GetCount()>0 then
		-- 将过滤后的对象怪兽全部变为表侧守备表示。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
		local tc=g:GetFirst()
		while tc do
			-- 直到下次的对方回合结束时，选择的怪兽不能把表示形式变更。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
