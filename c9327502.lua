--E・HERO ボルテック
-- 效果：
-- ①：这张卡给与对方战斗伤害时，以除外的1只自己的「元素英雄」怪兽为对象才能发动。那只怪兽特殊召唤。
function c9327502.initial_effect(c)
	-- ①：这张卡给与对方战斗伤害时，以除外的1只自己的「元素英雄」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c9327502.condition)
	e1:SetTarget(c9327502.target)
	e1:SetOperation(c9327502.operation)
	c:RegisterEffect(e1)
end
-- 判定给与对方玩家战斗伤害的条件（受到伤害的玩家ep不等于发动效果的玩家tp）
function c9327502.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤条件：除外区表侧表示的、卡名含有「元素英雄」且可以特殊召唤的怪兽
function c9327502.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与可行性检查
function c9327502.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c9327502.filter(chkc,e,tp) end
	-- 检查发动效果的玩家场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1只满足条件的自己怪兽作为对象
		and Duel.IsExistingTarget(c9327502.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外区1只满足条件的自己怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c9327502.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，表示该效果包含特殊召唤所选对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数，将选中的对象特殊召唤
function c9327502.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果玩家的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
