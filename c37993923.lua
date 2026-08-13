--ジャンク・ガードナー
-- 效果：
-- 「废品同调士」＋调整以外的怪兽1只以上
-- 1回合1次，可以选择对方场上存在的1只怪兽，把表示形式变更。这个效果在对方回合也能发动。此外，这张卡从场上送去墓地的场合，可以选择场上存在的1只怪兽，把表示形式变更。
function c37993923.initial_effect(c)
	-- 为这张卡声明同调素材卡名列表，将“废品同调士”（卡号63977008）加入其中，用于判定同调素材。
	aux.AddMaterialCodeList(c,63977008)
	-- 为这张卡添加同调召唤手续：以1只“废品同调士”（或满足tfilter的调整）＋1只以上调整以外的怪兽作为素材进行同调召唤。
	aux.AddSynchroProcedure(c,c37993923.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，可以选择对方场上存在的1只怪兽，把表示形式变更。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37993923,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c37993923.target)
	e1:SetOperation(c37993923.operation)
	c:RegisterEffect(e1)
	-- 此外，这张卡从场上送去墓地的场合，可以选择场上存在的1只怪兽，把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37993923,0))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c37993923.condition2)
	e2:SetTarget(c37993923.target2)
	e2:SetOperation(c37993923.operation)
	c:RegisterEffect(e2)
end
c37993923.material_setcode=0x1017
-- 定义同调素材中“调整”怪兽的判定函数：素材必须是卡号63977008（废品同调士）或拥有效果20932152（可替代“废品同调士”的调整）的怪兽。
function c37993923.tfilter(c)
	return c:IsCode(63977008) or c:IsHasEffect(20932152)
end
-- 定义“可以变更表示形式的怪兽”的过滤函数：返回该怪兽是否能用效果改变表示形式。
function c37993923.filter(c)
	return c:IsCanChangePosition()
end
-- 第一个效果（1回合1次、可在对方回合发动的即时效果）的发动条件与取对象处理：选择对方场上1只可变更表示形式的怪兽为对象。
function c37993923.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c37993923.filter(chkc) end
	-- 发动合法性检查：确认对方场上存在至少1只可变更表示形式的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c37993923.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示选择提示“请选择要改变表示形式的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让操作者从对方怪兽区域选择1只符合条件的怪兽，并将它登记为效果对象。
	local g=Duel.SelectTarget(tp,c37993923.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，声明本效果将变更上述对象卡的表示形式（CATEGORY_POSITION）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 第二个效果的发动条件：这张卡被送去墓地时，其原所在位置必须是场上，即确实是从场上送入墓地。
function c37993923.condition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 第二个效果（从场上送去墓地时触发的选发效果）的目标选择处理：选择场上1只可变更表示形式的怪兽为对象。
function c37993923.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37993923.filter(chkc) end
	-- 发动合法性检查：确认双方怪兽区域合计存在至少1只可变更表示形式的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c37993923.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示选择提示“请选择要改变表示形式的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让操作者从双方怪兽区域选择1只符合条件的怪兽，并将它登记为效果对象。
	local g=Duel.SelectTarget(tp,c37993923.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，声明本效果将变更上述对象卡的表示形式（CATEGORY_POSITION）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 两个效果共用的效果处理函数：若对象仍与该效果关联，就变更其表示形式。
function c37993923.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 变更目标怪兽的表示形式：原表侧攻击改为表侧守备，原里侧攻击改为里侧守备，原表侧守备或里侧守备改为表侧攻击。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
