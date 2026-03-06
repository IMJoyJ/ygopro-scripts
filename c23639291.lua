--アグレッシブ・クラウディアン
-- 效果：
-- 自己场上存在的名字带有「云魔物」的怪兽被自身的效果破坏送去墓地时才能发动。从自己墓地把那1只怪兽攻击表示特殊召唤，并给那只怪兽放置1个雾指示物。这个效果特殊召唤的怪兽不会被卡的效果变成守备表示。
function c23639291.initial_effect(c)
	-- 效果定义：攻击性云魔物的发动条件、效果处理流程和目标设定
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c23639291.condition)
	e1:SetTarget(c23639291.target)
	e1:SetOperation(c23639291.operation)
	c:RegisterEffect(e1)
end
-- 自己场上存在的名字带有「云魔物」的怪兽被自身的效果破坏送去墓地时才能发动
function c23639291.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsControler(tp) and tc:IsPreviousControler(tp) and tc:IsReason(REASON_DESTROY)
		and tc:GetReasonEffect() and tc:GetReasonEffect():GetOwner()==tc
end
-- 从自己墓地把那1只怪兽攻击表示特殊召唤，并给那只怪兽放置1个雾指示物
function c23639291.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc==eg:GetFirst() end
	-- 这个效果特殊召唤的怪兽不会被卡的效果变成守备表示
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) and eg:GetFirst():IsCanBeEffectTarget(e) end
	-- 检查场上是否有足够的特殊召唤区域
	Duel.SetTargetCard(eg:GetFirst())
	-- 设置目标怪兽为连锁处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg:GetFirst(),1,0,0)
end
-- 设置操作信息，准备特殊召唤目标怪兽
function c23639291.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且成功执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 「攻击性云魔物」效果适用中
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(23639291,0))  --"「攻击性云魔物」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 完成特殊召唤流程，结束本次特殊召唤操作
		Duel.SpecialSummonComplete()
		tc:AddCounter(0x1019,1)
	end
end
