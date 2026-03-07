--ジャンク・ガードナー
-- 效果：
-- 「废品同调士」＋调整以外的怪兽1只以上
-- 1回合1次，可以选择对方场上存在的1只怪兽，把表示形式变更。这个效果在对方回合也能发动。此外，这张卡从场上送去墓地的场合，可以选择场上存在的1只怪兽，把表示形式变更。
function c37993923.initial_effect(c)
	-- 为怪兽添加允许使用的素材代码列表，指定素材必须包含卡号63977008
	aux.AddMaterialCodeList(c,63977008)
	-- 添加同调召唤手续，要求1只满足tfilter条件的调整，以及1只调整以外的怪兽
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
-- tfilter函数用于判断是否为废品同调士或具有特定效果的调整
function c37993923.tfilter(c)
	return c:IsCode(63977008) or c:IsHasEffect(20932152)
end
-- filter函数用于判断怪兽是否可以改变表示形式
function c37993923.filter(c)
	return c:IsCanChangePosition()
end
-- 设置效果目标，选择对方场上可以改变表示形式的怪兽
function c37993923.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c37993923.filter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c37993923.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c37993923.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，记录将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- condition2函数用于判断该卡是否从场上送去墓地
function c37993923.condition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置效果目标，选择场上可以改变表示形式的怪兽
function c37993923.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37993923.filter(chkc) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c37993923.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c37993923.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，记录将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 执行效果操作，改变目标怪兽的表示形式
function c37993923.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽改变为表侧守备、里侧守备、表侧攻击、表侧攻击的表示形式
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
