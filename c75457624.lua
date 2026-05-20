--霊獣の相絆
-- 效果：
-- ①：把自己场上2只表侧表示的「灵兽」怪兽除外才能发动。从额外卡组把1只「灵兽」怪兽无视召唤条件特殊召唤。
function c75457624.initial_effect(c)
	-- ①：把自己场上2只表侧表示的「灵兽」怪兽除外才能发动。从额外卡组把1只「灵兽」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c75457624.cost)
	e1:SetTarget(c75457624.target)
	e1:SetOperation(c75457624.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示、可以作为代价除外的「灵兽」怪兽
function c75457624.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb5) and c:IsAbleToRemoveAsCost()
end
-- 过滤函数，用于在可选怪兽组中筛选出第一只怪兽，该怪兽必须存在另一只可与其配对并能成功特殊召唤额外怪兽的怪兽
function c75457624.cfilter1(c,cg,e,tp)
	return cg:IsExists(c75457624.cfilter2,1,c,c,e,tp)
end
-- 过滤函数，用于筛选出第二只怪兽，该怪兽与第一只怪兽一起除外后，额外卡组存在可特殊召唤的「灵兽」怪兽
function c75457624.cfilter2(c,mc,e,tp)
	-- 检查额外卡组是否存在至少1只满足条件的「灵兽」怪兽，且在将这两只怪兽除外释放格子后，额外怪兽区域有空位
	return Duel.IsExistingMatchingCard(c75457624.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,Group.FromCards(c,mc))
end
-- 效果发动代价函数。由于需要准确计算额外怪兽区域的可用格子，将实际的除外操作延迟到target中处理，此处仅作标记并返回true
function c75457624.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤额外卡组中满足特殊召唤条件的「灵兽」怪兽
function c75457624.filter(c,e,tp,mg)
	-- 检查卡片是否为「灵兽」怪兽、是否可以无视召唤条件特殊召唤，且在指定怪兽离场后额外怪兽区域有可用空位
	return c:IsSetCard(0xb5) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 效果发动目标函数。在chk==0时验证发动条件并进行格子预估，在chk==1时选择并除外2只怪兽作为代价，并声明特殊召唤的操作信息
function c75457624.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示且可以作为代价除外的「灵兽」怪兽
	local cg=Duel.GetMatchingGroup(c75457624.cfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return cg:IsExists(c75457624.cfilter1,1,nil,cg,e,tp)
	end
	e:SetLabel(0)
	-- 提示玩家选择第1只作为除外代价的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g1=cg:FilterSelect(tp,c75457624.cfilter1,1,1,nil,cg,e,tp)
	local tc=g1:GetFirst()
	-- 提示玩家选择第2只作为除外代价的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g2=cg:FilterSelect(tp,c75457624.cfilter2,1,1,tc,tc,e,tp)
	g1:Merge(g2)
	-- 将选中的2只怪兽表侧表示除外，作为发动的代价
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
	-- 设置效果处理的操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数。从额外卡组选择1只「灵兽」怪兽无视召唤条件特殊召唤
function c75457624.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「灵兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c75457624.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
