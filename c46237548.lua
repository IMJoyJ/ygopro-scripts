--紅蓮魔闘士
-- 效果：
-- ①：这张卡可以在自己墓地的通常怪兽是3只的场合，把那之内的2只除外，从手卡特殊召唤。
-- ②：1回合1次，以自己墓地1只4星以下的通常怪兽为对象才能发动。那只怪兽特殊召唤。
function c46237548.initial_effect(c)
	-- ①：这张卡可以在自己墓地的通常怪兽是3只的场合，把那之内的2只除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c46237548.spcon)
	e1:SetTarget(c46237548.sptg)
	e1:SetOperation(c46237548.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己墓地1只4星以下的通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46237548,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c46237548.target)
	e2:SetOperation(c46237548.operation)
	c:RegisterEffect(e2)
end
-- 筛选可作为代价从墓地除外的通常怪兽。
function c46237548.spcfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToRemoveAsCost()
end
-- 此卡在手卡时，满足以下条件才能进行规则特殊召唤：自己场上存在可用的怪兽区域、墓地通常怪兽数量为3、且其中有至少2只可作为代价除外的通常怪兽。
function c46237548.spcon(e,c)
	if c==nil then return true end
	-- 检查此卡的控制者（即召唤玩家）场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查该玩家墓地的通常怪兽数量是否恰好为3只。
		and Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,nil,TYPE_NORMAL)==3
		-- 检查墓地是否存在至少2只可作为代价除外的通常怪兽。
		and Duel.IsExistingMatchingCard(c46237548.spcfilter,c:GetControler(),LOCATION_GRAVE,0,2,nil)
end
-- 选择要除外的2只通常怪兽作为特殊召唤的代价；选择成功时将所选卡组保存并设定为效果对象，返回true，否则返回false。
function c46237548.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取该玩家墓地中所有可作为代价除外的通常怪兽的集合。
	local g=Duel.GetMatchingGroup(c46237548.spcfilter,tp,LOCATION_GRAVE,0,nil)
	-- 弹出选择提示，要求玩家从符合条件的怪兽中选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,2,2,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 规则特殊召唤处理时，将之前选择保存的2只通常怪兽作为代价除外。
function c46237548.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽从墓地以表侧表示除外，原因为特殊召唤（此处作为召唤手续的代价）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 筛选自己墓地中4星以下的通常怪兽，且能够被效果特殊召唤。
function c46237548.tgfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时点：检查自己场上是否有空位、墓地是否存在1只符合条件的通常怪兽；若满足，则选择1只墓地中的4星以下通常怪兽作为对象。
function c46237548.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46237548.tgfilter(chkc,e,tp) end
	-- 效果发动时（chk==0）检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查墓地是否存在至少1只符合tgfilter条件的通常怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c46237548.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，要求玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的符合条件的通常怪兽中选择1只作为效果对象（同时将对象登记到当前连锁）。
	local g=Duel.SelectTarget(tp,c46237548.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将进行的处理分类为特殊召唤，目标为选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时，若自己场上有空位且对象仍然存在于墓地且与该效果有联系，则将该怪兽表侧表示特殊召唤到自己场上。
function c46237548.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域，则处理结束（不进行特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得这个效果发动时选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件/苏生限制，因为已通过tgfilter验证）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
