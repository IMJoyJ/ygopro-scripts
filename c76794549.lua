--アストログラフ・マジシャン
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「星读之魔术师」在自己的灵摆区域放置或特殊召唤。
-- 【怪兽效果】
-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以选这个回合被破坏的1只自己或对方的怪兽，那1只同名怪兽从卡组加入手卡。
-- ②：把自己的手卡·场上·墓地的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各1只和场上的这张卡除外才能发动。把1只「霸王龙 扎克」当作融合召唤从额外卡组特殊召唤。
function c76794549.initial_effect(c)
	-- 注册该卡记载了「霸王龙 扎克」的卡片密码，用于相关卡片的检索或效果关联。
	aux.AddCodeList(c,13331639)
	-- 启用灵摆怪兽的灵摆属性（注册灵摆召唤和灵摆卡的发动等基本规则）。
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「星读之魔术师」在自己的灵摆区域放置或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76794549,0))  --"这张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,76794549)
	e1:SetTarget(c76794549.rptg)
	e1:SetOperation(c76794549.rpop)
	c:RegisterEffect(e1)
	-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以选这个回合被破坏的1只自己或对方的怪兽，那1只同名怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76794549,3))  --"这张卡从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+76794549)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c76794549.spcon)
	e2:SetTarget(c76794549.sptg)
	e2:SetOperation(c76794549.spop)
	c:RegisterEffect(e2)
	-- ②：把自己的手卡·场上·墓地的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各1只和场上的这张卡除外才能发动。把1只「霸王龙 扎克」当作融合召唤从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76794549,5))  --"融合召唤「霸王龙 扎克」"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c76794549.hncost)
	e3:SetTarget(c76794549.hntg)
	e3:SetOperation(c76794549.hnop)
	c:RegisterEffect(e3)
	if not c76794549.global_check then
		c76794549.global_check=true
		-- 那之后，可以选这个回合被破坏的1只自己或对方的怪兽，那1只同名怪兽从卡组加入手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c76794549.checkop)
		-- 注册全局效果，用于在每个回合中记录被破坏的卡片信息。
		Duel.RegisterEffect(ge1,0)
		-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_DESTROYED)
		ge2:SetCondition(c76794549.regcon)
		ge2:SetOperation(c76794549.regop)
		-- 注册全局效果，用于在自己场上的卡被破坏时触发自定义事件。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 创建用于检查「灵摆龙」（0x10f2）、「超量龙」（0x2073）、「同调龙」（0x2017）、「融合龙」（0x1046）怪兽的条件检查函数数组。
