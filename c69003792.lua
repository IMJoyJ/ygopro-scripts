--メガリス・アンフォームド
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●对方场上的全部怪兽的攻击力直到回合结束时下降场上的仪式怪兽数量×500。
-- ●等级合计直到变成仪式召唤的怪兽的等级的2倍为止，把自己的手卡·场上的怪兽解放，从卡组把1只「巨石遗物」仪式怪兽守备表示仪式召唤。
function c69003792.initial_effect(c)
	-- ●对方场上的全部怪兽的攻击力直到回合结束时下降场上的仪式怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69003792,0))  --"攻击力下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果的发动条件（限制在伤害步骤的伤害计算前可以发动）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c69003792.atktg)
	e1:SetOperation(c69003792.atkop)
	c:RegisterEffect(e1)
	-- ●等级合计直到变成仪式召唤的怪兽的等级的2倍为止，把自己的手卡·场上的怪兽解放，从卡组把1只「巨石遗物」仪式怪兽守备表示仪式召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69003792,1))  --"仪式召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(c69003792.sptg)
	e2:SetOperation(c69003792.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的仪式怪兽
function c69003792.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL)
end
-- 第一效果（降低攻击力）的发动准备与合法性检查
function c69003792.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只表侧表示的仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69003792.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查对方场上是否存在至少1只表侧表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 第一效果（降低攻击力）的处理函数
function c69003792.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上表侧表示的仪式怪兽数量
	local ct=Duel.GetMatchingGroupCount(c69003792.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到回合结束时下降场上的仪式怪兽数量×500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 仪式怪兽的过滤与合法性检查函数，判断卡组中的仪式怪兽是否能以等级2倍的祭品进行仪式召唤
function c69003792.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk))
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,POS_FACEUP_DEFENSE) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=level_function(c)
	-- 设置全局附加检查函数，用于在选择祭品时校验等级合计是否刚好等于目标仪式怪兽等级的2倍
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv*2,greater_or_equal)
	-- 检查祭品怪兽组中是否存在满足仪式召唤条件（等级合计等于目标等级2倍）的子集
	local res=mg:CheckSubGroup(aux.RitualCheck,1,lv*2,tp,c,lv*2,greater_or_equal)
	-- 清空全局附加检查函数，避免影响后续的其他检查
	aux.GCheckAdditional=nil
	return res
end
-- 过滤条件：属于「巨石遗物」系列的卡片
function c69003792.rfilter(c,e,tp)
	return c:IsSetCard(0x138)
end
-- 第二效果（仪式召唤）的发动准备与合法性检查
function c69003792.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家当前可用的仪式素材（手卡、场上可解放的怪兽）
	local mg=Duel.GetRitualMaterial(tp)
	-- 检查卡组中是否存在可以进行仪式召唤的「巨石遗物」仪式怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69003792.RitualUltimateFilter,tp,LOCATION_DECK,0,1,nil,c69003792.rfilter,e,tp,mg,nil,Card.GetLevel,"Equal") end
	-- 设置连锁运营信息，表示此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 第二效果（仪式召唤）的处理函数
function c69003792.spop(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 重新获取当前可用的仪式素材
	local mg=Duel.GetRitualMaterial(tp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足仪式召唤条件的「巨石遗物」仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,c69003792.RitualUltimateFilter,tp,LOCATION_DECK,0,1,1,nil,c69003792.rfilter,e,tp,mg,nil,Card.GetLevel,"Equal")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置全局附加检查函数，限制所选祭品的等级合计必须严格等于该仪式怪兽等级的2倍
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel()*2,"Equal")
		-- 让玩家选择用于仪式召唤的祭品怪兽组
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel()*2,tp,tc,tc:GetLevel()*2,"Equal")
		-- 清空全局附加检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果，使后续的特殊召唤处理与解放处理不视为同时进行
		Duel.BreakEffect()
		-- 将选定的仪式怪兽以守备表示进行仪式召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP_DEFENSE)
		tc:CompleteProcedure()
	end
end
