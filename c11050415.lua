--超カバーカーニバル
-- 效果：
-- ①：从自己的手卡·卡组·墓地选1只「娱乐伙伴 探寻河马」特殊召唤。那之后，可以在自己场上把「河马衍生物」（兽族·地·1星·攻/守0）尽可能特殊召唤。这衍生物不能解放。只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。这个效果把「河马衍生物」特殊召唤的场合，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
function c11050415.initial_effect(c)
	-- 效果原文内容：①：从自己的手卡·卡组·墓地选1只「娱乐伙伴 探寻河马」特殊召唤。那之后，可以在自己场上把「河马衍生物」（兽族·地·1星·攻/守0）尽可能特殊召唤。这衍生物不能解放。只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。这个效果把「河马衍生物」特殊召唤的场合，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11050415.target)
	e1:SetOperation(c11050415.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否可以特殊召唤「娱乐伙伴 探寻河马」
function c11050415.filter(c,e,tp)
	return c:IsCode(41440148) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的判断函数，用于确认是否满足发动条件
function c11050415.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡·卡组·墓地是否存在「娱乐伙伴 探寻河马」
		and Duel.IsExistingMatchingCard(c11050415.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只「娱乐伙伴 探寻河马」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 效果发动时的处理函数
function c11050415.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的「娱乐伙伴 探寻河马」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的「娱乐伙伴 探寻河马」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11050415.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「娱乐伙伴 探寻河马」特殊召唤
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 判断是否可以继续特殊召唤衍生物
		if ft<=0 or (Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1) then return end
		-- 检查玩家是否可以特殊召唤「河马衍生物」
		if Duel.IsPlayerCanSpecialSummonMonster(tp,18027139,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH)
			-- 询问玩家是否继续特殊召唤「河马衍生物」
			and Duel.SelectYesNo(tp,aux.Stringid(11050415,0)) then  --"是否尽可能地特殊召唤「河马衍生物」？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			local c=e:GetHandler()
			for i=1,ft do
				-- 创建「河马衍生物」衍生物
				local token=Duel.CreateToken(tp,11050415+i)
				-- 将「河马衍生物」特殊召唤到场上
				Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
				-- 效果原文内容：这衍生物不能解放。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UNRELEASABLE_SUM)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				token:RegisterEffect(e2)
				-- 效果原文内容：只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_FIELD)
				e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e3:SetRange(LOCATION_MZONE)
				e3:SetAbsoluteRange(tp,1,0)
				e3:SetTarget(c11050415.splimit)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				token:RegisterEffect(e3)
			end
			-- 完成所有衍生物的特殊召唤步骤
			Duel.SpecialSummonComplete()
			-- 效果原文内容：这个效果把「河马衍生物」特殊召唤的场合，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
			e1:SetTargetRange(0,LOCATION_MZONE)
			e1:SetValue(c11050415.atlimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册战斗限制效果，使对方不能攻击非「河马衍生物」的怪兽
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 限制特殊召唤的过滤函数，用于阻止从额外卡组特殊召唤
function c11050415.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 限制攻击目标的过滤函数，用于阻止攻击非「河马衍生物」的怪兽
function c11050415.atlimit(e,c)
	return not c:IsCode(18027139)
end
