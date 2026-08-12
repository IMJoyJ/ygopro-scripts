--アモルファージ・ライシス
-- 效果：
-- 「无形噬体溶解」的②的效果1回合只能使用1次。
-- ①：「无形噬体」怪兽以外的场上的怪兽的攻击力·守备力下降场上的「无形噬体」卡数量×100。
-- ②：自己的灵摆区域的卡被破坏的场合才能发动。从卡组选1只「无形噬体」灵摆怪兽在自己的灵摆区域放置。
function c47598941.initial_effect(c)
	-- ②：自己的灵摆区域的卡被破坏的场合才能发动。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(47598941,0))  --"发动但不使用效果"
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e0:SetCondition(aux.dscon)
	c:RegisterEffect(e0)
	-- 从卡组选1只「无形噬体」灵摆怪兽在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47598941,1))  --"发动并使用②效果"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,47598941)
	e2:SetCondition(c47598941.setcon)
	e2:SetTarget(c47598941.settg)
	e2:SetOperation(c47598941.setop)
	c:RegisterEffect(e2)
	-- 「无形噬体」怪兽以外的场上的怪兽的攻击力·守备力下降场上的「无形噬体」卡数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTarget(c47598941.atktg)
	e3:SetValue(c47598941.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 判断被破坏的卡是否来自自己的灵摆区。
function c47598941.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousControler(tp)
end
-- 判断是否有自己灵摆区的卡被破坏。
function c47598941.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47598941.cfilter,1,nil,tp)
end
-- 过滤出满足条件的「无形噬体」灵摆怪兽。
function c47598941.filter(c)
	return c:IsSetCard(0xe0) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 判断是否能发动②效果，即灵摆区有空位且卡组有符合条件的怪兽。
function c47598941.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己的灵摆区是否有空位。
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 判断卡组中是否存在满足条件的「无形噬体」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c47598941.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行②效果，将符合条件的怪兽放置到灵摆区。
function c47598941.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若灵摆区无空位则不发动效果。
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择一只符合条件的「无形噬体」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c47598941.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽放置到灵摆区。
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 判断目标怪兽是否为「无形噬体」怪兽。
function c47598941.atktg(e,c)
	return not c:IsSetCard(0xe0)
end
-- 过滤出场上正面表示的「无形噬体」卡。
function c47598941.vfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0)
end
-- 计算场上「无形噬体」卡的数量并乘以-100作为攻击力和守备力的减少值。
function c47598941.atkval(e,c)
	-- 返回场上「无形噬体」卡的数量乘以-100的结果。
	return Duel.GetMatchingGroupCount(c47598941.vfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*-100
end
