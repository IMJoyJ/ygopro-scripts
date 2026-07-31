--捕食植物ドラゴスタペリア
-- 效果：
-- 融合怪兽＋暗属性怪兽
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。这个效果在对方回合也能发动。
-- ②：只要这张卡在怪兽区域存在，对方发动的有捕食指示物放置的怪兽的效果无效化。
function c69946549.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤手续：融合怪兽＋暗属性怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),true)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69946549,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c69946549.cttg)
	e1:SetOperation(c69946549.ctop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方发动的有捕食指示物放置的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c69946549.discon)
	e2:SetOperation(c69946549.disop)
	c:RegisterEffect(e2)
end
c69946549.mentioned_counter={
	[0x1041]=true,
}
-- ①效果发动准备：选择对方场上1只表侧表示怪兽作为对象并设置指示物分类
function c69946549.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1041,1) end
	-- 发动条件检查：对方场上是否存在可放置1个捕食指示物（0x1041）的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1041,1) end
	-- 显示提示：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只可放置捕食指示物的表侧表示怪兽作为对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1041,1)
end
-- ①效果处理：给对象怪兽放置1个捕食指示物，若其等级在2级以上则使其等级变为1级
function c69946549.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:AddCounter(0x1041,1) and tc:IsLevelAbove(2) then
		-- 使拥有捕食指示物的怪兽等级变成1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c69946549.lvcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 等级变1判定条件：持有捕食指示物（0x1041）数量大于0
function c69946549.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- ②效果无效条件：对方发动的怪兽效果且该怪兽带有捕食指示物
function c69946549.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetCounter(0x1041)>0
end
-- ②效果处理：将该怪兽发动的效果无效化
function c69946549.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该连锁的效果处理
	Duel.NegateEffect(ev)
end
