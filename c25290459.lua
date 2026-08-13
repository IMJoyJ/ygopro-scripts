--レベルアップ！
-- 效果：
-- 把场上表侧表示存在的名字有「LV」的怪兽送去墓地发动。那张卡上面记述的怪兽，无视召唤条件从手卡·卡组特殊召唤。
function c25290459.initial_effect(c)
	-- 把场上表侧表示存在的名字有「LV」的怪兽送去墓地发动。那张卡上面记述的怪兽，无视召唤条件从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c25290459.cost)
	e1:SetTarget(c25290459.target)
	e1:SetOperation(c25290459.activate)
	c:RegisterEffect(e1)
end
-- costfilter：筛选可作为发动代价的场上表侧表示的名字含有「LV」的怪兽；要求它能作为代价送墓、不是里侧表示；根据其原卡号找到对应脚本类，确保该类存在且定义有lvup升级表；同时确认手卡·卡组中存在能由该表特殊召唤的怪兽。
function c25290459.costfilter(c,e,tp)
	if not c:IsSetCard(0x41) or not c:IsAbleToGraveAsCost() or c:IsFacedown() then return false end
	local code=c:GetOriginalCode()
	local class=_G["c"..code]
	if class==nil or class.lvup==nil then return false end
	-- 检查手卡·卡组中是否存在至少1张满足spfilter（卡名在class.lvup列表中且可被本次效果特殊召唤）的卡，用于确认该LV怪兽可作为代价。
	return Duel.IsExistingMatchingCard(c25290459.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,class,e,tp)
end
-- spfilter：筛选手卡·卡组中卡名属于该类lvup记载的怪兽，并确认它能被本次效果无视召唤条件特殊召唤。
function c25290459.spfilter(c,class,e,tp)
	local code=c:GetCode()
	return c:IsCode(table.unpack(class.lvup)) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- cost：发动代价处理。chk==0时（合法性检查）判断自己场上是否存在符合条件的LV怪兽；实际支付时提示选择要送去墓地的LV怪兽，将其送入墓地，并把该怪兽的原卡号存入效果Label以记录其对应的升级系列。
function c25290459.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：若场上存在符合条件的LV怪兽，且手卡·卡组中有对应可特殊召唤的怪兽，则返回true允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c25290459.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示信息，提示需要选择一张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上表侧表示存在的符合条件的LV怪兽中选择1张（costfilter保证满足条件）。
	local g=Duel.SelectMatchingCard(tp,c25290459.costfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的LV怪兽作为代价送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalCode())
end
-- target：效果发动时进行条件判定并设置操作信息；由于特召对象在处理时选择，因此不取对象，仅登记特殊召唤类别的操作信息（预定从手卡·卡组特殊召唤1只怪兽）。
function c25290459.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己主要怪兽区的空格数大于-1，即只要不处于无法使用怪兽区的极端限制状态即可发动，实际是否有格子在处理时再判断。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 end
	-- 登记本次连锁的操作信息：效果类别为特殊召唤，预定由玩家tp从手卡·卡组特殊召唤1只怪兽（目标数量1，位置为手卡+卡组）。该信息用于后续多种效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- activate：效果处理。若自己场上没有可用空格则终止；读取cost阶段记录的LV怪兽原卡号，获取对应的脚本类及lvup表；让玩家从手卡·卡组选择1只该表记载的怪兽，无视召唤条件表侧表示特殊召唤；若该怪兽从卡组特殊召唤，则洗切卡组。
function c25290459.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前检查：若自己主要怪兽区没有可用空格，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local code=e:GetLabel()
	local class=_G["c"..code]
	if class==nil or class.lvup==nil then return end
	-- 向玩家显示选择提示信息，提示需要选择一张要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组中筛选出1张符合spfilter（卡名属于lvup表且可被特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c25290459.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,class,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽无视召唤条件、无视苏生限制，以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		-- 若被特殊召唤的怪兽在效果处理前位于卡组，则特殊召唤后洗切卡组。
		if tc:IsPreviousLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	end
end
