--セリオンズ・スタンダップ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己墓地1只「兽带斗神」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从自己的手卡·墓地把1只「兽带斗神」怪兽当作装备卡使用给那只怪兽装备。
-- ②：自己·对方的主要阶段，把墓地的这张卡除外，从自己的场上·墓地各以1只「兽带斗神」怪兽为对象才能发动。那只墓地的怪兽当作装备卡使用给那只自己场上的怪兽装备。
function c79775821.initial_effect(c)
	-- ①：以自己墓地1只「兽带斗神」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从自己的手卡·墓地把1只「兽带斗神」怪兽当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,79775821)
	e1:SetTarget(c79775821.target)
	e1:SetOperation(c79775821.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把墓地的这张卡除外，从自己的场上·墓地各以1只「兽带斗神」怪兽为对象才能发动。那只墓地的怪兽当作装备卡使用给那只自己场上的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79775821,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,79775821)
	e2:SetCondition(c79775821.eqcon)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c79775821.eqtg)
	e2:SetOperation(c79775821.eqop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中可以特殊召唤的「兽带斗神」怪兽
function c79775821.spfilter(c,e,tp)
	return c:IsSetCard(0x179) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：进行对象合法性检测和发动条件判断
function c79775821.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c79775821.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「兽带斗神」怪兽
		and Duel.IsExistingTarget(c79775821.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「兽带斗神」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c79775821.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含目标怪兽组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤手卡或墓地的「兽带斗神」怪兽卡
function c79775821.eqfilter(c)
	return c:IsSetCard(0x179) and c:IsType(TYPE_MONSTER)
end
-- 效果①的处理：特殊召唤目标怪兽，并可选从手卡·墓地装备1只「兽带斗神」怪兽
function c79775821.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽（即准备特殊召唤的怪兽）
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍合法，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取自己手卡·墓地中不受「王家长眠之谷」影响的「兽带斗神」怪兽组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c79775821.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
		-- 若存在可装备的怪兽且魔法与陷阱区域有空位，询问玩家是否进行装备
		if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(79775821,0)) then  --"是否选怪兽装备？"
			-- 中断当前效果处理，使后续的装备处理不与特殊召唤同时进行（造成错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要装备的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			local sg=g:Select(tp,1,1,nil)
			local ec=sg:GetFirst()
			if ec then
				-- 将选择的怪兽作为装备卡装备给特殊召唤的怪兽，若装备失败则结束处理
				if not Duel.Equip(tp,ec,tc) then return end
				-- 当作装备卡使用给那只怪兽装备
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetLabelObject(tc)
				e1:SetValue(c79775821.eqlimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				ec:RegisterEffect(e1)
			end
		end
	end
end
-- 设定装备限制，该装备卡只能装备给特定的怪兽
function c79775821.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果②的发动条件：只能在自己或对方的主要阶段发动
function c79775821.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤自己场上表侧表示的「兽带斗神」怪兽
function c79775821.filter(c)
	return c:IsSetCard(0x179) and c:IsFaceup()
end
-- 效果②的发动准备：进行双对象（场上和墓地）的合法性检测和发动条件判断
function c79775821.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否有空余的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在可以作为装备卡的「兽带斗神」怪兽
		and Duel.IsExistingTarget(c79775821.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查自己场上是否存在表侧表示的「兽带斗神」怪兽作为装备对象
		and Duel.IsExistingTarget(c79775821.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡（墓地的怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只「兽带斗神」怪兽作为装备卡的对象
	local g=Duel.SelectTarget(tp,c79775821.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择效果的对象（场上的怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的「兽带斗神」怪兽作为装备对象
	local g1=Duel.SelectTarget(tp,c79775821.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：有1张卡将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②的处理：将选择的墓地怪兽装备给选择的场上怪兽
function c79775821.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	local ec=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	if tc and ec and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将墓地的怪兽作为装备卡装备给场上的怪兽，若装备失败则结束处理
		if not Duel.Equip(tp,ec,tc) then return end
		-- 当作装备卡使用给那只自己场上的怪兽装备
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(c79775821.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end