c76794549.hnchecks=aux.CreateChecks(Card.IsSetCard,{0x10f2,0x2073,0x2017,0x1046})
-- 全局破坏卡片记录函数，为本回合被破坏并送去墓地、除外区或额外卡组的卡片注册Flag，用于后续检索同名卡。
function c76794549.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) then
			tc:RegisterFlagEffect(76794549,RESET_EVENT+0x1f20000+RESET_PHASE+PHASE_END,0,1)
		elseif tc:IsLocation(LOCATION_EXTRA) then
			tc:RegisterFlagEffect(76794549,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end
-- 过滤条件：检查卡片是否因战斗或效果破坏，且原本控制者为指定玩家、原本在场上。
function c76794549.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检查是否有自己场上的卡被破坏，并根据被破坏卡片的控制者设置对应的玩家标签。
function c76794549.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c76794549.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c76794549.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 触发自定义事件，向系统广播“场上的卡被破坏”的时点，并传递受影响的玩家参数。
function c76794549.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，通知系统有卡片被破坏，以便手卡中的此卡可以发动特殊召唤效果。
	Duel.RaiseEvent(eg,EVENT_CUSTOM+76794549,re,r,rp,ep,e:GetLabel())
end
-- 过滤条件：卡名为「星读之魔术师」，且该卡未被禁止放置在灵摆区，或者可以被特殊召唤。
function c76794549.rpfilter(c,e,tp)
	return c:IsCode(94415058) and (not c:IsForbidden()
		-- 或者在己方怪兽区域有空位时，该卡可以被特殊召唤。
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 灵摆效果的发动准备：检查手卡或卡组是否存在可操作的「星读之魔术师」，并设置破坏自身的操作信息。
function c76794549.rptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组中是否存在至少1只满足条件的「星读之魔术师」。
	if chk==0 then return Duel.IsExistingMatchingCard(c76794549.rpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：将破坏自身（这张卡）作为预期的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果的处理：破坏自身，并让玩家选择将手卡·卡组的一只「星读之魔术师」放置在灵摆区或特殊召唤。
function c76794549.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍存在于灵摆区，并尝试将其因效果破坏。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 提示玩家选择1只「星读之魔术师」。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76794549,6))  --"请选择1只「星读之魔术师」"
		-- 让玩家从手卡或卡组选择1只满足条件的「星读之魔术师」。
		local g=Duel.SelectMatchingCard(tp,c76794549.rpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()==0 then return end
		local tc=g:GetFirst()
		local op=0
		-- 检查己方怪兽区是否有空位，且选中的怪兽是否可以特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 让玩家选择是“在灵摆区域放置”还是“特殊召唤”。
			op=Duel.SelectOption(tp,aux.Stringid(76794549,1),aux.Stringid(76794549,2))  --"灵摆区域放置/特殊召唤"
		else
			-- 无法特殊召唤时，玩家只能选择“在灵摆区域放置”。
			op=Duel.SelectOption(tp,aux.Stringid(76794549,1))  --"灵摆区域放置"
		end
		if op==0 then
			-- 将选中的怪兽表侧表示放置在自己的灵摆区域。
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			-- 将选中的怪兽表侧表示特殊召唤到场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 怪兽效果1的发动条件：检查被破坏的卡片是否属于发动效果的玩家（或双方）。
function c76794549.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 怪兽效果1的发动准备：检查自身是否可以特殊召唤，并设置特殊召唤的操作信息。
function c76794549.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将特殊召唤自身（这张卡）作为预期的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤条件：检查是否为本回合被破坏的怪兽，且卡组中存在其同名怪兽。
function c76794549.thfilter1(c,tp,id)
	return c:IsType(TYPE_MONSTER) and c:GetFlagEffect(76794549)~=0
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		-- 并且检查卡组中是否存在该怪兽的同名怪兽。
		and Duel.IsExistingMatchingCard(c76794549.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤条件：卡组中与指定卡片同名且可以加入手卡的卡。
function c76794549.thfilter2(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 怪兽效果1的处理：特殊召唤自身，之后可选择本回合被破坏的1只怪兽，将其同名怪兽从卡组加入手卡。
function c76794549.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡特殊召唤，若特殊召唤成功则继续处理后续效果。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取双方墓地、除外区及额外卡组中所有在本回合被破坏且卡组有同名卡的怪兽。
		local g=Duel.GetMatchingGroup(c76794549.thfilter1,tp,0x70,0x70,nil,tp,Duel.GetTurnCount())
		-- 如果存在符合条件的被破坏怪兽，询问玩家是否要将同名怪兽加入手卡。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(76794549,4)) then  --"是否把破坏怪兽的同名怪兽加入手卡？"
			-- 中断当前效果处理，使后续的“加入手卡”与“特殊召唤”不视为同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择1只本回合被破坏的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76794549,7))  --"请选择这个回合被破坏的1只怪兽"
			local cg=g:Select(tp,1,1,nil)
			-- 闪烁显示被选中的被破坏怪兽，向双方玩家确认。
			Duel.HintSelection(cg)
			-- 提示玩家选择要加入手卡的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组中选择1只与被选怪兽同名的怪兽。
			local sg=Duel.SelectMatchingCard(tp,c76794549.thfilter2,tp,LOCATION_DECK,0,1,1,nil,cg:GetFirst():GetCode())
			-- 将选中的同名怪兽加入手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 过滤条件：手卡·场上·墓地的「灵摆龙」、「超量龙」、「同调龙」、「融合龙」怪兽，且可以作为除外Cost。
function c76794549.cfilter(c)
	return c:IsSetCard(0x10f2,0x2073,0x2017,0x1046)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 检查选中的除外素材组加上这张卡后，是否能合法特殊召唤「霸王龙 扎克」。
function c76794549.hngoal(g,e,tp,c)
	local sg=Group.FromCards(c)
	sg:Merge(g)
	-- 检查额外卡组中是否存在可以特殊召唤的「霸王龙 扎克」，并考虑素材离场后的格子变化。
	return Duel.IsExistingMatchingCard(c76794549.hnfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
-- 过滤条件：额外卡组中的「霸王龙 扎克」，且满足融合召唤的特殊召唤条件和格子要求。
function c76794549.hnfilter(c,e,tp,sg)
	return c:IsCode(13331639) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		-- 并且在将选中的素材除外后，己方场上仍有足够的额外怪兽区域空位。
		and (not sg or Duel.GetLocationCountFromEx(tp,tp,sg,c)>0)
end
-- 怪兽效果2的Cost处理：检查并从手卡·场上·墓地各选择1只「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽，与场上的这张卡一同除外。
function c76794549.hncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取手卡、场上、墓地中所有符合条件的四种龙族怪兽。
	local mg=Duel.GetMatchingGroup(c76794549.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 并且额外卡组中存在可以特殊召唤的「霸王龙 扎克」。
		and Duel.IsExistingMatchingCard(c76794549.hnfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
		and mg:CheckSubGroupEach(c76794549.hnchecks,c76794549.hngoal,e,tp,c) end
	-- 提示玩家选择要除外的卡片作为发动Cost。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=mg:SelectSubGroupEach(tp,c76794549.hnchecks,false,c76794549.hngoal,e,tp,c)
	sg:AddCard(c)
	-- 将选中的4只怪兽和这张卡表侧表示除外。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 怪兽效果2的发动准备：进行融合素材必须性检查，并设置特殊召唤的操作信息。
function c76794549.hntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在必须作为融合素材的限制。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	-- 设置效果处理信息：将从额外卡组特殊召唤1只怪兽作为预期的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果2的处理：将1只「霸王龙 扎克」当作融合召唤从额外卡组特殊召唤。
function c76794549.hnop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果不满足融合素材的限制条件，则不处理效果。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的「霸王龙 扎克」。
	local g=Duel.SelectMatchingCard(tp,c76794549.hnfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的怪兽当作融合召唤表侧表示特殊召唤。
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
