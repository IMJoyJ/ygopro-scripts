--ヒーローズルール1 ファイブ・フリーダムス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己·对方的墓地的卡合计最多5张为对象才能发动。那些卡除外。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己的除外状态的1只「元素英雄」怪兽为对象才能发动。那只怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 定义卡片效果初始化函数，创建并注册两个效果：除外效果和特殊召唤效果。
function s.initial_effect(c)
	-- 创建第一个效果，描述为“除外”，类别为移除，允许选择目标卡，类型为激活效果，触发时机为自由连锁，设置目标选择函数为s.target，操作函数为s.activate，并注册该效果到卡片c上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 创建第二个效果，描述为“特殊召唤”，类别为特殊召唤，类型为快速效果，触发时机为自由连锁，生效范围为墓地，允许选择目标卡，设置提示时机，限制每回合使用次数为1次（id），设置发动条件为aux.exccon，设置费用为aux.bfgcost，设置目标选择函数为s.sptg，操作函数为s.spop，并注册该效果到卡片c上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 设置特殊召唤效果的触发条件：当前回合没有送去墓地的这张卡才能发动。
	e2:SetCondition(aux.exccon)
	-- 设置特殊召唤效果的费用：将这张卡从场上除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义目标选择函数s.target，用于选择要除外的卡片。如果检查的是目标有效性，则返回目标是否在墓地且可以被移除；如果正在进行实际的选择，则提示玩家选择最多5张墓地的可移除卡片，并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查是否有满足条件的卡片（即：位于墓地且可被移除）
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送提示消息，要求其选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 使用Duel.SelectTarget函数让玩家从墓地中选择1到5张可移除的卡片。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,5,nil)
	-- 设置连锁的操作信息：类别为移除，目标为选中的卡片组g，数量为g中卡片的数量，影响对象为所有玩家，位置为墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),PLAYER_ALL,LOCATION_GRAVE)
end
-- 定义激活函数s.activate，用于执行除外效果。获取连锁相关的目标卡片组sg，然后以正面表示的形式将sg中的卡片移除。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中关联的目标卡片组。
	local sg=Duel.GetTargetsRelateToChain()
	-- 将目标卡片组sg以正面表示的形式从场上移除。
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
-- 定义过滤函数s.spfilter，用于筛选可以特殊召唤的元素英雄怪兽。检查怪兽是否正面显示、类型为怪兽、属于元素英雄系列（0x3008），并且满足特殊召唤条件。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 定义目标选择函数s.sptg，用于选择要特殊召唤的除外状态的元素英雄怪兽。如果检查的是目标有效性，则返回目标是否在除外区、是正面表示的元素英雄怪兽且由当前玩家控制；如果正在进行实际的选择，则检查场上是否有可用的怪兽区域，并提示玩家从除外区选择1只满足条件的元素英雄怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) and chkc:IsControler(tp) end
	-- 检查当前玩家的怪兽区域是否还有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在位于除外区的、正面表示的、属于元素英雄系列的、可以被特殊召唤的卡片。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家发送提示消息，要求其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 使用Duel.SelectTarget函数让玩家从除外区选择1只满足条件的元素英雄怪兽。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息：类别为特殊召唤，目标为选中的怪兽g，数量为1，影响对象为0（不指定），参数为0（不指定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义特殊召唤操作函数s.spop，用于执行特殊召唤效果。获取第一个目标卡片tc，如果tc与连锁相关且不受王家长眠之谷的影响，则以无视召唤条件的方式将tc特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡片是否与连锁相关，并且不受王家长眠之谷效果的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 使用Duel.SpecialSummon函数将目标怪兽tc特殊召唤到场上，不进行任何条件检查。
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
