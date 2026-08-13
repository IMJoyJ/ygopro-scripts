--スマイル・ユニバース
-- 效果：
-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·特殊召唤，自己怪兽不能攻击。
-- ①：从自己的额外卡组把表侧表示的灵摆怪兽尽可能特殊召唤。这个效果特殊召唤的怪兽的效果无效化。那之后，对方基本分回复这个效果特殊召唤的怪兽的原本攻击力合计的数值。
function c35259350.initial_effect(c)
	-- ①：从自己的额外卡组把表侧表示的灵摆怪兽尽可能特殊召唤。这个效果特殊召唤的怪兽的效果无效化。那之后，对方基本分回复这个效果特殊召唤的怪兽的原本攻击力合计的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c35259350.cost)
	e1:SetTarget(c35259350.target)
	e1:SetOperation(c35259350.activate)
	c:RegisterEffect(e1)
end
-- 发动前检查我方本回合未进行过召唤、特殊召唤和攻击，以满足“这张卡发动的回合”的自肃条件。
function c35259350.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检测阶段：确认我方本回合的通常召唤（含放置）次数为0。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		-- 费用检测阶段：确认我方本回合的特殊召唤次数为0。
		and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		-- 费用检测阶段：确认我方本回合的攻击次数为0。
		and Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 自己不能用这张卡的效果以外把怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将“不能召唤”的誓约自肃效果注册给发动玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 自己不能用这张卡的效果以外把怪兽特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetLabelObject(e)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c35259350.sumlimit)
	-- 将“不能特殊召唤”的誓约自肃效果注册给发动玩家，同时允许通过本卡效果进行的特殊召唤。
	Duel.RegisterEffect(e2,tp)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·特殊召唤，自己怪兽不能攻击。①：从自己的额外卡组把表侧表示的灵摆怪兽尽可能特殊召唤。这个效果特殊召唤的怪兽的效果无效化。那之后，对方基本分回复这个效果特殊召唤的怪兽的原本攻击力合计的数值。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将“自己怪兽不能攻击”的誓约自肃效果注册给发动玩家，持续到结束阶段。
	Duel.RegisterEffect(e3,tp)
end
-- 判定即将进行的特殊召唤是否不由本卡效果发动：若不是本卡效果（e）发动的特殊召唤则返回true，表示应受到禁止。
function c35259350.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
-- 筛选额外卡组中表侧表示的灵摆怪兽，且该怪兽能被玩家tp特殊召唤，并且额外灵摆怪兽有可用特殊召唤区域。
function c35259350.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 额外卡组怪兽可用的主怪兽区/额外怪兽区空格数需大于0，保证该灵摆怪兽能够从额外卡组特殊召唤。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 发动的目标检测：确认额外卡组存在至少1只符合条件的表侧灵摆怪兽，并设置本次操作包含特殊召唤与回复生命值。
function c35259350.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法检测阶段，检查额外卡组是否存在至少1只符合筛选条件的表侧灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c35259350.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向系统登记本次效果包含特殊召唤，预计从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 向系统登记本次效果包含回复生命值，回复对象为对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,0)
end
-- 效果处理：计算可用区域数并选取符合条件的灵摆怪兽，逐个特殊召唤并使其效果无效化，累计原本攻击力，最后让对方回复合计数值；同时受“青眼精灵龙”影响时只能特殊召唤1只。
function c35259350.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算从额外卡组把灵摆怪兽特殊召唤到场上可用的空格数（用于确定“尽可能”的数量）。
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	-- 取得额外卡组中所有符合条件的表侧灵摆怪兽的集合。
	local tg=Duel.GetMatchingGroup(c35259350.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示发动玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=tg:Select(tp,ft,ft,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	local lp=0
	while tc do
		-- 将选中的怪兽以表侧攻击表示逐个特殊召唤到己方场上（分步处理，以便附加无效化效果）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化（防止其效果在场上发动或适用）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		lp=lp+tc:GetBaseAttack()
		tc=g:GetNext()
	end
	-- 完成连续特殊召唤的收尾处理，统一触发特殊召唤成功时点。
	Duel.SpecialSummonComplete()
	if lp>0 then
		-- 中断当前效果处理，使后续回复生命值部分与特殊召唤部分不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 让对方玩家回复相当于这些特殊召唤怪兽原本攻击力合计数值的基本分。
		Duel.Recover(1-tp,lp,REASON_EFFECT)
	end
end
