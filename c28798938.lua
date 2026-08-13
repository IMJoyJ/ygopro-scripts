--双天の獅使－阿吽
-- 效果：
-- 「双天」怪兽×2
-- ①：这张卡得到作为融合素材的怪兽的原本卡名的以下效果。
-- ●「双天将 金刚」：进行战斗的自己的「双天」怪兽的攻击力只在伤害计算时变成3000。
-- ●「双天将 密迹」：对方回合1次，以场上1张卡为对象才能发动。那张卡除外。
-- ②：融合召唤的这张卡被破坏的场合才能发动。从卡组把「双天拳之熊罴」「双天脚之鸿鹄」各1只特殊召唤。那些怪兽在这个回合不会被战斗·效果破坏。
function c28798938.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：使用2只「双天」怪兽作为融合素材（满足卡名含有『双天』字段的怪兽）。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x14f),2,true)
	-- ①：这张卡得到作为融合素材的怪兽的原本卡名的以下效果。●「双天将 金刚」：进行战斗的自己的「双天」怪兽的攻击力只在伤害计算时变成3000。●「双天将 密迹」：对方回合1次，以场上1张卡为对象才能发动。那张卡除外。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(c28798938.regcon)
	e0:SetOperation(c28798938.regop)
	c:RegisterEffect(e0)
	-- ②：融合召唤的这张卡被破坏的场合才能发动。从卡组把「双天拳之熊罴」「双天脚之鸿鹄」各1只特殊召唤。那些怪兽在这个回合不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c28798938.spcon)
	e3:SetTarget(c28798938.sptg)
	e3:SetOperation(c28798938.spop)
	c:RegisterEffect(e3)
end
-- e0的发动条件：这张卡是以融合召唤方式特殊召唤成功的。
function c28798938.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 融合召唤成功后的处理：获取融合素材；若素材含有效果怪兽则给这张卡标记（熊罴回收相关）；若素材含『双天将 金刚』则获得『进行战斗的自己的「双天」怪兽攻击力只在伤害计算时变成3000』的永续效果；若素材含『双天将 密迹』则获得『对方回合1次，以场上1张卡为对象才能发动，那张卡除外』的诱发即时效果；并分别添加客户端提示标志。
function c28798938.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if #g==0 then return end
	if g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then
		c:RegisterFlagEffect(85360035,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	if g:IsExists(Card.IsOriginalCodeRule,1,nil,33026283) then
		-- ●「双天将 金刚」：进行战斗的自己的「双天」怪兽的攻击力只在伤害计算时变成3000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetCondition(c28798938.atkcon)
		e1:SetTarget(c28798938.atktg)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(28798938,0))  --"「双天将 金刚」为融合素材"
	end
	if g:IsExists(Card.IsOriginalCodeRule,1,nil,284224) then
		-- ●「双天将 密迹」：对方回合1次，以场上1张卡为对象才能发动。那张卡除外。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(28798938,2))
		e2:SetCategory(CATEGORY_REMOVE)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_MZONE)
		e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
		e2:SetCountLimit(1)
		e2:SetCondition(c28798938.rmcon)
		e2:SetTarget(c28798938.rmtg)
		e2:SetOperation(c28798938.rmop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(28798938,1))  --"「双天将 密迹」为融合素材"
	end
end
-- 攻击力赋予效果的适用条件：仅在伤害计算阶段，己方存在进行战斗的「双天」怪兽时适用。
function c28798938.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取由tp玩家操控的正在进行战斗的怪兽，若没有则返回nil。
	local a=Duel.GetBattleMonster(tp)
	-- 判断当前阶段是否为伤害计算阶段，且存在战斗怪兽且该怪兽属于「双天」字段（0x14f）。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and a and a:IsSetCard(0x14f)
end
-- 攻击力赋予效果的目标判定：只对己方当前正在战斗的那只「双天」怪兽（a）生效，即c必须等于a。
function c28798938.atktg(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取己方当前战斗怪兽，用于与效果目标c比较。
	local a=Duel.GetBattleMonster(tp)
	return c==a
end
-- 除外效果的发动条件：当前回合为这张卡的控制者的对方回合（即满足『对方回合1次』）。
function c28798938.rmcon(e)
	-- 返回当前回合玩家是否不是这张卡的控制者，即当前为对方回合。
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 除外效果的目标选择与发动判定：选择场上1张可以被除外的卡作为对象；若存在则让玩家选择并设置操作信息。
function c28798938.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 发动时（chk==0）判断双方场上是否存在至少1张可以被除外的卡，作为能否发动的前提。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择提示『请选择要除外的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方场上选择1张可除外的卡，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果分类为除外，对象为g，数量为1，用于连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：取得对象卡，若对象仍与效果关联，则将其表侧表示除外。
function c28798938.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外，除外原因为效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡被破坏前位于怪兽区域，且是以融合召唤方式召唤的（即『融合召唤的这张卡被破坏的场合』）。
function c28798938.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 特召对象的筛选条件：卡名是「双天拳之熊罴」或「双天脚之鸿鹄」，且可以被当前效果特殊召唤。
function c28798938.spfilter(c,e,tp)
	return c:IsCode(85360035,11759079) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标判定：确认己方怪兽区有至少2个空位，且没有【青眼精灵龙】等禁止同时特殊召唤2只以上怪兽的效果，然后检查卡组中是否存在卡名互不相同的2张符合条件的卡（熊罴和鸿鹄各1只）；满足后设置操作信息。
function c28798938.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取己方主要怪兽区可用空格数，用于判断能否同时特殊召唤2只怪兽。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 从卡组中取得所有满足特召条件的卡（熊罴和鸿鹄）。
		local g=Duel.GetMatchingGroup(c28798938.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检查是否存在2张卡名不同（即熊罴和鸿鹄各1张）的子组，作为能否发动的条件。
		return g:CheckSubGroup(aux.dncheck,2,2)
	end
	-- 设置操作信息：本次效果分类为特殊召唤，预计从卡组特殊召唤2只怪兽（对象在处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理：再次确认空位和青眼精灵龙限制后，从卡组选择卡名不同的2张卡（熊罴和鸿鹄），依次特殊召唤，并给它们各注册本回合不会被战斗·效果破坏的效果；最后完成特殊召唤。
function c28798938.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方主要怪兽区可用空格数，用于再次确认能否特殊召唤2只怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 从卡组中取得符合条件的特召对象（熊罴和鸿鹄）。
	local g=Duel.GetMatchingGroup(c28798938.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 向玩家显示选择提示『请选择要特殊召唤的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从符合条件的卡组中选择2张卡名不同的卡（即熊罴和鸿鹄各1只）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if not sg then return end
	local tc=sg:GetFirst()
	-- 遍历选出的2张卡，依次进行后续特殊召唤处理。
	for tc in aux.Next(sg) do
		-- 将当前卡以表侧表示特殊召唤到己方场上；若召唤成功，则继续为其赋予本回合的破坏抗性。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 不会被战斗破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 不会被效果破坏。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(28798938,3))  --"「双天之狮使-阿吽」效果适用中"
		end
	end
	-- 完成所有特殊召唤步骤，触发特殊召唤成功时的各种时点。
	Duel.SpecialSummonComplete()
end
