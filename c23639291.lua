--アグレッシブ・クラウディアン
-- 效果：
-- 自己场上存在的名字带有「云魔物」的怪兽被自身的效果破坏送去墓地时才能发动。从自己墓地把那1只怪兽攻击表示特殊召唤，并给那只怪兽放置1个雾指示物。这个效果特殊召唤的怪兽不会被卡的效果变成守备表示。
function c23639291.initial_effect(c)
	-- 自己场上存在的名字带有「云魔物」的怪兽被自身的效果破坏送去墓地时才能发动。从自己墓地把那1只怪兽攻击表示特殊召唤，并给那只怪兽放置1个雾指示物。这个效果特殊召唤的怪兽不会被卡的效果变成守备表示。
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
-- 发动条件：送去墓地的怪兽只有1只，且该怪兽由自己控制、之前也由自己控制，是被自身的效果破坏送去墓地的（即破坏原因效果的拥有者就是该怪兽本身）。
function c23639291.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsControler(tp) and tc:IsPreviousControler(tp) and tc:IsReason(REASON_DESTROY)
		and tc:GetReasonEffect() and tc:GetReasonEffect():GetOwner()==tc
end
-- 取对象目标函数：对象只能是被送去墓地的那只怪兽；可发动检测要求己方主要怪兽区有空位，且那只怪兽可以攻击表示特殊召唤并可以成为效果对象。
function c23639291.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc==eg:GetFirst() end
	-- 可发动检测：确认自己场上主要怪兽区有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) and eg:GetFirst():IsCanBeEffectTarget(e) end
	-- 把被送去墓地的那只怪兽设置为当前连锁的对象。
	Duel.SetTargetCard(eg:GetFirst())
	-- 设置操作信息：本连锁为特殊召唤效果，处理对象是那只送去墓地的怪兽，数量为1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg:GetFirst(),1,0,0)
end
-- 效果处理：取得对象怪兽，若其仍与本效果相关则以攻击表示特殊召唤，然后给它赋予不会被卡的效果变成守备表示的状态，最后完成特殊召唤并给它放置1个雾指示物。
function c23639291.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡（即被送去墓地的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与本效果相关，则以攻击表示把它特殊召唤到自己场上，成功才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 这个效果特殊召唤的怪兽不会被卡的效果变成守备表示。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(23639291,0))  --"「攻击性云魔物」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 完成本次特殊召唤的处理（与Duel.SpecialSummonStep配套使用）。
		Duel.SpecialSummonComplete()
		tc:AddCounter(0x1019,1)
	end
end
