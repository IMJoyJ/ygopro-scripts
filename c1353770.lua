--神の居城－ヴァルハラ
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只天使族怪兽特殊召唤。这个效果在自己场上没有怪兽存在的场合才能发动和处理。
function c1353770.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只天使族怪兽特殊召唤。这个效果在自己场上没有怪兽存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1353770,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c1353770.condition)
	e1:SetTarget(c1353770.target)
	e1:SetOperation(c1353770.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数：该效果仅允许在自己场上没有怪兽存在的场合才能发动（同时也用于效果处理时判定）。
function c1353770.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区（以及额外怪兽区？实际为怪兽区域整体）没有怪兽存在，即场上怪兽数量为0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 定义手牌天使族怪兽的筛选条件：需要是天属性·天使族，并且能够被该效果允许的特殊召唤（通过苏生限制等召唤条件检查）。
function c1353770.filter(c,e,sp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 定义效果发动时的目标检测和操作信息设置：确认有可用怪兽区空位，且手牌存在满足条件的天使族怪兽，并声明本效果将进行特殊召唤。
function c1353770.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：己方场上是否有可以使用的怪兽区空格（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时检查：手牌中是否存在至少1只满足条件（天使族且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c1353770.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，向系统声明本次连锁的效果包含特殊召唤分类，预定从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义效果处理时的实际操作：先再次确认仍有怪兽区空位且自己场上没有怪兽，然后由玩家选择手牌中的1只天使族怪兽，并以表侧表示特殊召唤到己方场上。
function c1353770.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，如果己方场上没有可用怪兽区空格，则直接终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时，如果己方场上已经有怪兽存在，则不进行特殊召唤（符合“这个效果在自己场上没有怪兽存在的场合才能发动和处理”的限制）。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	-- 向玩家发送选择提示，提示内容是“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方手牌中选择1只满足条件的（天使族且可特殊召唤）怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c1353770.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的那只怪兽以表侧表示形式特殊召唤到己方场上（不改变控制者，不检查召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
