--クロノグラフ・マジシャン
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「时读之魔术师」在自己的灵摆区域放置或特殊召唤。
-- 【怪兽效果】
-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从手卡把1只怪兽特殊召唤。
-- ②：把自己的手卡·场上·墓地的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各1只和场上的这张卡除外才能发动。把1只「霸王龙 扎克」当作融合召唤从额外卡组特殊召唤。
function c12289247.initial_effect(c)
	-- 记录这张卡的效果文本中记载了「霸王龙 扎克」(13331639)的卡名
	aux.AddCodeList(c,13331639)
	-- 为这张卡注册灵摆怪兽的通用属性（灵摆卡发动与灵摆召唤规则）
	aux.EnablePendulumAttribute(c)
	-- ←8 【灵摆】 8→ 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「时读之魔术师」在自己的灵摆区域放置或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12289247,0))  --"这张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
		-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c12289247.regcon)
		ge1:SetOperation(c12289247.regop)
		-- 在全局注册用于监听场上卡片破坏并抛出自定义事件的持续效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 生成包含「灵摆龙」「超量龙」「同调龙」「融合龙」四个字段检测函数的检查列表
c12289247.hnchecks=aux.CreateChecks(Card.IsSetCard,{0x10f2,0x2073,0x2017,0x1046})
-- 过滤函数：判断卡片是否原本在己方场上控制且因战斗或效果被破坏
function c12289247.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 全局监听效果的Condition函数：统计被破坏卡片中属于玩家0或玩家1的数量，记录受影响玩家到Label
function c12289247.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c12289247.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c12289247.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 全局监听效果的Operation函数：触发自定义破坏事件EVENT_CUSTOM+12289247并传递受影响玩家标记
function c12289247.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 抛出自定义事件EVENT_CUSTOM+12289247，将受影响的场上被破坏卡片及玩家信息传递给手卡中的怪兽效果①
	Duel.RaiseEvent(eg,EVENT_CUSTOM+12289247,re,r,rp,ep,e:GetLabel())
end
-- 过滤函数：筛选手卡或卡组中未被禁止使用或可特殊召唤的「时读之魔术师」(20409757)
function c12289247.rpfilter(c,e,tp)
	return c:IsCode(20409757) and (not c:IsForbidden()
		-- 或者检查己方主要怪兽区有空位且「时读之魔术师」可以被特殊召唤
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 灵摆效果①的Target函数：确认手卡或卡组存在可操作的「时读之魔术师」，并设置破坏这张卡的操作信息
function c12289247.rptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方手卡或卡组中存在至少1只满足放置或特召条件的「时读之魔术师」
	if chk==0 then return Duel.IsExistingMatchingCard(c12289247.rpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置将灵摆区域的这张卡破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果①的Operation函数：破坏这张卡后，从手卡·卡组选1只「时读之魔术师」放置到灵摆区域或特殊召唤到怪兽区
function c12289247.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联并将其破坏，成功破坏后执行后续处理
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 向己方玩家发送选择1只「时读之魔术师」的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(12289247,6))  --"请选择1只「时读之魔术师」"
		-- 从己方手卡或卡组中选择1只「时读之魔术师」
		local g=Duel.SelectMatchingCard(tp,c12289247.rpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		local op=0
		-- 检查己方主要怪兽区是否有空位且选中的「时读之魔术师」是否能够特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 让己方玩家在“灵摆区域放置”和“特殊召唤”两个选项中二选一
			op=Duel.SelectOption(tp,aux.Stringid(12289247,1),aux.Stringid(12289247,2))  --"灵摆区域放置/特殊召唤"
		else
			-- 当无法特殊召唤时，仅提供“灵摆区域放置”选项供确认
			op=Duel.SelectOption(tp,aux.Stringid(12289247,1))  --"灵摆区域放置"
		end
		if op==0 then
			-- 将选中的「时读之魔术师」表侧放置在己方灵摆区域并启用其效果
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			-- 将选中的「时读之魔术师」表侧特殊召唤到己方怪兽区
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 怪兽效果①的Condition函数：检查本次自定义破坏事件是否包含己方玩家场上的卡片
function c12289247.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 怪兽效果①的Target函数：检测己方怪兽区有空位且手卡中的这张卡可特召，并设置特殊召唤操作信息
function c12289247.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动检测时确认己方主要怪兽区有空位且这张卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将手卡中的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 怪兽效果①的Operation函数：从手卡特殊召唤这张卡后，可进一步选择从手卡特殊召唤1只怪兽
function c12289247.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡从手卡特殊召唤，若特召失败则直接终止后续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
		return
	end
	-- 获取己方手卡中所有可以被当前效果特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,nil,e,0,tp,false,false)
	-- 检查手卡中存在可特召怪兽且己方怪兽区仍有可用空位
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问己方玩家是否要继续从手卡特殊召唤1只怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(12289247,4)) then  --"是否从手卡把怪兽特殊召唤？"
		-- 中断当前处理步骤，使后续手卡怪兽的特殊召唤视为不同时处理（“那之后”）
		Duel.BreakEffect()
		-- 向己方玩家发送选择要特殊召唤的怪兽的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将从手卡选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：筛选属于四大龙字段之一、可作为代价除外的怪兽（若在怪兽区则须为表侧表示）
