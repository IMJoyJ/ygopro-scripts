--闘争本能
-- 效果：
-- 对方宣言直接攻击时，自己场上没有怪兽存在的场合才能发动。从手卡把1只4星以下的兽族怪兽表侧攻击表示特殊召唤。
function c60534585.initial_effect(c)
	-- 对方宣言直接攻击时，自己场上没有怪兽存在的场合才能发动。从手卡把1只4星以下的兽族怪兽表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c60534585.condition)
	e1:SetTarget(c60534585.target)
	e1:SetOperation(c60534585.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：对方直接攻击宣言时，且自己场上没有怪兽存在
function c60534585.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合，且攻击对象为空（即直接攻击）
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==nil
		-- 判断自己场上的怪兽数量是否为0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤手卡中等级4以下、兽族、且可以表侧攻击表示特殊召唤的怪兽
function c60534585.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 发动时的效果处理，检查怪兽区域空位和手卡中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c60534585.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检测时，检查手卡中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c60534585.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理，从手卡选择1只满足条件的怪兽表侧攻击表示特殊召唤
function c60534585.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已没有可用的怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c60534585.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
