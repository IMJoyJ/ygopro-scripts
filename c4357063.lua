--先史遺産都市バビロン
-- 效果：
-- 1回合1次，把自己墓地1只名字带有「先史遗产」的怪兽从游戏中除外，从自己墓地选择持有和除外的怪兽相同等级的1只名字带有「先史遗产」的怪兽才能发动。选择的怪兽特殊召唤。
function c4357063.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 发动时选择自己墓地1只名字带有「先史遗产」的怪兽从游戏中除外，从自己墓地选择持有和除外的怪兽相同等级的1只名字带有「先史遗产」的怪兽才能发动。选择的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4357063,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c4357063.sptg)
	e2:SetOperation(c4357063.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查自己墓地是否存在满足条件的怪兽（名字带有「先史遗产」、可以除外、等级大于0、并且存在与该怪兽等级相同的可特殊召唤怪兽）
function c4357063.costfilter(c,e,tp)
	return c:IsSetCard(0x70) and c:IsAbleToRemoveAsCost() and c:GetLevel()>0
		-- 检查是否存在满足条件的可特殊召唤怪兽（与除外怪兽等级相同）
		and Duel.IsExistingTarget(c4357063.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,c:GetLevel())
end
-- 过滤函数，用于检查自己墓地是否存在满足条件的怪兽（名字带有「先史遗产」、等级与指定等级相同、可以特殊召唤）
function c4357063.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x70) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的处理函数，用于设置效果的目标和操作信息
function c4357063.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4357063.spfilter(chkc,e,tp,e:GetLabel()) end
	-- 检查场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的怪兽（名字带有「先史遗产」、可以除外、等级大于0、并且存在与该怪兽等级相同的可特殊召唤怪兽）
		and Duel.IsExistingMatchingCard(c4357063.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,c4357063.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local lv=g:GetFirst():GetLevel()
	-- 将选中的怪兽从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(lv)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectTarget(tp,c4357063.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	-- 设置效果操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将选中的怪兽特殊召唤
function c4357063.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
