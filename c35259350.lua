--スマイル・ユニバース
-- 效果：
-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·特殊召唤，自己怪兽不能攻击。
-- ①：从自己的额外卡组把表侧表示的灵摆怪兽尽可能特殊召唤。这个效果特殊召唤的怪兽的效果无效化。那之后，对方基本分回复这个效果特殊召唤的怪兽的原本攻击力合计的数值。
function c35259350.initial_effect(c)
	-- 效果发动时，将自身设置为自由连锁时点，且具有特殊召唤和回复效果的分类
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
-- 检查在发动回合是否没有进行过召唤、特殊召唤和攻击
function c35259350.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在发动回合是否没有进行过通常召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		-- 检查在发动回合是否没有进行过特殊召唤
		and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		-- 检查在发动回合是否没有进行过攻击
		and Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0 end
	-- 为玩家创建一个不能召唤怪兽的效果，并在回合结束时重置
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将效果注册给玩家，使其不能进行召唤
	Duel.RegisterEffect(e1,tp)
	-- 为玩家创建一个不能特殊召唤怪兽的效果，并在回合结束时重置
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetLabelObject(e)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c35259350.sumlimit)
	-- 将效果注册给玩家，使其不能进行特殊召唤
	Duel.RegisterEffect(e2,tp)
	-- 为玩家创建一个不能攻击的效果，并在回合结束时重置
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家，使其不能进行攻击
	Duel.RegisterEffect(e3,tp)
end
-- 限制特殊召唤的条件，确保只有当前效果才能特殊召唤
function c35259350.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
-- 过滤满足条件的灵摆怪兽，包括表侧表示、类型为灵摆、可特殊召唤且有召唤位置
function c35259350.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组中是否有足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置连锁处理时的提示信息，包括特殊召唤和回复效果
function c35259350.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在额外卡组中是否存在满足条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35259350.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤灵摆怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息，表示将回复对方基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,0)
end
-- 处理效果发动时的特殊召唤和回复逻辑
function c35259350.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中可特殊召唤的灵摆怪兽数量
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	-- 获取满足条件的灵摆怪兽组
	local tg=Duel.GetMatchingGroup(c35259350.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=tg:Select(tp,ft,ft,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	local lp=0
	while tc do
		-- 特殊召唤一张灵摆怪兽
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 使特殊召唤的灵摆怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的灵摆怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		lp=lp+tc:GetBaseAttack()
		tc=g:GetNext()
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
	if lp>0 then
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 使对方回复特殊召唤的灵摆怪兽攻击力总和的LP
		Duel.Recover(1-tp,lp,REASON_EFFECT)
	end
end
