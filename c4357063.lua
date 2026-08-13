--先史遺産都市バビロン
-- 效果：
-- 1回合1次，把自己墓地1只名字带有「先史遗产」的怪兽从游戏中除外，从自己墓地选择持有和除外的怪兽相同等级的1只名字带有「先史遗产」的怪兽才能发动。选择的怪兽特殊召唤。
function c4357063.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，把自己墓地1只名字带有「先史遗产」的怪兽从游戏中除外，从自己墓地选择持有和除外的怪兽相同等级的1只名字带有「先史遗产」的怪兽才能发动。选择的怪兽特殊召唤。
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
-- 筛选可作为发动代价的先史遗产怪兽：属于「先史遗产」字段、可作为代价除外、等级大于0，且墓地存在与该怪兽等级相同并能特殊召唤的先史遗产怪兽。
function c4357063.costfilter(c,e,tp)
	return c:IsSetCard(0x70) and c:IsAbleToRemoveAsCost() and c:GetLevel()>0
		-- 确认墓地存在与这张候选代价怪兽等级相同的先史遗产怪兽，保证除外后能选择同一等级的对象进行特殊召唤。
		and Duel.IsExistingTarget(c4357063.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,c:GetLevel())
end
-- 特殊召唤对象的筛选条件：属于「先史遗产」字段、等级等于指定的lv（即除外怪兽的等级），且能够被当前效果特殊召唤。
function c4357063.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x70) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标选择与代价处理：先检查发动条件（主怪兽区有空位、存在可除外的代价怪兽），再进行代价除外并选择同等级怪兽作为效果对象。
function c4357063.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4357063.spfilter(chkc,e,tp,e:GetLabel()) end
	-- 发动条件之一：自己主要怪兽区必须至少有1个空位，以便后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：墓地中存在满足代价条件的「先史遗产」怪兽（即可除外并能对应选出同等级特召对象的怪兽）。
		and Duel.IsExistingMatchingCard(c4357063.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡片，显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足代价条件（costfilter）的「先史遗产」怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c4357063.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local lv=g:GetFirst():GetLevel()
	-- 将选择的怪兽以表侧表示从游戏中除外，作为发动此效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(lv)
	-- 提示玩家选择要特殊召唤的卡片，显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只与除外怪兽等级相同且满足特殊召唤条件的「先史遗产」怪兽，作为此效果的对象。
	local g=Duel.SelectTarget(tp,c4357063.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	-- 设置操作信息，声明将特殊召唤所选择的对象（1张），供连锁处理后端判断使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：取得发动时选择的对象，若该对象仍与效果关联，则将其特殊召唤到自己的场上。
function c4357063.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的效果对象（墓地中等级相同的「先史遗产」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己的主要怪兽区（按苏生限制等规则进行特殊召唤）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
