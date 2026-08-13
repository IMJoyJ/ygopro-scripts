--破械式鬼シャラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡从手卡丢弃才能发动。从手卡把1只恶魔族怪兽特殊召唤。那之后，自己场上1张卡破坏。
-- ②：这张卡在墓地存在的状态，场上的卡被战斗或者「破械式鬼 萨拉」以外的卡的效果破坏的场合才能发动。这张卡加入手卡或特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
local s,id,o=GetID()
-- 注册该卡的两个效果：①在手卡可作为即时效果发动，从手卡特召1只恶魔族怪兽并破坏自己场上1张卡；②在墓地时，场上卡被战斗或本卡以外效果破坏的场合，可回手或特召自身。两效果同名卡1回合各1次。
function s.initial_effect(c)
	-- 为这张卡注册“已在墓地”的标记检测效果，用于记录其进入墓地的状态，确保②效果能在正确的时机判定“这张卡在墓地存在的状态”。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：自己·对方的主要阶段，把这张卡从手卡丢弃才能发动。从手卡把1只恶魔族怪兽特殊召唤。那之后，自己场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，场上的卡被战斗或者「破械式鬼 萨拉」以外的卡的效果破坏的场合才能发动。这张卡加入手卡或特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetLabelObject(e0)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：当前必须是主要阶段（涵盖自己或对方的主要阶段）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段，若是则返回true。
	return Duel.IsMainPhase()
end
-- ①效果的代价函数：要求这张卡在手卡且可以丢弃；满足时把这张卡送入墓地作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡以“代价+丢弃”原因送去墓地，完成丢弃cost。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 特召对象过滤器：对象必须为恶魔族怪兽、在手卡存在且可以被效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标判定：需要自己怪兽区有空位，且手卡存在可以特殊召唤的恶魔族怪兽，否则不能发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：自己主要怪兽区必须有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：手卡中存在至少1只满足s.spfilter的恶魔族怪兽，且排除作为cost的这张卡自身。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 登记本效果包含特殊召唤操作：从手卡特殊召唤1只怪兽，用于供其他卡连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 获取自己场上的全部卡片作为之后可能被破坏的候选集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if g:GetCount()>0 then
		-- 登记本效果包含破坏操作：可能破坏自己场上1张卡，g为候选集合。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- ①效果处理：先选择并特殊召唤手卡中的1只恶魔族怪兽；特召成功后，再选择自己场上1张卡破坏。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认怪兽区有空位，若没有空位则直接终止整个处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示正在选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足条件的恶魔族怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若选择成功且该怪兽被特殊召唤成功，则继续执行后续的破坏效果。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使“特殊召唤”和“那之后破坏”作为不同时点处理，避免错过时点。
		Duel.BreakEffect()
		-- 向玩家提示正在选择要破坏的自己场上的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从自己场上选择任意1张卡（怪兽/魔陷均可）作为破坏对象。
		local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 显示被选中卡的选中动画，并将其标记为本次效果的处理对象。
			Duel.HintSelection(sg)
			-- 将选中的卡片以效果原因破坏。
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- ②效果的触发过滤器：判断被破坏的卡原本位于场上，且破坏原因是战斗破坏，或是“破械式鬼 萨拉”以外的卡的效果破坏；同时排除由指定同一效果造成的破坏。
function s.cfilter(c,tp,se,re)
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(id)))
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ②效果发动条件：这张卡在墓地时，若场上有卡被战斗或本卡以外的效果破坏，则可发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,c,tp,se,re)
end
-- ②效果发动时的目标检查：这张卡至少满足“能加入手卡”或“能特殊召唤”其中一项。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand()
		-- 特殊召唤选项需要自己怪兽区有空位，且这张卡在效果处理时仍可被特殊召唤。
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)) end
end
-- ②效果处理：选择“加入手卡”或“特殊召唤”之一；若选择特殊召唤且成功，则给这张卡附加“离场时回到卡组最下面”的效果。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 若这张卡在墓地中的效果受到“王家长眠之谷”影响且可被无效，则整个效果无效并停止处理。
	if aux.NecroValleyNegateCheck(c) then return end
	-- 再次确认这张卡不受“王家长眠之谷”影响，若受影响则不能进行后续移动操作。
	if not aux.NecroValleyFilter()(c) then return end
	local b1=c:IsAbleToHand()
	-- 计算“特殊召唤”选项是否可行：自己怪兽区有空位且这张卡可以被特殊召唤。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local op=0
	if b1 and not b2 then
		op=1
	elseif not b1 and b2 then
		op=2
	else
		-- 当回手和特殊召唤都可行时，弹出选项菜单让玩家选择（“回到手卡”或“特殊召唤”），返回选择的选项编号。
		op=aux.SelectFromOptions(tp,{b1,1190},{b2,1152})
	end
	if op==1 then
		-- 若玩家选择加入手卡，则把这张卡以效果原因送回手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
	-- 若玩家选择特殊召唤且这张卡特殊召唤成功，则继续注册离场回卡组最下面的效果。
	if op==2 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合回到卡组最下面。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1,true)
	end
end
