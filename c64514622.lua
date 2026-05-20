--龍王の聖刻印
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。可以通过把场上表侧表示存在的这张卡当作通常召唤作再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●把这张卡解放才能发动。从自己的手卡·卡组·墓地选「龙王之圣刻印」以外的1只名字带有「圣刻」的怪兽表侧守备表示特殊召唤。
function c64514622.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●把这张卡解放才能发动。从自己的手卡·卡组·墓地选「龙王之圣刻印」以外的1只名字带有「圣刻」的怪兽表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(64514622,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果的发动条件为自身处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetCost(c64514622.cost)
	e1:SetTarget(c64514622.target)
	e1:SetOperation(c64514622.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的代价函数，要求解放自身
function c64514622.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤出「龙王之圣刻印」以外、可以表侧守备表示特殊召唤的「圣刻」怪兽
function c64514622.filter(c,e,tp)
	return c:IsSetCard(0x69) and not c:IsCode(64514622) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义效果发动的目标检测与连锁处理信息函数
function c64514622.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空位（由于会解放自身，可用格子数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己的手卡、卡组、墓地是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c64514622.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手卡、卡组、墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 定义效果处理函数，将选定的怪兽特殊召唤
function c64514622.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若怪兽区域没有空位则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地中选择1张满足条件且不受王家长眠之谷影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c64514622.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
