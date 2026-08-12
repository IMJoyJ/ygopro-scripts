--レスキューキャット
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把场上的这张卡送去墓地才能发动。从卡组把2只3星以下的兽族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c14878871.initial_effect(c)
	-- ①：把场上的这张卡送去墓地才能发动。从卡组把2只3星以下的兽族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14878871,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,14878871)
	e1:SetCost(c14878871.spcost)
	e1:SetTarget(c14878871.sptg)
	e1:SetOperation(c14878871.spop)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件，即确认此卡可以作为费用送去墓地
function c14878871.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为发动费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选满足条件的怪兽（3星以下、兽族、可特殊召唤）
function c14878871.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置发动时的处理目标，检查是否满足发动条件
function c14878871.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少2只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c14878871.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数
function c14878871.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 如果场上没有足够的怪兽区域则不发动
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	-- 获取卡组中满足条件的怪兽数组
	local g=Duel.GetMatchingGroup(c14878871.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		local fid=e:GetHandler():GetFieldID()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,2,2,nil)
		local tc=sg:GetFirst()
		while tc do
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 使特殊召唤的怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使特殊召唤的怪兽效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(14878871,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc=sg:GetNext()
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 注册结束阶段破坏效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(sg)
		e3:SetCondition(c14878871.descon)
		e3:SetOperation(c14878871.desop)
		-- 将结束阶段破坏效果注册到场上
		Duel.RegisterEffect(e3,tp)
	end
end
-- 用于判断是否为本次特殊召唤的怪兽
function c14878871.desfilter(c,fid)
	return c:GetFlagEffectLabel(14878871)==fid
end
-- 判断是否满足结束阶段破坏的条件
function c14878871.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c14878871.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行结束阶段破坏操作
function c14878871.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c14878871.desfilter,nil,e:GetLabel())
	-- 将满足条件的怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
