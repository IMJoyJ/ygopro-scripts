--フォトン・サンクチュアリ
-- 效果：
-- 这张卡发动的回合，自己不是光属性怪兽不能召唤·反转召唤·特殊召唤。
-- ①：在自己场上把2只「光子衍生物」（雷族·光·4星·攻2000/守0）守备表示特殊召唤。这衍生物不能攻击，也不能作为同调素材。
function c17418744.initial_effect(c)
	-- 这张卡发动的回合，自己不是光属性怪兽不能召唤·反转召唤·特殊召唤。①：在自己场上把2只「光子衍生物」（雷族·光·4星·攻2000/守0）守备表示特殊召唤。这衍生物不能攻击，也不能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c17418744.cost)
	e1:SetTarget(c17418744.target)
	e1:SetOperation(c17418744.activate)
	c:RegisterEffect(e1)
	-- 注册“通常召唤”活动计数器：玩家进行通常召唤时，若召唤的怪兽不是光属性（counterfilter返回false），则计数器增加，用于记录非光属性怪兽的通常召唤行为。
	Duel.AddCustomActivityCounter(17418744,ACTIVITY_SUMMON,c17418744.counterfilter)
	-- 注册“特殊召唤”活动计数器：玩家进行特殊召唤时，若特殊召唤的怪兽不是光属性，则计数器增加，用于记录非光属性怪兽的特殊召唤行为。
	Duel.AddCustomActivityCounter(17418744,ACTIVITY_SPSUMMON,c17418744.counterfilter)
	-- 注册“反转召唤”活动计数器：玩家进行反转召唤时，若反转召唤的怪兽不是光属性，则计数器增加，用于记录非光属性怪兽的反转召唤行为。
	Duel.AddCustomActivityCounter(17418744,ACTIVITY_FLIPSUMMON,c17418744.counterfilter)
end
-- 活动计数器的过滤函数：判定怪兽是否为光属性；返回true表示该召唤操作合法（不计入违规），返回false会使对应召唤类型的计数器加1，从而限制非光属性怪兽的召唤。
function c17418744.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 发动条件/费用检查：在发动时确认本回合尚未进行过非光属性怪兽的通常召唤、特殊召唤或反转召唤，否则不能发动这张卡。
function c17418744.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检查第一步：确认本回合玩家没有进行过非光属性怪兽的通常召唤（召唤计数为0）。
	if chk==0 then return Duel.GetCustomActivityCount(17418744,tp,ACTIVITY_SUMMON)==0
		-- 费用检查第二步：确认本回合玩家没有进行过非光属性怪兽的特殊召唤（特殊召唤计数为0）。
		and Duel.GetCustomActivityCount(17418744,tp,ACTIVITY_SPSUMMON)==0
		-- 费用检查第三步：确认本回合玩家没有进行过非光属性怪兽的反转召唤（反转召唤计数为0）；三项均为0时费用检查通过。
		and Duel.GetCustomActivityCount(17418744,tp,ACTIVITY_FLIPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是光属性怪兽不能召唤·反转召唤·特殊召唤。①：在自己场上把2只「光子衍生物」（雷族·光·4星·攻2000/守0）守备表示特殊召唤。这衍生物不能攻击，也不能作为同调素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c17418744.sumlimit)
	-- 将“不能特殊召唤非光属性怪兽”的永续效果（EFFECT_CANNOT_SPECIAL_SUMMON）注册到场上，作用于当前玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将“不能通常召唤非光属性怪兽”的永续效果（由e1克隆的EFFECT_CANNOT_SUMMON）注册到场上，作用于当前玩家，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 将“不能反转召唤非光属性怪兽”的永续效果（由e1克隆的EFFECT_CANNOT_FLIP_SUMMON）注册到场上，作用于当前玩家，持续到结束阶段。
	Duel.RegisterEffect(e3,tp)
end
-- 限制效果的过滤函数：怪兽属性为0x6f（即除光属性以外的所有属性）时返回true，表示该怪兽受到“不能召唤·反转召唤·特殊召唤”的限制。
function c17418744.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsAttribute(0x6f)
end
-- 发动时（chk==0）判定效果是否可以发动：当前玩家未受青眼精灵龙“不能同时特殊召唤2只以上怪兽”的效果影响、自己主要怪兽区空格数>1，且能将光子衍生物以表侧守备表示特殊召唤。
function c17418744.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 要求自己主要怪兽区至少还有2个可用空格，因为本次效果要特殊召唤2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查当前玩家能否将卡号17418745的光子衍生物（雷族·光·4星·攻2000/守0）以表侧守备表示特殊召唤到自己的主要怪兽区。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,17418745,0x55,TYPES_TOKEN_MONSTER,2000,0,4,RACE_THUNDER,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：本次效果会生成2只衍生物（CATEGORY_TOKEN），供效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：本次效果会特殊召唤2只怪兽（CATEGORY_SPECIAL_SUMMON），用于连锁处理中的相关时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：若当前玩家未受青眼精灵龙的上述效果影响且自己主要怪兽区有至少2格并能特召光子衍生物，则连续特殊召唤2只光子衍生物，并给它们附加不能攻击、不能作为同调素材的效果。
function c17418744.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 在效果处理时确认自己主要怪兽区仍有至少2个空格，否则无法特殊召唤2只衍生物。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 在效果处理时再次确认玩家当前仍能特殊召唤光子衍生物（若已有其他限制导致不能特召，则不执行特召）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,17418745,0x55,TYPES_TOKEN_MONSTER,2000,0,4,RACE_THUNDER,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) then
		for i=1,2 do
			-- 创建一只卡号为17418745的「光子衍生物」衍生物，控制者为tp，作为要特殊召唤的怪兽。
			local token=Duel.CreateToken(tp,17418745)
			-- 将衍生物以表侧守备表示特殊召唤到tp的场上（SpecialSummonStep是连续特殊召唤的一步，后续需用SpecialSummonComplete完成）。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这衍生物不能攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			-- 也不能作为同调素材。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e2,true)
		end
		-- 完成连续特殊召唤：由SpecialSummonStep累积的衍生物全部特殊召唤成功，此处触发召唤成功相关时点。
		Duel.SpecialSummonComplete()
	end
end
