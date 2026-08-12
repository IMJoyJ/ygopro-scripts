--瓔珞帝華－ペリアリス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升自己场上的其他的植物族怪兽数量×400。
-- ②：自己主要阶段才能发动。除「璎珞帝华-帝王贝母」外的1只5星以上的植物族怪兽从自己的手卡·墓地守备表示特殊召唤。
function c72924435.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升自己场上的其他的植物族怪兽数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c72924435.atkval)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。除「璎珞帝华-帝王贝母」外的1只5星以上的植物族怪兽从自己的手卡·墓地守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72924435,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,72924435)
	e2:SetTarget(c72924435.target)
	e2:SetOperation(c72924435.operation)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的植物族怪兽
function c72924435.atkfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsFaceup()
end
-- 计算攻击力上升数值的辅助函数
function c72924435.atkval(e,c)
	-- 获取自己场上除自身以外的表侧表示植物族怪兽数量并乘以400
	return Duel.GetMatchingGroupCount(c72924435.atkfilter,c:GetControler(),LOCATION_MZONE,0,c)*400
end
-- 过滤手卡或墓地中除「璎珞帝华-帝王贝母」以外、可以守备表示特殊召唤的5星以上的植物族怪兽
function c72924435.filter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsLevelAbove(5) and not c:IsCode(72924435)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备与合法性检测函数
function c72924435.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检测时，检查自己的手卡或墓地是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c72924435.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果②的效果处理（特殊召唤）函数
function c72924435.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地（受王家长眠之谷影响）选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c72924435.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
