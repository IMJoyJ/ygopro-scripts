--WAKE CUP！ アル
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合才能发动。从自己手卡选1只其他的反转怪兽丢弃，这张卡表侧攻击表示或里侧守备表示特殊召唤。
-- ②：这张卡反转的场合才能发动。把最多有自己场上的反转怪兽数量的对方场上的表侧表示卡送去墓地。
-- ③：自己结束阶段，以自己墓地1只反转怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①②③效果的定义。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合才能发动。从自己手卡选1只其他的反转怪兽丢弃，这张卡表侧攻击表示或里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转的场合才能发动。把最多有自己场上的反转怪兽数量的对方场上的表侧表示卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段，以自己墓地1只反转怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡中可因效果丢弃的反转怪兽。
function s.dfilter(c)
	return c:IsType(TYPE_FLIP) and c:IsDiscardable(REASON_EFFECT)
end
-- 效果①的发动准备：检查怪兽区域空位、手卡是否有其他可丢弃的反转怪兽，以及自身是否能特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在除这张卡以外的、可因效果丢弃的反转怪兽。
		and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	end
	-- 设置连锁处理中的操作信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：从手卡丢弃1只反转怪兽，将这张卡表侧攻击表示或里侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要丢弃的手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家从手卡选择1只除这张卡以外的反转怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND,0,1,1,aux.ExceptThisCard(e))
	-- 若成功将选中的卡因效果丢弃送去墓地，且此卡仍与连锁有关联。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)>0 and c:IsRelateToChain() then
		-- 将此卡以表侧攻击表示或里侧守备表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤条件：对方场上表侧表示且能送去墓地的卡。
function s.tgfilter(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
-- 过滤条件：自己场上表侧表示的反转怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FLIP)
end
-- 效果②的发动准备：计算自己场上反转怪兽数量，并确认对方场上有可送去墓地的表侧表示卡。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上表侧表示的反转怪兽数量。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查自己场上是否有反转怪兽，且对方场上是否存在至少1张表侧表示的卡。
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有满足送去墓地条件的表侧表示卡片。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁处理中的操作信息：将对方场上的卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果②的处理：将最多有自己场上反转怪兽数量的对方场上的表侧表示卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算当前自己场上表侧表示的反转怪兽数量。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择最多等同于自己场上反转怪兽数量的对方场上的表侧表示卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		-- 闪烁显示被选中的卡片。
		Duel.HintSelection(g)
		-- 将选中的卡因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果③的发动条件：必须是自己的回合。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件：墓地中可以里侧守备表示特殊召唤的反转怪兽。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果③的发动准备：选择自己墓地1只反转怪兽作为对象。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空位，且墓地中是否存在可特殊召唤的反转怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择墓地中1只反转怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息：特殊召唤选中的对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的处理：将选中的墓地反转怪兽里侧守备表示特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与连锁有关联，且不受王家长眠之谷的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽以里侧守备表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end
