--四花繚乱の霊使い
-- 效果：
-- 怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升场上的怪兽的属性种类×300。
-- ②：只在这张卡表侧表示存在才有1次，自己·对方的主要阶段，以自己墓地2只相同属性而种族不同的怪兽或者2只相同种族而属性不同的怪兽为对象才能发动。那2只怪兽特殊召唤。这张卡以及这个效果特殊召唤的怪兽直到下个回合的结束时不能作为融合·同调·超量·连接召唤的素材。
local s,id,o=GetID()
-- 初始化效果，添加连接召唤手续并启用复活限制，设置攻击力上升效果和特殊召唤效果
function s.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求至少2个连接素材
	aux.AddLinkProcedure(c,nil,2)
	c:EnableReviveLimit()
	-- 设置攻击力上升效果，数值为场上怪兽数量乘以300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- 设置特殊召唤效果，可在主要阶段发动，只能发动一次，目标为墓地符合条件的2只怪兽
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
-- 过滤场上正面表示且具有属性的怪兽
function s.atkfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=0
end
-- 计算场上怪兽属性种类数并乘以300作为攻击力提升值
function s.atkval(e,c)
	-- 获取场上正面表示且具有属性的怪兽组
	local g=Duel.GetMatchingGroup(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 返回场上怪兽属性种类数乘以300
	return aux.GetAttributeCount(g)*300
end
-- 判断是否在主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否在主要阶段
	return Duel.IsMainPhase()
end
-- 过滤可特殊召唤且可成为效果对象的怪兽
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsCanBeEffectTarget(e)
end
-- 检查怪兽组是否满足相同属性不同种族或相同种族不同属性的条件
function s.gcheck(g)
	-- 检查怪兽组是否满足相同种族不同属性的条件
	return aux.SameValueCheck(g,Card.GetRace) and not aux.SameValueCheck(g,Card.GetAttribute)
		-- 检查怪兽组是否满足相同属性不同种族的条件
		or aux.SameValueCheck(g,Card.GetAttribute) and not aux.SameValueCheck(g,Card.GetRace)
end
-- 设置特殊召唤效果的发动条件，检查是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取墓地符合条件的怪兽组
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的召唤位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and g:CheckSubGroup(s.gcheck,2,2) end
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"已发动过效果"
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g1=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	-- 设置效果的目标卡组
	Duel.SetTargetCard(g1)
	-- 设置效果操作信息，指定将要特殊召唤的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 处理特殊召唤效果的发动，设置效果适用期间的限制并执行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 设置该卡不能作为连接召唤素材的效果
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
	-- 获取玩家场上可用的召唤位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取与连锁相关的卡组
	local sg=Duel.GetTargetsRelateToChain()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()<2 or Duel.IsPlayerAffectedByEffect(tp,59822133)
		or sg:GetCount()>ft then return end
	-- 遍历卡组中的每张卡
	for tc in aux.Next(sg) do
		-- 特殊召唤一张卡
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 设置特殊召唤的怪兽不能作为连接召唤素材的效果
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
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 设置融合召唤素材限制函数，返回是否为融合召唤
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
