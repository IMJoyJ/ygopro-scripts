--アグレッシブ・クラウディアン
-- 效果：
-- 自己场上存在的名字带有「云魔物」的怪兽被自身的效果破坏送去墓地时才能发动。从自己墓地把那1只怪兽攻击表示特殊召唤，并给那只怪兽放置1个雾指示物。这个效果特殊召唤的怪兽不会被卡的效果变成守备表示。
function c23639291.initial_effect(c)
	-- 效果初始化，设置效果类型为发动效果，触发条件为怪兽被破坏送入墓地，目标为符合条件的怪兽，处理函数为operation
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
c23639291.mentioned_counter={
	[0x1019]=true,
}
-- 效果发动条件：场上1只名字带有「云魔物」的怪兽被自身效果破坏送去墓地时才能发动
function c23639291.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsControler(tp) and tc:IsPreviousControler(tp) and tc:IsReason(REASON_DESTROY)
		and tc:GetReasonEffect() and tc:GetReasonEffect():GetOwner()==tc
end
-- 效果处理目标设定：检查是否能将目标怪兽特殊召唤并作为效果对象
function c23639291.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc==eg:GetFirst() end
	-- 判断场上是否有足够空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) and eg:GetFirst():IsCanBeEffectTarget(e) end
	-- 设置当前连锁的目标卡为被破坏送入墓地的那只怪兽
	Duel.SetTargetCard(eg:GetFirst())
	-- 设置操作信息，表示将要特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg:GetFirst(),1,0,0)
end
-- 效果处理函数：将目标怪兽从墓地攻击表示特殊召唤，并给其放置1个雾指示物，且该怪兽不会被卡的效果变成守备表示
function c23639291.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡有效并执行特殊召唤步骤，以攻击表示加入场上
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 为特殊召唤的怪兽添加效果，使其不会被卡的效果变成守备表示
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(23639291,0))  --"「攻击性云魔物」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		tc:AddCounter(0x1019,1)
	end
end
