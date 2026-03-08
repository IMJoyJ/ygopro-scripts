--エターナル・ボンド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地的「光子」怪兽任意数量为对象才能发动。那些怪兽效果无效特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以对方场上1只「光子」怪兽为对象才能发动。得到那只怪兽的控制权。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽的攻击力变成自己场上的「光子」怪兽的原本攻击力合计数值。
function c45283341.initial_effect(c)
	-- 效果原文内容：这个卡名的①②的效果1回合各能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,45283341)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c45283341.sptg)
	e1:SetOperation(c45283341.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己主要阶段把墓地的这张卡除外，以对方场上1只「光子」怪兽为对象才能发动。得到那只怪兽的控制权。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽的攻击力变成自己场上的「光子」怪兽的原本攻击力合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45283341,0))
	e2:SetCategory(CATEGORY_CONTROL+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,45283342)
	e2:SetCondition(c45283341.ctcon)
	-- 规则层面作用：将此卡除外作为发动②效果的费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c45283341.cttg)
	e2:SetOperation(c45283341.ctop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：过滤满足条件的「光子」怪兽（可特殊召唤）。
function c45283341.filter(c,e,tp)
	return c:IsSetCard(0x55) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置①效果的发动条件，检测是否满足特殊召唤的条件。
function c45283341.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45283341.filter(chkc,e,tp) end
	-- 规则层面作用：检测场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检测自己墓地是否有满足条件的「光子」怪兽。
		and Duel.IsExistingTarget(c45283341.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：获取玩家当前可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 规则层面作用：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择满足条件的墓地「光子」怪兽作为特殊召唤对象。
	local g=Duel.SelectTarget(tp,c45283341.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 规则层面作用：处理①效果的发动，执行特殊召唤及效果无效化。
function c45283341.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：获取玩家当前可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 规则层面作用：获取当前连锁的目标卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 规则层面作用：提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	local tc=sg:GetFirst()
	while tc do
		-- 规则层面作用：特殊召唤一张怪兽。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 效果原文内容：那些怪兽效果无效特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 效果原文内容：那些怪兽效果无效特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc=sg:GetNext()
	end
	-- 规则层面作用：完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
-- 规则层面作用：设置②效果的发动条件，判断是否处于主要阶段。
function c45283341.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否处于主要阶段。
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 规则层面作用：过滤满足条件的对方场上的「光子」怪兽（可改变控制权）。
function c45283341.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55) and c:IsControlerCanBeChanged()
end
-- 规则层面作用：设置②效果的发动条件，检测是否满足改变控制权的条件。
function c45283341.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c45283341.ctfilter(chkc) end
	-- 规则层面作用：检测对方场上是否有满足条件的「光子」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c45283341.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面作用：提示玩家选择要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 规则层面作用：选择满足条件的对方场上的「光子」怪兽作为目标。
	local g=Duel.SelectTarget(tp,c45283341.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 规则层面作用：设置连锁操作信息，表明将要改变控制权的卡。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 规则层面作用：过滤满足条件的己方场上的「光子」怪兽（用于计算攻击力）。
function c45283341.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55)
end
-- 规则层面作用：处理②效果的发动，执行改变控制权及攻击力变更。
function c45283341.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断目标怪兽是否有效且成功获得控制权。
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp)~=0 then
		local atk=0
		-- 规则层面作用：获取己方场上的「光子」怪兽。
		local g=Duel.GetMatchingGroup(c45283341.atkfilter,tp,LOCATION_MZONE,0,nil)
		if g:GetCount()>0 then atk=g:GetSum(Card.GetBaseAttack) end
		-- 效果原文内容：那只怪兽的攻击力变成自己场上的「光子」怪兽的原本攻击力合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果原文内容：这个回合，自己不用那只怪兽不能攻击宣言。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(c45283341.ftarget)
		e2:SetLabel(tc:GetFieldID())
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 规则层面作用：注册攻击宣言禁止效果。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 规则层面作用：设置攻击宣言禁止效果的目标。
function c45283341.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
