--四花繚乱の霊使い
-- 效果：
-- 怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升场上的怪兽的属性种类×300。
-- ②：只在这张卡表侧表示存在才有1次，自己·对方的主要阶段，以自己墓地2只相同属性而种族不同的怪兽或者2只相同种族而属性不同的怪兽为对象才能发动。那2只怪兽特殊召唤。这张卡以及这个效果特殊召唤的怪兽直到下个回合的结束时不能作为融合·同调·超量·连接召唤的素材。
local s,id,o=GetID()
-- 定义这张卡的初始化函数：注册连接召唤手续（2只以上怪兽）、苏生限制、①攻击力上升效果和②特殊召唤效果。
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续，素材为2只以上任意怪兽。
	aux.AddLinkProcedure(c,nil,2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升场上的怪兽的属性种类×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- ②：只在这张卡表侧表示存在才有1次，自己·对方的主要阶段，以自己墓地2只相同属性而种族不同的怪兽或者2只相同种族而属性不同的怪兽为对象才能发动。那2只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上的表侧表示怪兽且属性不为0（避免无属性）。
function s.atkfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=0
end
-- 计算这张卡的攻击力上升值：取场上所有表侧表示怪兽，按不同属性种数×300。
function s.atkval(e,c)
	-- 获取双方怪兽区所有满足atkfilter的怪兽（即所有表侧表示且拥有属性的怪兽）。
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 返回属性种类数×300作为攻击力上升数值。
	return aux.GetAttributeCount(g)*300
end
-- ②效果的发动条件函数：仅在主要阶段可发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前是否为主要阶段。
	return Duel.IsMainPhase()
end
-- 特殊召唤候选过滤：位于自己墓地、可以被当前效果特殊召唤并成为效果对象的怪兽。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsCanBeEffectTarget(e)
end
-- 检查所选2只怪兽是否满足：种族相同且属性不同，或属性相同且种族不同。
function s.gcheck(g)
	-- 第一种合法组合：2只怪兽种族相同，但属性不同。
	return aux.SameValueCheck(g,Card.GetRace) and not aux.SameValueCheck(g,Card.GetAttribute)
		-- 第二种合法组合：2只怪兽属性相同，但种族不同。
		or aux.SameValueCheck(g,Card.GetAttribute) and not aux.SameValueCheck(g,Card.GetRace)
end
-- ②效果的发动目标选择函数：确认发动条件、选择墓地符合条件的2只怪兽作为对象并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 从自己墓地筛选所有可特殊召唤并可作为效果对象的怪兽。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 需要自己主要怪兽区至少存在2个空位，因为要同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and g:CheckSubGroup(s.gcheck,2,2) end
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"已发动过效果"
	-- 弹出选择提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g1=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	-- 将选择组的2只怪兽设为当前连锁的对象，用于后续处理。
	Duel.SetTargetCard(g1)
	-- 设置操作信息：本次效果将特殊召唤2只怪兽（对应CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- ②效果处理函数：给这张卡和特殊召唤的怪兽附加不能作为融合/同调/超量/连接素材的限制，并执行特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 这张卡……不能作为融合·同调·超量·连接召唤的素材。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(1)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e2:SetValue(s.fuslimit)
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		c:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e4:SetDescription(aux.Stringid(id,1))  --"「四花缭乱之灵使」效果适用中"
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		c:RegisterEffect(e4)
	end
	-- 检查自己主要怪兽区的空位数量，若没有空位则无法特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取与当前连锁相关的对象卡（即之前选择的目标）。
	local sg=Duel.GetTargetsRelateToChain()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()<2 or Duel.IsPlayerAffectedByEffect(tp,59822133)
		or sg:GetCount()>ft then return end
	-- 遍历所有要特殊召唤的怪兽。
	for tc in aux.Next(sg) do
		-- 以表侧表示形式将当前怪兽加入特殊召唤流程，等待统一完成特殊召唤。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽……不能作为融合·同调·超量·连接召唤的素材。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e2:SetValue(s.fuslimit)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e4:SetDescription(aux.Stringid(id,1))  --"「四花缭乱之灵使」效果适用中"
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		tc:RegisterEffect(e4)
	end
	-- 完成整个特殊召唤流程，统一处理所有SpecialSummonStep。
	Duel.SpecialSummonComplete()
end
-- 融合素材限制的判定函数：只有作为融合召唤素材时禁止。
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
