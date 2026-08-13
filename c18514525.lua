--プランキッズ・ロケット
-- 效果：
-- 「调皮宝贝」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤成功的场合才能发动。这个回合这张卡攻击力下降1000，并且也能直接攻击。
-- ②：把这张卡解放，以融合怪兽以外的自己墓地2只「调皮宝贝」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c18514525.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以2只「调皮宝贝」怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x120),2,true)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡融合召唤成功的场合才能发动。这个回合这张卡攻击力下降1000，并且也能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18514525,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,18514525)
	e1:SetCondition(c18514525.atkcon)
	e1:SetOperation(c18514525.atkop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：把这张卡解放，以融合怪兽以外的自己墓地2只「调皮宝贝」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18514525,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,18514526)
	e2:SetCost(c18514525.spcost)
	e2:SetTarget(c18514525.sptg)
	e2:SetOperation(c18514525.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡以融合召唤方式成功召唤（判定召唤类型为融合召唤）。
function c18514525.atkcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①处理：若这张卡仍表侧且在场上且攻击力不低于1000，则使其攻击力下降1000直到回合结束，并在没有攻击力反转效果影响时赋予其直接攻击能力。
function c18514525.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or atk<1000 then return end
	-- 这个回合这张卡攻击力下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 并且也能直接攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 筛选可作为代替解放除外的代价卡：该卡须为表侧表示或在墓地、能够作为代价除外，并且持有相应代替解放效果。
function c18514525.excostfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(25725326,tp)
end
-- 判断某个候选代价卡是否可行：若将其移除后我方怪兽区空格数大于1（足以特殊召唤2只怪兽），且墓地中可特殊召唤的「调皮宝贝」怪兽卡名种类不少于2（满足同名最多1张）。
function c18514525.costfilter(c,tp,g)
	local tg=g:Clone()
	tg:RemoveCard(c)
	-- 代价可行性条件：解放候选卡后怪兽区空格数>1，且目标「调皮宝贝」怪兽卡名种类≥2。
	return Duel.GetMZoneCount(tp,c)>1 and tg:GetClassCount(Card.GetCode)>=2
end
-- 效果②的代价处理：从可代替解放的候选卡和这张卡自身中选择1张作为代价（带有代替解放效果的除外，否则解放）；需在无青眼精灵龙等禁止同时特殊召唤2只以上怪兽的效果适用时才能发动，且解放后空位足够、墓地有至少2个不同名的可特殊召唤「调皮宝贝」怪兽；若候选不止1张则提示玩家选择。
function c18514525.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	-- 获取可作为解放/代替解放除外的候选卡组：自己场上表侧表示或墓地的、可除外作为代价且具有代替解放效果的卡。
	local g=Duel.GetMatchingGroup(c18514525.excostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 获取墓地中可作为特殊召唤对象的「调皮宝贝」怪兽组，供后续选择。
	local tg=Duel.GetMatchingGroup(c18514525.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then
		e:SetLabel(100)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133) and g:IsExists(c18514525.costfilter,1,nil,tp,tg)
	end
	local cg=g:Filter(c18514525.costfilter,nil,tp,tg)
	local tc
	if #cg>1 then
		-- 当存在多个可选的解放/代替解放卡时，显示“请选择要解放或代替解放除外的卡”的选择提示，等待玩家选择。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25725326,0))  --"请选择要解放或代替解放除外的卡"
		tc=cg:Select(tp,1,1,nil):GetFirst()
	else
		tc=cg:GetFirst()
	end
	local te=tc:IsHasEffect(25725326,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将选中的卡表侧除外，作为发动代价并视为代替解放（REASON_COST+REASON_REPLACE）。
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将选中的卡（通常为这张卡自身）解放，作为发动效果的代价。
		Duel.Release(tc,REASON_COST)
	end
end
-- 特殊召唤对象过滤：必须是「调皮宝贝」怪兽、不是融合怪兽、能成为效果对象，且能被这个效果特殊召唤。
function c18514525.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and not c:IsType(TYPE_FUSION)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的目标选择：确认代价已支付后，从墓地选择2张卡名互不相同的「调皮宝贝」非融合怪兽作为对象，设为效果对象并登记操作信息。
function c18514525.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetLabel()==100 end
	e:SetLabel(0)
	-- 获取墓地中所有可作为特殊召唤对象的「调皮宝贝」怪兽。
	local g=Duel.GetMatchingGroup(c18514525.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从候选组中选择正好2张卡，并保证2张卡卡名互不相同（同名卡最多1张）。
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的2张怪兽卡设为当前效果的取对象目标。
	Duel.SetTargetCard(g1)
	-- 设置操作信息：本次效果将特殊召唤这2张目标怪兽（数量为2），供相关卡片响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 效果②处理：取得仍与效果关联的对象卡；若对象不存在、没有空位，或青眼精灵龙效果适用且需特殊召唤2只时，效果不处理；若空位不足则让玩家选择实际特殊召唤的卡；逐只特殊召唤成功时赋予“不能攻击”效果，最后完成特殊召唤。
function c18514525.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方主要怪兽区的可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁的对象卡组（即发动时选择的2只墓地怪兽）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or ft<=0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<g:GetCount() then
		-- 当可用怪兽区数量不足时，显示选择提示，让玩家选择实际要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 使用SpecialSummonStep逐只特殊召唤目标怪兽，若特殊召唤成功，则赋予其不能攻击的效果，等待后续完成特殊召唤。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
	-- 完成多只怪兽的特殊召唤流程，触发特殊召唤成功时点。
	Duel.SpecialSummonComplete()
end
