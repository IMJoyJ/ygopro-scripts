--ホルスの黒炎竜 LV4
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，控制权不会被变更。这张卡战斗破坏怪兽的回合的结束阶段时，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「荷鲁斯之黑炎龙 LV6」。
function c75830094.initial_effect(c)
	-- 这张卡战斗破坏怪兽的回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c75830094.bdop)
	c:RegisterEffect(e1)
	-- 只要这张卡在自己场上表侧表示存在，控制权不会被变更。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e2)
	-- 结束阶段时，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「荷鲁斯之黑炎龙 LV6」。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75830094,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(c75830094.spcon)
	e3:SetCost(c75830094.spcost)
	e3:SetTarget(c75830094.sptg)
	e3:SetOperation(c75830094.spop)
	c:RegisterEffect(e3)
end
c75830094.lvup={11224103}
-- 战斗破坏怪兽时，给自身注册一个在回合结束时重置的标记
function c75830094.bdop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(75830094,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查自身是否在本回合战斗破坏过怪兽（是否存在对应的标记）
function c75830094.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(75830094)>0
end
-- 发动代价：检查并把场上的这张卡送去墓地
function c75830094.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为发动代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：手卡·卡组中的「荷鲁斯之黑炎龙 LV6」且可以无视召唤条件特殊召唤
function c75830094.spfilter(c,e,tp)
	return c:IsCode(11224103) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 特殊召唤效果的发动条件检查与操作信息设置
function c75830094.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（由于自身作为代价送墓会空出1格，因此可用空格数大于-1即可）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在满足条件的「荷鲁斯之黑炎龙 LV6」
		and Duel.IsExistingMatchingCard(c75830094.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的具体处理
function c75830094.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有可用空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只满足条件的「荷鲁斯之黑炎龙 LV6」
	local g=Duel.SelectMatchingCard(tp,c75830094.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽无视召唤条件和苏生限制以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
