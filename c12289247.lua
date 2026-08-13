--クロノグラフ・マジシャン
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「时读之魔术师」在自己的灵摆区域放置或特殊召唤。
-- 【怪兽效果】
-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从手卡把1只怪兽特殊召唤。
-- ②：把自己的手卡·场上·墓地的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各1只和场上的这张卡除外才能发动。把1只「霸王龙 扎克」当作融合召唤从额外卡组特殊召唤。
function c12289247.initial_effect(c)
	-- 记录本卡效果中提及的「霸王龙 扎克」（卡号13331639），用于相关卡名检索或判定。
	aux.AddCodeList(c,13331639)
	-- 为这张卡添加灵摆怪兽属性，使其可以作为灵摆卡在灵摆区域发动并参与灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ←8 【灵摆】 8→ 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「时读之魔术师」在自己的灵摆区域放置或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12289247,0))  --"这张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,12289247)
	e1:SetTarget(c12289247.rptg)
	e1:SetOperation(c12289247.rpop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从手卡把1只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12289247,3))  --"这张卡从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+12289247)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c12289247.spcon)
	e2:SetTarget(c12289247.sptg)
	e2:SetOperation(c12289247.spop)
	c:RegisterEffect(e2)
	-- ②：把自己的手卡·场上·墓地的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各1只和场上的这张卡除外才能发动。把1只「霸王龙 扎克」当作融合召唤从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12289247,5))  --"融合召唤「霸王龙 扎克」"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c12289247.hncost)
	e3:SetTarget(c12289247.hntg)
	e3:SetOperation(c12289247.hnop)
	c:RegisterEffect(e3)
	if not c12289247.global_check then
		c12289247.global_check=true
		-- ←8 【灵摆】 8→ 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「时读之魔术师」在自己的灵摆区域放置或特殊召唤。【怪兽效果】①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从手卡把1只怪兽特殊召唤。②：把自己的手卡·场上·墓地的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各1只和场上的这张卡除外才能发动。把1只「霸王龙 扎克」当作融合召唤从额外卡组特殊召唤。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c12289247.regcon)
		ge1:SetOperation(c12289247.regop)
		-- 将全局监测效果注册到场上共通环境，持续监听卡片被破坏的事件，为手卡中的刻读之魔术士提供诱发条件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 创建四个字段判定闭包，分别检查「灵摆龙」「超量龙」「同调龙」「融合龙」所属，用于怪兽效果②的素材选择。
c12289247.hnchecks=aux.CreateChecks(Card.IsSetCard,{0x10f2,0x2073,0x2017,0x1046})
-- 过滤函数：判断被破坏的卡是否因战斗或效果被破坏、破坏前控制者为指定玩家且位于场上，对应“自己场上的卡被战斗·效果破坏”的条件。
function c12289247.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 全局监测条件：从被破坏的卡组中判断是玩家0、玩家1还是双方场上的卡被战斗/效果破坏，并用标签记录该信息。
function c12289247.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c12289247.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c12289247.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 全局监测操作：以被破坏的卡组为事件源，手动触发自定义破坏事件，供手卡中的刻读之魔术士接收。
function c12289247.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 主动引发自定义事件，广播破坏信息并附带受影响玩家参数，使对应的手卡特召效果能正确判定。
	Duel.RaiseEvent(eg,EVENT_CUSTOM+12289247,re,r,rp,ep,e:GetLabel())
