--D・スクランブル
-- 效果：
-- 对方宣言直接攻击时，自己场上没有怪兽存在的场合才能发动。那次攻击无效，从手卡把1只名字带有「变形斗士」的怪兽特殊召唤。
function c49833312.initial_effect(c)
	-- 创建效果，设置为魔陷发动，攻击宣言时触发，条件为对方宣言直接攻击且自己场上没有怪兽存在，目标为特殊召唤，效果处理为无效攻击并特殊召唤怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c49833312.condition)
	e1:SetTarget(c49833312.target)
	e1:SetOperation(c49833312.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：自己场上没有怪兽存在
function c49833312.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤函数：检查手牌中是否含有名字带有「变形斗士」的怪兽且可以被特殊召唤
function c49833312.filter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标：确认是否有满足条件的怪兽可特殊召唤
function c49833312.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张符合条件的怪兽
		and Duel.IsExistingMatchingCard(c49833312.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤，目标为手牌中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：无效攻击并从手牌特殊召唤符合条件的怪兽
function c49833312.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效攻击且自己场上存在空位
	if Duel.NegateAttack() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的手牌怪兽
		local g=Duel.SelectMatchingCard(tp,c49833312.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的怪兽正面表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
