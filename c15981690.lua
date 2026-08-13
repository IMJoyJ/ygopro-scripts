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
	-- 「碳素龙」的②的效果1回合只能使用1次。②：自己主要阶段把墓地的这张卡除外才能发动。从手卡·卡组把1只7星以下的龙族通常怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15981690,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,15981690)
	-- 设置②效果的发动代价：将墓地的这张卡除外才能发动。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c15981690.sptg)
	e2:SetOperation(c15981690.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：检测这张卡的战斗对象是否存在且为炎属性，若满足则伤害计算时发动。
function c15981690.upcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsAttribute(ATTRIBUTE_FIRE)
end
-- ①效果处理：若这张卡仍与效果相关且处于表侧表示，则给它赋予攻击力上升1000的临时效果，持续到伤害计算时结束。
function c15981690.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力只在那次伤害计算时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(1000)
		c:RegisterEffect(e1)
	end
end
-- 定义②特殊召唤的候选卡过滤条件：必须是等级7以下的龙族通常怪兽，且可以被表侧守备表示特殊召唤。
function c15981690.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(7) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果发动时的检查：确认自己主要怪兽区有空位，且手卡·卡组中存在满足条件的龙族通常怪兽。
function c15981690.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自己主要怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡或卡组中存在至少1只满足spfilter过滤条件的龙族通常怪兽。
		and Duel.IsExistingMatchingCard(c15981690.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统登记本连锁将进行特殊召唤操作：从手卡·卡组特殊召唤1只怪兽（具体处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②效果处理：从手卡·卡组选择1只符合条件的龙族通常怪兽，以表侧守备表示特殊召唤到自己场上。
function c15981690.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若没有主要怪兽区空位则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选卡提示“请选择要特殊召唤的卡”，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组中选择1张满足spfilter条件的龙族通常怪兽（处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c15981690.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
