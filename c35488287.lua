--寿炎星－リシュンマオ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己把「炎舞」魔法·陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己墓地选「寿炎星-李熊猫」以外的1只「炎星」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「炎星」怪兽不能特殊召唤。
-- ②：自己场上的「炎星」怪兽被对方的效果破坏的场合，可以作为代替把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地。
function c35488287.initial_effect(c)
	-- ①：自己把「炎舞」魔法·陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己墓地选「寿炎星-李熊猫」以外的1只「炎星」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「炎星」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35488287,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,35488287)
	e1:SetCondition(c35488287.spcon)
	e1:SetTarget(c35488287.sptg)
	e1:SetOperation(c35488287.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「炎星」怪兽被对方的效果破坏的场合，可以作为代替把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,35488289)
	e2:SetTarget(c35488287.desreptg)
	e2:SetValue(c35488287.desrepval)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：仅当自己（rp==tp）发动了「炎舞」魔法·陷阱卡（效果类型为魔陷发动）时，本卡效果才能发动。
function c35488287.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x7c)
end
-- 效果①发动前的合法性检查：确认自己场上有可用怪兽区，且手卡中本卡能够被特殊召唤；满足则效果可发动。
function c35488287.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有空余的怪兽区域，用于特殊召唤手卡的这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁的操作信息：此效果将进行特殊召唤，对象为本卡，数量为1，供其他卡牌（如星尘龙）进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 从墓地特殊召唤时的候选过滤：必须是「炎星」怪兽、不是本卡（李熊猫）、并且能够被特殊召唤。
function c35488287.spfilter(c,e,tp)
	return c:IsSetCard(0x79) and not c:IsCode(35488287) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的解决处理：先将手卡的本卡特殊召唤；成功后若玩家选择，再从墓地特殊召唤1只其他「炎星」怪兽；最后给自己附加直到回合结束只能特殊召唤「炎星」怪兽的自肃。
function c35488287.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡仍与该效果存在关联（未被无效或离场），然后将本卡表侧表示特殊召唤；只有特殊召唤成功时才继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 从自己墓地中筛选出满足条件的「炎星」怪兽（排除本卡且不受王家长眠之谷影响、能够被特殊召唤），作为可追加召唤的候选。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c35488287.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 判断是否有场地和候选怪兽，并询问玩家是否要进行追加的墓地特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(35488287,1)) then  --"是否从墓地把「炎星」怪兽特殊召唤？"
			-- 中断当前效果处理，使之后进行的特殊召唤被视为另一个独立处理，避免产生错误的时点判断。
			Duel.BreakEffect()
			-- 显示选择提示，让玩家从候选墓地怪兽中选出要特殊召唤的1只「炎星」怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的墓地「炎星」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「炎星」怪兽不能特殊召唤。②：自己场上的「炎星」怪兽被对方的效果破坏的场合，可以作为代替把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c35488287.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述自肃效果注册到场上，使其在结束阶段前持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的判定条件：若一只怪兽不是「炎星」怪兽，则不能将其特殊召唤。
function c35488287.splimit(e,c)
	return not c:IsSetCard(0x79)
end
-- ②效果的代替破坏判定：被破坏的卡必须是己方场上表侧表示的「炎星」怪兽，破坏原因为对方效果（REASON_EFFECT），且不是已经作为代替物被破坏的卡。
function c35488287.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x79) and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 可作为代替送去墓地的卡的条件：己方场上表侧表示的「炎舞」魔法·陷阱卡，且未被预定破坏、不免疫当前效果。
function c35488287.tgfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) and not c:IsImmuneToEffect(e)
end
-- ②效果的触发与处理：当己方「炎星」怪兽被对方效果破坏时，检查是否存在可代替的「炎舞」卡；若玩家选择发动，则选择一张送去墓地并返回true以代替那次破坏。
function c35488287.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return rp==1-tp and eg:IsExists(c35488287.repfilter,1,nil,tp)
		-- 确认己方场上存在至少1张可送去墓地表侧「炎舞」魔法·陷阱卡（用于代替破坏）。
		and Duel.IsExistingMatchingCard(c35488287.tgfilter,tp,LOCATION_ONFIELD,0,1,nil,e) end
	-- 询问玩家是否发动②的代替破坏效果。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 发出选择提示，要求玩家选择要送去墓地的「炎舞」魔法·陷阱卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从己方场上选择1张符合条件的表侧「炎舞」魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c35488287.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e)
		-- 将选中的「炎舞」卡送去墓地，作为破坏的代替（原因标记为效果+代替）。
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 系统的代替破坏查询函数：对每只预定被破坏的怪兽，用repfilter判断其是否满足被代替条件；返回true则触发代替处理。
function c35488287.desrepval(e,c)
	return c35488287.repfilter(c,e:GetHandlerPlayer())
end