end
-- 检索条件：选择「时读之魔术师」（20409757），且该卡未被禁止，或者己方怪兽区域有空位可被效果特殊召唤。
function c12289247.rpfilter(c,e,tp)
	return c:IsCode(20409757) and (not c:IsForbidden()
		-- 若不能放置到灵摆区域，则判断是否有空余怪兽区域且该卡能够被效果特殊召唤，满足其一即可选为特殊召唤对象。
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 灵摆效果①的发动检测：检查手卡·卡组存在符合条件的「时读之魔术师」，同时登记破坏这张卡的操作信息。
function c12289247.rptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性判定：不存在可用对象时不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c12289247.rpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本效果登记为包含破坏这张卡的操作，以便其他卡正确响应此次破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果①处理：先破坏本卡，成功后从手卡·卡组选取1只「时读之魔术师」，让玩家选择放置灵摆区域或特殊召唤并执行。
function c12289247.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联且成功被效果破坏后，才继续后续检索和处理。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 弹出选择卡片提示，文字为“请选择1只「时读之魔术师」”。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(12289247,6))  --"请选择1只「时读之魔术师」"
		-- 让玩家从手卡·卡组中选出1只满足条件的「时读之魔术师」。
		local g=Duel.SelectMatchingCard(tp,c12289247.rpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		local op=0
		-- 判断是否允许选择“特殊召唤”处理：需要己方怪兽区有空位，且选中的卡可以被效果特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 提供“灵摆区域放置”和“特殊召唤”两个选项让玩家选择处理方式。
			op=Duel.SelectOption(tp,aux.Stringid(12289247,1),aux.Stringid(12289247,2))  --"灵摆区域放置/特殊召唤"
		else
			-- 无法特殊召唤时，只提供“灵摆区域放置”选项。
			op=Duel.SelectOption(tp,aux.Stringid(12289247,1))  --"灵摆区域放置"
		end
		if op==0 then
			-- 将选中的「时读之魔术师」表侧放置到自己的灵摆区域。
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			-- 将选中的「时读之魔术师」表侧特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 怪兽效果①的触发条件：本次自定义事件记录的受影响玩家包含自己（或双方），说明自己场上的卡被破坏，从而可以发动。
function c12289247.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 怪兽效果①的发动检测：确认自己怪兽区有空位且这张卡能够从手卡特殊召唤，并登记特殊召唤操作。
function c12289247.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性检查：没有空余怪兽区域或该卡不能特殊召唤时不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本效果将特殊召唤这张卡，供时点/连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 怪兽效果①处理：先特殊召唤自己，若成功且手卡有可特殊召唤的怪兽，则询问玩家是否额外特殊召唤并执行。
function c12289247.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行本卡从手卡的特殊召唤；若失败则不再进行后续额外特殊召唤。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
		return
	end
	-- 获取手卡中所有可以被效果特殊召唤的怪兽，作为“那之后”可选的额外特殊召唤对象。
	local g=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,nil,e,0,tp,false,false)
	-- 只有当存在可选怪兽且场上仍有怪兽区空位时，才继续后续询问。
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否“从手卡把怪兽特殊召唤”，选择是才执行额外召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(12289247,4)) then  --"是否从手卡把怪兽特殊召唤？"
		-- 中断当前效果处理，使后续额外特殊召唤成为独立事件，避免错过时点。
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将玩家选择的手卡怪兽特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤怪兽效果②的除外素材：必须是「灵摆龙」「超量龙」「同调龙」「融合龙」任一字段的怪兽、可作为代价除外，且场上的素材需表侧表示。
function c12289247.cfilter(c)
	return c:IsSetCard(0x10f2,0x2073,0x2017,0x1046)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 辅助判断：将当前候选素材组与本卡合并，检查额外卡组是否存在能以此作为融合素材的「霸王龙 扎克」。
function c12289247.hngoal(g,e,tp,c)
	local sg=Group.FromCards(c)
	sg:Merge(g)
	-- 确认额外卡组存在可用的「霸王龙 扎克」，且使用该素材组能够满足融合召唤条件。
	return Duel.IsExistingMatchingCard(c12289247.hnfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
-- 额外卡组中「霸王龙 扎克」的特殊召唤条件：是扎克、能以融合召唤方式特殊召唤、满足融合素材要求，且除素材后额外怪兽区有空位。
function c12289247.hnfilter(c,e,tp,sg)
	return c:IsCode(13331639) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		-- 若提供了素材组，还需保证把这些素材除外的场地空格足够让扎克特殊召唤。
		and (not sg or Duel.GetLocationCountFromEx(tp,tp,sg,c)>0)
end
-- 怪兽效果②的代价处理：从手牌·场上·墓地选择「灵摆龙」「超量龙」「同调龙」「融合龙」各1只，与本卡一起除外。
function c12289247.hncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 收集手牌·场上·墓地中可作为素材的龙族怪兽。
	local mg=Duel.GetMatchingGroup(c12289247.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 代价可行还需要额外卡组存在可融合召唤的「霸王龙 扎克」。
		and Duel.IsExistingMatchingCard(c12289247.hnfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and mg:CheckSubGroupEach(c12289247.hnchecks,c12289247.hngoal,e,tp,c) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=mg:SelectSubGroupEach(tp,c12289247.hnchecks,false,c12289247.hngoal,e,tp,c)
	sg:AddCard(c)
	-- 将选中的素材和场上的这张卡表侧除外支付代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 怪兽效果②的发动检测：确认不存在必须作为融合素材的限制，并登记从额外卡组特殊召唤的操作。
function c12289247.hntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若存在强制融合素材限制效果则不能发动。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	-- 登记本效果将要从额外卡组特殊召唤1只怪兽，供相关卡检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果②处理：从额外卡组选1只「霸王龙 扎克」，以融合召唤方式特殊召唤，并完成融合手续。
function c12289247.hnop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认没有强制融合素材限制，若有变化则终止特殊召唤。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的「霸王龙 扎克」。
	local g=Duel.SelectMatchingCard(tp,c12289247.hnfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选的「霸王龙 扎克」以融合召唤（SUMMON_TYPE_FUSION）特殊召唤到己方场上。
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
