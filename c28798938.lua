--双天の獅使－阿吽
-- 效果：
-- 「双天」怪兽×2
-- ①：这张卡得到作为融合素材的怪兽的原本卡名的以下效果。
-- ●「双天将 金刚」：进行战斗的自己的「双天」怪兽的攻击力只在伤害计算时变成3000。
-- ●「双天将 密迹」：对方回合1次，以场上1张卡为对象才能发动。那张卡除外。
-- ②：融合召唤的这张卡被破坏的场合才能发动。从卡组把「双天拳之熊罴」「双天脚之鸿鹄」各1只特殊召唤。那些怪兽在这个回合不会被战斗·效果破坏。
function c28798938.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置此卡的融合召唤条件为使用2个「双天」卡组的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x14f),2,true)
	-- ①：这张卡得到作为融合素材的怪兽的原本卡名的以下效果。
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
-- 判断此卡是否为融合召唤
function c28798938.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 根据融合素材判断是否附加效果
function c28798938.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if #g==0 then return end
	if g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then
		c:RegisterFlagEffect(85360035,RESET_EVENT+RESETS_STANDARD,0,1)
	end
	if g:IsExists(Card.IsOriginalCodeRule,1,nil,33026283) then
		-- 为「双天将 金刚」的融合素材时，使战斗中的自己的「双天」怪兽在伤害计算时攻击力变为3000
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
		-- 为「双天将 密迹」的融合素材时，对方回合1次，以场上1张卡为对象才能发动。那张卡除外
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
-- 判断是否处于伤害计算阶段且有战斗中的怪兽
function c28798938.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前战斗中的怪兽
	local a=Duel.GetBattleMonster(tp)
	-- 判断是否处于伤害计算阶段且战斗怪兽为「双天」族
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and a and a:IsSetCard(0x14f)
end
-- 设置攻击判定目标为战斗中的怪兽
function c28798938.atktg(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取当前战斗中的怪兽
	local a=Duel.GetBattleMonster(tp)
	return c==a
end
-- 判断是否为对方回合
function c28798938.rmcon(e)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
-- 选择要除外的卡
function c28798938.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检测是否有可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择要除外的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为除外卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作
function c28798938.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断此卡是否为融合召唤且在场上被破坏
function c28798938.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 筛选可特殊召唤的卡
function c28798938.spfilter(c,e,tp)
	return c:IsCode(85360035,11759079) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检测是否满足特殊召唤条件
function c28798938.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取场上可用位置数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 获取卡组中符合条件的卡
		local g=Duel.GetMatchingGroup(c28798938.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测是否能选出2张不同卡名的卡
		return g:CheckSubGroup(aux.dncheck,2,2)
	end
	-- 设置操作信息为特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作
function c28798938.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上可用位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取卡组中符合条件的卡
	local g=Duel.GetMatchingGroup(c28798938.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择2张不同卡名的卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if not sg then return end
	local tc=sg:GetFirst()
	-- 遍历选择的卡
	for tc in aux.Next(sg) do
		-- 特殊召唤一张卡
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 使特殊召唤的怪兽在战斗中不会被破坏
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使特殊召唤的怪兽在效果处理中不会被破坏
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(28798938,3))  --"「双天之狮使-阿吽」效果适用中"
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