function c12289247.cfilter(c)
	return c:IsSetCard(0x10f2,0x2073,0x2017,0x1046)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 组合目标检查函数：将已选素材与场上的这张卡合并，检查除外后额外卡组是否能融合召唤「霸王龙 扎克」
function c12289247.hngoal(g,e,tp,c)
	local sg=Group.FromCards(c)
	sg:Merge(g)
	-- 检查考虑离场空位后，额外卡组是否存在可当作融合召唤特殊召唤的「霸王龙 扎克」
	return Duel.IsExistingMatchingCard(c12289247.hnfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
-- 过滤函数：筛选额外卡组中满足融合召唤条件及空位要求的「霸王龙 扎克」(13331639)
function c12289247.hnfilter(c,e,tp,sg)
	return c:IsCode(13331639) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		-- 检查若跳过素材或将素材sg从场上除外离场后，从额外卡组特召「霸王龙 扎克」是否有可用格子
		and (not sg or Duel.GetLocationCountFromEx(tp,tp,sg,c)>0)
end
-- 怪兽效果②的Cost函数：检查并选择手卡·场上·墓地的四龙各1只与场上的这张卡一并表侧除外作为发动代价
function c12289247.hncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 收集己方手卡、怪兽区和墓地中所有符合除外代价条件的四龙字段怪兽
	local mg=Duel.GetMatchingGroup(c12289247.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 确认己方额外卡组中存在可特殊召唤的「霸王龙 扎克」
		and Duel.IsExistingMatchingCard(c12289247.hnfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and mg:CheckSubGroupEach(c12289247.hnchecks,c12289247.hngoal,e,tp,c) end
	-- 向己方玩家发送选择要除外的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=mg:SelectSubGroupEach(tp,c12289247.hnchecks,false,c12289247.hngoal,e,tp,c)
	sg:AddCard(c)
	-- 将选出的四龙怪兽和这张卡作为发动代价以表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 怪兽效果②的Target函数：进行融合素材必须限制检查，并设置从额外卡组特殊召唤1只怪兽的操作信息
function c12289247.hntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否未受到“必须使用特定卡作为融合素材”效果的限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	-- 设置从己方额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果②的Operation函数：从额外卡组选1只「霸王龙 扎克」当作融合召唤特殊召唤并完成正规召唤手续
function c12289247.hnop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认未受到强制融合素材效果的限制
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 向己方玩家发送选择要特殊召唤的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方额外卡组中选择1只「霸王龙 扎克」
	local g=Duel.SelectMatchingCard(tp,c12289247.hnfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的「霸王龙 扎克」以融合召唤方式表侧特殊召唤到己方场上
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
