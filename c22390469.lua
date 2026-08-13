--GP－スター・リオン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力上升那只怪兽的原本攻击力数值。自己基本分比对方少的场合，可以再把作为对象的怪兽破坏。
-- ②：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-马狮利昂」特殊召唤。
local s,id,o=GetID()
-- 初始化效果处理函数：为这张卡登记记载的关联卡名、添加同调召唤手续、赋予苏生限制，并分别注册①的诱发即时效果和②的结束阶段诱发必发效果。
function s.initial_effect(c)
	-- 将卡号23512906（黄金荣耀-马狮利昂）登记为本卡记述的关联卡名，用于相关检索或判定。
	aux.AddCodeList(c,23512906)
	-- 为这张卡添加同调召唤手续：调整怪兽＋调整以外的怪兽1只以上（这里滤镜为任意调整以外怪兽，数量1）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应①效果：自己·对方的主要阶段，以对方场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力上升那只怪兽的原本攻击力数值。自己基本分比对方少的场合，可以再把作为对象的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- 对应②效果：这张卡的①的效果发动的回合的结束阶段发动。这张卡回到额外卡组，从自己的卡组·墓地把1只「黄金荣耀-马狮利昂」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判断函数：只有在主要阶段1或主要阶段2（即自己·对方的主要阶段）才能发动。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 对象过滤条件：对方场上的怪兽必须表侧表示，且原本攻击力大于0。
function s.atkfilter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
end
-- ①效果的发动目标处理：选择对方场上1只表侧表示且原本攻击力大于0的怪兽作为对象，并为本卡标记已发动过①效果的flag，供②效果在结束阶段触发。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.atkfilter(chkc) end
	-- 发动时检查是否存在符合条件的合法对象（对方场上表侧表示且原本攻击力大于0的怪兽）。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从对方场上选择1只符合条件的表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果处理函数：根据对象怪兽的原本攻击力提升自身攻击力；若自己LP少于对方且玩家选择破坏，则将对象怪兽破坏。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetBaseAttack()
	if c:IsRelateToEffect(e) and c:IsFaceup()
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and atk>0 then
		-- 对应效果原文：这张卡的攻击力上升那只怪兽的原本攻击力数值。——为这张卡赋予持续上升攻击力的效果，上升值等于对象怪兽的原本攻击力，卡片离场或效果无效时重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 判断是否满足额外的破坏条件：自己基本分比对方少，并由玩家确认是否追加破坏对象怪兽。
		if Duel.GetLP(tp)<Duel.GetLP(1-tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把那只怪兽破坏？"
			-- 中断当前效果处理，使后续的破坏处理作为另一次效果处理进行，避免造成时点被错过。
			Duel.BreakEffect()
			-- 将对象怪兽通过效果破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：本回合已经使用过①效果（持有对应的flag标记），因此在结束阶段发动。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- ②效果的目标设定：无条件可以发动，设置将自身送回额外卡组以及从卡组·墓地特殊召唤1只「黄金荣耀-马狮利昂」的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：把效果发动者自身送入额外卡组（回额外卡组）的处理类别和对象。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
	-- 设置操作信息：从卡组·墓地特殊召唤1只「黄金荣耀-马狮利昂」（处理时再选择具体来源），目标玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 特殊召唤的过滤条件：要特殊召唤的卡必须是「黄金荣耀-马狮利昂」，并且可以被玩家tp以效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(23512906) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理函数：这张卡先返回额外卡组；若成功返回且自己场上仍有空位，则从自己的卡组·墓地选择1只「黄金荣耀-马狮利昂」表侧表示特殊召唤。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsExtraDeckMonster()
		-- 将自身送入额外卡组（通过返回卡组的操作实现），并确认该卡已经回到额外卡组，即“这张卡回到额外卡组”这一处理成功。
		and Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA)
		-- 确认操作玩家场上有可用的主要怪兽区域空位，以进行后续特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从操作玩家的卡组·墓地选择1只符合条件的「黄金荣耀-马狮利昂」，并过滤掉受王家长眠之谷影响而不能从墓地特殊召唤的卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			-- 将选择的「黄金荣耀-马狮利昂」以表侧表示特殊召唤到操作玩家场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
