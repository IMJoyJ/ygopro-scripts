--超カバーカーニバル
-- 效果：
-- ①：从自己的手卡·卡组·墓地选1只「娱乐伙伴 探寻河马」特殊召唤。那之后，可以在自己场上把「河马衍生物」（兽族·地·1星·攻/守0）尽可能特殊召唤。这衍生物不能解放。只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。这个效果把「河马衍生物」特殊召唤的场合，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
function c11050415.initial_effect(c)
	-- ①：从自己的手卡·卡组·墓地选1只「娱乐伙伴 探寻河马」特殊召唤。那之后，可以在自己场上把「河马衍生物」（兽族·地·1星·攻/守0）尽可能特殊召唤。这衍生物不能解放。只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。这个效果把「河马衍生物」特殊召唤的场合，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c11050415.target)
	e1:SetOperation(c11050415.activate)
	c:RegisterEffect(e1)
end
-- 过滤器：选择卡号为41440148的「娱乐伙伴 探寻河马」，并确认其能被当前效果特殊召唤（满足召唤条件与苏生限制）。
function c11050415.filter(c,e,tp)
	return c:IsCode(41440148) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的判定：自己主要怪兽区有空位，并且手卡·卡组·墓地中存在至少1只符合条件的「娱乐伙伴 探寻河马」。
function c11050415.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区区域（用于特殊召唤）。若为0则无法发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组·墓地中是否存在至少1只满足过滤器c11050415.filter的「娱乐伙伴 探寻河马」。
		and Duel.IsExistingMatchingCard(c11050415.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置操作信息：从自己的手卡·卡组·墓地（0x13）中特殊召唤1只怪兽，分类为特殊召唤，供连锁处理时的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 效果处理：先特殊召唤「娱乐伙伴 探寻河马」；若成功，检查剩余可用主要怪兽区，若没有空位或受青眼精灵龙影响（不能同时特召2只以上）则不再特召衍生物；否则询问玩家后尽可能特殊召唤「河马衍生物」，给每个衍生物附加不能解放和不能从额外卡组特召的限制，最后注册对方只能攻击「河马衍生物」的效果直到回合结束。
function c11050415.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 开始处理时再次确认自己仍有可用的主要怪兽区；若没有，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，方便玩家识别选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组·墓地中选择1只满足过滤器的「娱乐伙伴 探寻河马」，过滤时使用aux.NecroValleyFilter排除因王家长眠之谷而不能被特殊召唤的墓地卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11050415.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上；若没有成功特殊召唤任何怪兽，则终止后续处理。
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 获取自己场上当前剩余的主要怪兽区空格数量，用于计算最多能特殊召唤多少只「河马衍生物」。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft<=0 or (Duel.IsPlayerAffectedByEffect(tp,59822133) and ft>1) then return end
		-- 检查当前玩家是否能够特殊召唤「河马衍生物」（衍生物参数：兽族·地·1星·攻/守0）。
		if Duel.IsPlayerCanSpecialSummonMonster(tp,18027139,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH)
			-- 弹出选择框询问玩家是否要“尽可能地特殊召唤「河马衍生物」？”
			and Duel.SelectYesNo(tp,aux.Stringid(11050415,0)) then  --"是否尽可能地特殊召唤「河马衍生物」？"
			-- 中断当前效果处理，使后续衍生物的特殊召唤与之前的特殊召唤错开时点处理。
			Duel.BreakEffect()
			local c=e:GetHandler()
			for i=1,ft do
				-- 创建「河马衍生物」衍生物，其卡号使用11050415+i（即11050416等衍生物模板）。
				local token=Duel.CreateToken(tp,11050415+i)
				-- 将衍生物作为特殊召唤的中间步骤加入特殊召唤处理，表侧表示特殊召唤到自己场上。
				Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
				-- 这衍生物不能解放。
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
				-- 只要「河马衍生物」在怪兽区域存在，自己不能从额外卡组把怪兽特殊召唤。
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
			-- 完成所有衍生物的特殊召唤处理，将特殊召唤步骤统一结算。
			Duel.SpecialSummonComplete()
			-- 这个效果把「河马衍生物」特殊召唤的场合，直到回合结束时对方不能把「河马衍生物」以外的怪兽作为攻击对象。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
			e1:SetTargetRange(0,LOCATION_MZONE)
			e1:SetValue(c11050415.atlimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将“对方不能选择「河马衍生物」以外的怪兽作为攻击对象”的场上效果注册给自己（持续到结束阶段）。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- splimit判断函数：当要特殊召唤的怪兽位于额外卡组时返回true，表示不允许从额外卡组特殊召唤。
function c11050415.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
-- atlimit判断函数：当怪兽卡号不是18027139（「河马衍生物」）时返回true，表示对方不能选择该怪兽作为攻击对象。
function c11050415.atlimit(e,c)
	return not c:IsCode(18027139)
end
