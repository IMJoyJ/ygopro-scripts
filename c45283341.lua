--エターナル・ボンド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地的「光子」怪兽任意数量为对象才能发动。那些怪兽效果无效特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以对方场上1只「光子」怪兽为对象才能发动。得到那只怪兽的控制权。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽的攻击力变成自己场上的「光子」怪兽的原本攻击力合计数值。
function c45283341.initial_effect(c)
	-- ①：以自己墓地的「光子」怪兽任意数量为对象才能发动。那些怪兽效果无效特殊召唤。
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
	-- ②：自己主要阶段把墓地的这张卡除外，以对方场上1只「光子」怪兽为对象才能发动。得到那只怪兽的控制权。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽的攻击力变成自己场上的「光子」怪兽的原本攻击力合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45283341,0))
	e2:SetCategory(CATEGORY_CONTROL+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,45283342)
	e2:SetCondition(c45283341.ctcon)
	-- 设置②效果的发动代价：把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c45283341.cttg)
	e2:SetOperation(c45283341.ctop)
	c:RegisterEffect(e2)
end
-- 定义①效果的怪兽过滤器：选择自己墓地中「光子」字段且能够被当前效果特殊召唤的怪兽（不忽略召唤条件与苏生限制）。
function c45283341.filter(c,e,tp)
	return c:IsSetCard(0x55) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的取对象处理：合法性检查时确认自己的主要怪兽区有空位，且墓地存在可特殊召唤的「光子」怪兽；对象确认时验证目标位于自己墓地且满足条件。
function c45283341.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45283341.filter(chkc,e,tp) end
	-- 发动条件检查：自己主要怪兽区必须存在至少1个可用空格，才能特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地必须存在至少1只满足「光子」字段且可特殊召唤的怪兽，作为取对象目标。
		and Duel.IsExistingTarget(c45283341.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取自己主要怪兽区的当前可用空格数，用于限制本次最多可选择特殊召唤的怪兽数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡（显示“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地的「光子」怪兽中选择1到可用空格数张作为效果对象，并将这些卡设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c45283341.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 登记本次操作信息为特殊召唤，对象为所选怪兽，数量为其张数，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- ①效果处理时：从对象中筛掉已不关联的卡；若青眼精灵龙在场且对象数大于1则不能处理；若对象数超过可用格则选择可处理的张数；逐只以表侧表示特殊召唤，并给每只赋予效果无效和效果无效化状态，最后完成特殊召唤。
function c45283341.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次获取自己主要怪兽区的可用空格数；若没有空格则终止特殊召唤处理。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 取得当前连锁中记录的发动时选择的对象卡组，用于确定要特殊召唤的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 当可特殊召唤对象数量超过可用区域时，提示玩家选择要实际特殊召唤的卡（显示“请选择要特殊召唤的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	local tc=sg:GetFirst()
	while tc do
		-- 将当前怪兽以表侧表示特殊召唤到己方场上，作为同时特殊召唤多只怪兽的中间步骤（不跳过召唤条件与苏生限制）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 那些怪兽效果无效特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 那些怪兽效果无效特殊召唤。②：自己主要阶段把墓地的这张卡除外，以对方场上1只「光子」怪兽为对象才能发动。得到那只怪兽的控制权。这个回合，自己不用那只怪兽不能攻击宣言，那只怪兽的攻击力变成自己场上的「光子」怪兽的原本攻击力合计数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc=sg:GetNext()
	end
	-- 完成多只怪兽的特殊召唤流程，统一触发召唤成功相关时点，并结束①效果的特殊召唤处理。
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件：仅在自己的回合的主要阶段1或主要阶段2（即自己主要阶段）才能发动。
function c45283341.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家是效果发动者，且所处阶段为主要阶段1或主要阶段2，满足②效果的发动时点。
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- ②效果的取对象过滤器：选择对方场上表侧表示且属于「光子」字段、控制权可以被变更的怪兽。
function c45283341.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55) and c:IsControlerCanBeChanged()
end
-- ②效果的目标选择处理：检查对方场上是否存在符合条件的「光子」怪兽；若存在则提示并选择其中1只作为对象，同时登记为改变控制权的操作。
function c45283341.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c45283341.ctfilter(chkc) end
	-- 发动合法性检查：对方场上必须存在至少1只表侧表示、可变更控制权的「光子」怪兽，才能以之作为对象发动。
	if chk==0 then return Duel.IsExistingTarget(c45283341.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，让玩家选择要改变控制权的怪兽（显示“请选择要改变控制权的怪兽”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 玩家从对方场上选择1只表侧表示「光子」且控制权可变更的怪兽作为效果对象，并建立对象关联。
	local g=Duel.SelectTarget(tp,c45283341.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记本次操作信息为改变控制权，对象为1只怪兽，供后续效果检测与连锁处理使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 定义攻击力合计用过滤器：选取自己场上表侧表示且属于「光子」字段的怪兽，用于计算原本攻击力总和。
function c45283341.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55)
end
-- ②效果处理时：若对象仍与效果关联且成功夺取其控制权，则计算己方所有表侧「光子」怪兽的原本攻击力总和，将对象的攻击力变更为该数值；同时给自己场上除该对象外的怪兽附加“不能攻击宣言”的限制，持续到回合结束。
function c45283341.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的唯一的对象怪兽（对方场上的「光子」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果有联系，并且成功取得其控制权后，才开始处理攻击力变更与攻击限制。
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp)~=0 then
		local atk=0
		-- 取得己方场上所有表侧表示「光子」怪兽的集合，用于计算合计原本攻击力。
		local g=Duel.GetMatchingGroup(c45283341.atkfilter,tp,LOCATION_MZONE,0,nil)
		if g:GetCount()>0 then atk=g:GetSum(Card.GetBaseAttack) end
		-- 那只怪兽的攻击力变成自己场上的「光子」怪兽的原本攻击力合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合，自己不用那只怪兽不能攻击宣言。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(c45283341.ftarget)
		e2:SetLabel(tc:GetFieldID())
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将“除那只怪兽外己方怪兽不能攻击宣言”的场地效果注册到场上，持续到回合结束，从而限制自己只能用那只怪兽进行攻击。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 该过滤条件判断正在尝试攻击宣言的怪兽是否不是被夺取控制权的那只对象怪兽（通过FieldID比较）；若是其他怪兽则禁止攻击。
function c45283341.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
