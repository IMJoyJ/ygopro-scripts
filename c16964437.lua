--ダーク・ホライズン
-- 效果：
-- ①：自己因战斗·效果受到伤害时才能发动。把持有受到的伤害数值以下的攻击力的1只魔法师族·暗属性怪兽从卡组特殊召唤。
function c16964437.initial_effect(c)
	-- ①：自己因战斗·效果受到伤害时才能发动。把持有受到的伤害数值以下的攻击力的1只魔法师族·暗属性怪兽从卡组特殊召唤。
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
-- 发动条件判断：受到伤害的玩家必须是这张卡的发动者自己，即只有自己受到伤害时才能发动。
function c16964437.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 筛选可特殊召唤的怪兽：必须为魔法师族、暗属性、攻击力在受到的伤害数值以下，且满足可被效果特殊召唤的条件。
function c16964437.filter(c,e,tp,dam)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackBelow(dam) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点检查：自己场上存在可用的主要怪兽区区域，并且卡组中存在至少1只符合条件的怪兽。
function c16964437.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中是否存在至少1张符合条件的怪兽（不取对象，处理时再选择）。
		and Duel.IsExistingMatchingCard(c16964437.filter,tp,LOCATION_DECK,0,1,nil,e,tp,ev) end
	-- 设置本次操作信息，标明要从卡组特殊召唤1只怪兽，供相关效果（如星尘龙等）进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：若场上仍有可用怪兽区，则提示玩家从卡组选择符合条件的魔法师族·暗属性怪兽，并将其表侧表示特殊召唤。
function c16964437.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始前再次确认自己场上主要怪兽区是否有空位，若没有空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示，告知需要选择一张要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的卡组中选择1只满足筛选条件的怪兽（攻击力≤所受伤害的魔法师族·暗属性怪兽）。
	local g=Duel.SelectMatchingCard(tp,c16964437.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ev)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
