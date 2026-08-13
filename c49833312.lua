--D・スクランブル
-- 效果：
-- 对方宣言直接攻击时，自己场上没有怪兽存在的场合才能发动。那次攻击无效，从手卡把1只名字带有「变形斗士」的怪兽特殊召唤。
function c49833312.initial_effect(c)
	-- 对方宣言直接攻击时，自己场上没有怪兽存在的场合才能发动。那次攻击无效，从手卡把1只名字带有「变形斗士」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c49833312.condition)
	e1:SetTarget(c49833312.target)
	e1:SetOperation(c49833312.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件判定函数：本卡在对方宣言直接攻击且自己场上没有怪兽时才能发动。
function c49833312.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己怪兽区域怪兽数量为0，即自己场上没有怪兽存在。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义可特殊召唤的怪兽筛选条件：手牌中名字带有「变形斗士」且可以被特殊召唤的怪兽。
function c49833312.filter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标检查与操作信息设置：在发动时确认自己怪兽区有空位且手牌存在符合条件的「变形斗士」，并登记特殊召唤操作。
function c49833312.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌中是否存在至少1张满足filter条件的「变形斗士」怪兽。
		and Duel.IsExistingMatchingCard(c49833312.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次效果处理的信息：从手牌特殊召唤1只怪兽（数量1，位置为手牌）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义效果处理函数：无效攻击后，将手牌中1只「变形斗士」怪兽特殊召唤。
function c49833312.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，先无效那次攻击，并再次确认自己怪兽区仍有空位才继续。
	if Duel.NegateAttack() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示选择提示，要求其选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择1张满足filter条件的「变形斗士」怪兽。
		local g=Duel.SelectMatchingCard(tp,c49833312.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
