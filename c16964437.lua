--ダーク・ホライズン
-- 效果：
-- ①：自己因战斗·效果受到伤害时才能发动。把持有受到的伤害数值以下的攻击力的1只魔法师族·暗属性怪兽从卡组特殊召唤。
function c16964437.initial_effect(c)
	-- 效果原文内容：①：自己因战斗·效果受到伤害时才能发动。把持有受到的伤害数值以下的攻击力的1只魔法师族·暗属性怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(c16964437.condition)
	e1:SetTarget(c16964437.target)
	e1:SetOperation(c16964437.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断伤害是否为自己受到
function c16964437.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 效果作用：过滤满足条件的怪兽（魔法师族·暗属性·攻击力不超过伤害值）
function c16964437.filter(c,e,tp,dam)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackBelow(dam) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置连锁处理目标为从卡组特殊召唤怪兽
function c16964437.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c16964437.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ev) end
	-- 效果作用：设置操作信息为特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：处理特殊召唤效果
function c16964437.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c16964437.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ev)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
