--カーボネドン
-- 效果：
-- 「碳素龙」的②的效果1回合只能使用1次。
-- ①：这张卡和炎属性怪兽进行战斗的伤害计算时发动。这张卡的攻击力只在那次伤害计算时上升1000。
-- ②：自己主要阶段把墓地的这张卡除外才能发动。从手卡·卡组把1只7星以下的龙族通常怪兽守备表示特殊召唤。
function c15981690.initial_effect(c)
	-- ①：这张卡和炎属性怪兽进行战斗的伤害计算时发动。这张卡的攻击力只在那次伤害计算时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15981690,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c15981690.upcon)
	e1:SetOperation(c15981690.upop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外才能发动。从手卡·卡组把1只7星以下的龙族通常怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15981690,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,15981690)
	-- 将这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c15981690.sptg)
	e2:SetOperation(c15981690.spop)
	c:RegisterEffect(e2)
end
-- 效果适用的条件：战斗中的对方怪兽为炎属性
function c15981690.upcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsAttribute(ATTRIBUTE_FIRE)
end
-- 效果处理：使自身攻击力在伤害计算时上升1000
function c15981690.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 设置攻击力上升效果，仅在伤害计算阶段结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(1000)
		c:RegisterEffect(e1)
	end
end
-- 筛选满足条件的怪兽：通常怪兽、7星以下、龙族、可守备表示特殊召唤
function c15981690.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(7) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的检查：确认场上是否有空位且手卡或卡组是否存在符合条件的怪兽
function c15981690.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c15981690.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：选择并特殊召唤符合条件的怪兽
function c15981690.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c15981690.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
