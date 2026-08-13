--第一の棺
-- 效果：
-- 在对方的每1个结束阶段时，按照「第二之棺」「第三之棺」的顺序将其中1张卡从自己的手卡·卡组以表侧表示放到自己场上。当其中任意1张离场时，将这些卡全部送去墓地。当自己场上凑齐所有卡时，将这些卡全部送去墓地，从自己的手卡·卡组特殊召唤1只「法老之灵」上场。
function c31076103.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 在对方的每1个结束阶段时，按照「第二之棺」「第三之棺」的顺序将其中1张卡从自己的手卡·卡组以表侧表示放到自己场上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31076103,0))  --"放置"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c31076103.condition)
	e2:SetOperation(c31076103.operation)
	c:RegisterEffect(e2)
	-- 当自己场上凑齐所有卡时，将这些卡全部送去墓地，从自己的手卡·卡组特殊召唤1只「法老之灵」上场。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31076103,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c31076103.condition)
	e3:SetCost(c31076103.spcost)
	e3:SetTarget(c31076103.sptg)
	e3:SetOperation(c31076103.spop)
	c:RegisterEffect(e3)
	-- 当其中任意1张离场时，将这些卡全部送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c31076103.tgcon)
	e4:SetOperation(c31076103.tgop)
	c:RegisterEffect(e4)
	-- 当其中任意1张离场时，将这些卡全部送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetOperation(c31076103.tgop)
	c:RegisterEffect(e5)
end
-- 判断当前回合玩家是否不是本卡控制者，即仅在对方回合满足触发条件，用于在对方结束阶段发动。
function c31076103.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家不是本卡控制者的布尔值，确保效果只在对方回合执行。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数：判断卡片是否表侧表示且卡号等于指定卡号，用于检查第二之棺或第三之棺是否已在场上。
function c31076103.cfilter1(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 对方结束阶段时：若自己魔陷区有空位，则先检查第二之棺是否在场，不在则从手卡·卡组选1张第二之棺表侧放到自己魔陷区；若第二之棺已在场而第三之棺不在，则选1张第三之棺表侧放到自己魔陷区，实现按顺序放置。
function c31076103.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己魔陷区是否有空位，若没有空位则直接终止本次处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 检查自己魔陷区是否不存在表侧表示的第二之棺（4081094），若不存在则进入放置第二之棺的分支。
	if not Duel.IsExistingMatchingCard(c31076103.cfilter1,tp,LOCATION_SZONE,0,1,nil,4081094) then
		-- 向玩家发送选择提示消息，提示正在选择要表侧表示放到自己场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31076103,2))  --"请选择要表侧表示放到自己场上的卡"
		-- 从自己的手卡·卡组中选择1张卡号是4081094（第二之棺）的卡。
		local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,4081094)
		if g:GetCount()>0 then
			-- 将选中的第二之棺以表侧表示移动到自己的魔陷区，并立即适用其效果。
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	-- 若场上已有第二之棺，则检查是否不存在表侧表示的第三之棺（78697395）；若不存在则进入放置第三之棺的分支。
	elseif not Duel.IsExistingMatchingCard(c31076103.cfilter1,tp,LOCATION_SZONE,0,1,nil,78697395) then
		-- 向玩家发送选择提示消息，提示正在选择要表侧表示放到自己场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31076103,2))  --"请选择要表侧表示放到自己场上的卡"
		-- 从自己的手卡·卡组中选择1张卡号是78697395（第三之棺）的卡。
		local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,78697395)
		if g:GetCount()>0 then
			-- 将选中的第三之棺以表侧表示移动到自己的魔陷区，并立即适用其效果。
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end
-- 过滤函数：判断卡片是否表侧表示、卡号匹配且可以作为代价送去墓地，用于确认第二/第三之棺能否作为特殊召唤的代价。
function c31076103.cfilter2(c,code)
	return c:IsFaceup() and c:IsCode(code) and c:IsAbleToGraveAsCost()
end
-- 过滤函数：判断卡片是否为第一之棺、第二之棺或第三之棺之一，且表侧表示并可作为代价送去墓地，用于选择全部相关卡作为代价。
function c31076103.cfilter3(c)
	return c:IsFaceup() and c:IsCode(31076103,4081094,78697395) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤的代价确认：检查第一之棺自身以及场上的第二之棺、第三之棺是否都能作为代价送去墓地，全部满足才可发动。
function c31076103.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
		-- 确认场上存在至少1张表侧表示且可作为代价的第二之棺（4081094）。
		and Duel.IsExistingMatchingCard(c31076103.cfilter2,tp,LOCATION_SZONE,0,1,nil,4081094)
		-- 确认场上存在至少1张表侧表示且可作为代价的第三之棺（78697395），满足全部代价条件。
		and Duel.IsExistingMatchingCard(c31076103.cfilter2,tp,LOCATION_SZONE,0,1,nil,78697395) end
	-- 获取自己魔陷区上所有满足cfilter3的卡，即场上全部表侧表示的第一之棺、第二之棺和第三之棺。
	local g=Duel.GetMatchingGroup(c31076103.cfilter3,tp,LOCATION_SZONE,0,nil)
	-- 将选中的这些卡全部作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 特殊召唤的目标设定：发动时无条件通过，并登记操作信息为从手卡·卡组特殊召唤1只怪兽。
function c31076103.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次效果的操作信息设置为从手卡·卡组特殊召唤1只怪兽，供其他卡进行效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤函数：判断卡片是否为法老之灵（25343280），且能被当前效果以不检查召唤条件、不检查苏生限制的方式特殊召唤。
function c31076103.spfilter(c,e,tp)
	return c:IsCode(25343280) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤处理：若主怪兽区有空位，则从手卡·卡组选择1只法老之灵，以表侧表示特殊召唤到自己场上；成功后为其补完正规召唤手续。
function c31076103.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主怪兽区是否有空位，若无空位则无法特殊召唤，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组中选择1只满足spfilter的法老之灵。
	local g=Duel.SelectMatchingCard(tp,c31076103.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功选择到目标且特殊召唤成功（表侧表示），则继续执行后续处理。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end
-- 过滤函数：判断卡片卡号是否为第一之棺、第二之棺或第三之棺之一，用于离场事件中筛选相关卡片。
function c31076103.cfilter4(c)
	return c:IsCode(31076103,4081094,78697395)
end
-- 过滤函数：判断卡片是否表侧表示且卡号为第一之棺、第二之棺或第三之棺之一，用于全部送墓时选择场上相关卡片。
function c31076103.cfilter5(c)
	return c:IsFaceup() and c:IsCode(31076103,4081094,78697395)
end
-- 离场触发条件：离场事件组中存在至少1张第一之棺、第二之棺或第三之棺时返回真。
function c31076103.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31076103.cfilter4,1,nil)
end
-- 离场时处理：将自己魔陷区上所有表侧表示的第一之棺、第二之棺、第三之棺全部送去墓地。
function c31076103.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己魔陷区上所有表侧表示的相关三张卡。
	local g=Duel.GetMatchingGroup(c31076103.cfilter5,tp,LOCATION_SZONE,0,nil)
	-- 将这些卡以效果原因全部送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
