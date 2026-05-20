--充電池メン
-- 效果：
-- 这张卡的召唤成功时，可以从自己的手卡·卡组把1只「充电池人」以外的名字带有「电池人」的怪兽特殊召唤。这张卡的攻击力·守备力上升自己场上表侧表示存在的雷族怪兽数量×300的数值。
function c83446909.initial_effect(c)
	-- 这张卡的召唤成功时，可以从自己的手卡·卡组把1只「充电池人」以外的名字带有「电池人」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83446909,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c83446909.sumtg)
	e1:SetOperation(c83446909.sumop)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力·守备力上升自己场上表侧表示存在的雷族怪兽数量×300的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c83446909.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤条件：非「充电池人」且名字带有「电池人」的可以特殊召唤的怪兽
function c83446909.spfilter(c,e,tp)
	return not c:IsCode(83446909) and c:IsSetCard(0x28) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 召唤成功时特殊召唤效果的发动准备与可行性检查
function c83446909.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或卡组是否存在至少1只满足特殊召唤条件的「电池人」怪兽
		and Duel.IsExistingMatchingCard(c83446909.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从手卡或卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 召唤成功时特殊召唤效果的执行处理
function c83446909.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的「电池人」怪兽
	local g=Duel.SelectMatchingCard(tp,c83446909.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：场上表侧表示存在的雷族怪兽
function c83446909.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 计算攻击力/守备力上升数值的辅助函数
function c83446909.val(e,c)
	-- 返回自己场上表侧表示存在的雷族怪兽数量乘以300的数值
	return Duel.GetMatchingGroupCount(c83446909.filter,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
