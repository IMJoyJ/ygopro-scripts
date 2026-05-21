--セイヴァー・ミラージュ
-- 效果：
-- ①：自己场上的表侧表示的「星尘龙」或者有那个卡名记述的同调怪兽为让自己的卡的效果发动而从场上离开的场合或者因自己的卡的效果从场上离开的场合才能发动。从以下效果选1个适用。这个回合，自己的「救世幻象」的效果不能有相同效果适用。
-- ●选那1只怪兽特殊召唤。
-- ●从对方的场上·墓地选1只怪兽除外。
-- ●这个回合，自己受到的全部伤害变成一半。
function c98020526.initial_effect(c)
	-- 注册卡片效果中记述了「星尘龙」（卡号44508094）的卡片信息。
	aux.AddCodeList(c,44508094)
	-- 对应卡片效果原文：救世幻象的卡片发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98020526,3))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应卡片效果原文：①：自己场上的表侧表示的「星尘龙」或者有那个卡名记述的同调怪兽为让自己的卡的效果发动而从场上离开的场合或者因自己的卡的效果从场上离开的场合才能发动。从以下效果选1个适用。这个回合，自己的「救世幻象」的效果不能有相同效果适用。●选那1只怪兽特殊召唤。●从对方的场上·墓地选1只怪兽除外。●这个回合，自己受到的全部伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c98020526.condition)
	e2:SetTarget(c98020526.target)
	e2:SetOperation(c98020526.activate)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(98020526,4))  --"发动并使用效果"
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「星尘龙」或记述有其卡名的同调怪兽，因自己的卡的效果发动或效果而从场上离开。
function c98020526.cfilter(c,tp,rp)
	return c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
		-- 检查离开场前的卡是否为「星尘龙」或者是记述有「星尘龙」卡名的同调怪兽。
		and (c:IsCode(44508094) or c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0 and aux.IsCodeListed(c,44508094))
		and c:IsReason(REASON_COST+REASON_EFFECT) and rp==tp
end
-- 效果发动条件：检查是否有满足条件的怪兽因自己的卡的效果或代价而离场。
function c98020526.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c98020526.cfilter,1,nil,tp,rp)
end
-- 过滤条件：在墓地或除外状态，且可以特殊召唤的怪兽。
function c98020526.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or (c:IsFaceup() and c:IsLocation(LOCATION_REMOVED))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：可以被除外的怪兽。
function c98020526.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果发动时的目标选择与可行性检查：检查三个可选效果中是否至少有一个可以适用，且该效果本回合未被适用过。
function c98020526.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查是否满足效果1的适用条件：有怪兽区域空位、离场的怪兽在墓地或除外区可特殊召唤，且本回合未适用过效果1。
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:Filter(c98020526.cfilter,nil,tp,rp):IsExists(c98020526.spfilter,1,nil,e,tp) and Duel.GetFlagEffect(tp,98020526)==0
		-- 检查是否满足效果2的适用条件：对方场上或墓地有可除外的怪兽，且本回合未适用过效果2。
		local b2=Duel.IsExistingMatchingCard(c98020526.rfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) and Duel.GetFlagEffect(tp,98020527)==0
		-- 检查是否满足效果3的适用条件：本回合未适用过效果3。
		local b3=Duel.GetFlagEffect(tp,98020528)==0
		return b1 or b2 or b3
	end
end
-- 效果处理：根据玩家的选择，执行对应的效果（特殊召唤、除外或伤害减半），并为该效果注册本回合已适用的标记。
function c98020526.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查效果1（特殊召唤）是否满足适用条件。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:Filter(c98020526.cfilter,nil,tp,rp):IsExists(c98020526.spfilter,1,nil,e,tp) and Duel.GetFlagEffect(tp,98020526)==0
	-- 效果处理时，再次检查效果2（除外）是否满足适用条件（受王家之谷影响）。
	local b2=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c98020526.rfilter),tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) and Duel.GetFlagEffect(tp,98020527)==0
	-- 效果处理时，再次检查效果3（伤害减半）是否满足适用条件。
	local b3=Duel.GetFlagEffect(tp,98020528)==0
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(98020526,0)  --"选那1只怪兽特殊召唤"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(98020526,1)  --"从对方的场上·墓地选1只怪兽除外"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(98020526,2)  --"这个回合，自己受到的全部伤害变成一半"
		opval[off-1]=3
		off=off+1
	end
	if off==1 then return end
	-- 提示玩家选择要适用的效果。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 让玩家从可用的效果选项中选择一个。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		local sg=eg:Filter(c98020526.cfilter,nil,tp,rp):Filter(c98020526.spfilter,nil,e,tp)
		if #sg>1 then
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=sg:Select(tp,1,1,nil)
		end
		-- 将选中的怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		-- 注册效果1已适用的标记，持续到回合结束。
		Duel.RegisterFlagEffect(tp,98020526,RESET_PHASE+PHASE_END,0,1)
	elseif opval[op]==2 then
		-- 提示玩家选择要除外的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 优先从对方场上（其次从墓地）选择1只满足条件的怪兽，并应用王家之谷的过滤。
		local rg=aux.SelectCardFromFieldFirst(tp,aux.NecroValleyFilter(c98020526.rfilter),tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
		-- 选中卡片的视觉提示效果。
		Duel.HintSelection(rg)
		-- 将选中的怪兽表侧表示除外。
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		-- 注册效果2已适用的标记，持续到回合结束。
		Duel.RegisterFlagEffect(tp,98020527,RESET_PHASE+PHASE_END,0,1)
	else
		local c=e:GetHandler()
		-- 对应卡片效果原文：●这个回合，自己受到的全部伤害变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(c98020526.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册使自己受到的伤害减半的全局效果。
		Duel.RegisterEffect(e1,tp)
		-- 注册效果3已适用的标记，持续到回合结束。
		Duel.RegisterFlagEffect(tp,98020528,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 伤害计算函数：将受到的伤害值减半（向下取整）。
function c98020526.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
