--アストログラフ・マジシャン
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「星读之魔术师」在自己的灵摆区域放置或特殊召唤。
-- 【怪兽效果】
-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以选这个回合被破坏的1只自己或对方的怪兽，那1只同名怪兽从卡组加入手卡。
-- ②：把自己的手卡·场上·墓地的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各1只和场上的这张卡除外才能发动。把1只「霸王龙 扎克」当作融合召唤从额外卡组特殊召唤。
function c76794549.initial_effect(c)
	-- 记录此卡文本上记述了「霸王龙 扎克」卡名
	aux.AddCodeList(c,13331639)
	-- 为这张卡注册灵摆怪兽属性（灵摆召唤与灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ←1 【灵摆】 1→ 这个卡名的灵摆效果1回合只能使用1次。 ①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「星读之魔术师」在自己的灵摆区域放置或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76794549,0))  --"这张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,76794549)
	e1:SetTarget(c76794549.rptg)
	e1:SetOperation(c76794549.rpop)
	c:RegisterEffect(e1)
	-- 【怪兽效果】 ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以选这个回合被破坏的1只自己或对方的怪兽，那1只同名怪兽从卡组加入手卡。
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
		-- 那之后，可以选这个回合被破坏的1只自己或对方的怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c76794549.checkop)
		-- 注册全局永续效果，为每回合被破坏并送去墓地、除外区或额外卡组的卡添加本回合标识
		Duel.RegisterEffect(ge1,0)
		-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_DESTROYED)
		ge2:SetCondition(c76794549.regcon)
		ge2:SetOperation(c76794549.regop)
		-- 注册全局永续效果，监听场上的卡被战斗·效果破坏的时点并触发自定义事件
		Duel.RegisterEffect(ge2,0)
	end
end
-- 构建4组字段判定函数列表，依次检查「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽
c76794549.hnchecks=aux.CreateChecks(Card.IsSetCard,{0x10f2,0x2073,0x2017,0x1046})
-- 全局破坏标记回调，为被破坏进入墓地·除外区或表侧加入额外卡组的卡注册持续至回合结束的标识
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
-- 过滤函数，检查卡片是否为之前位于玩家tp场上且因战斗或效果被破坏的卡
function c76794549.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 触发检查函数，判断本次破坏事件涉及哪一方场上的卡并记录受影响的玩家编号
function c76794549.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c76794549.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c76794549.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 触发自定义破坏事件，将记录的受影响玩家信息传递给手卡效果
function c76794549.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 引发自定义破坏时点，通知手卡中的此卡满足发动时机
	Duel.RaiseEvent(eg,EVENT_CUSTOM+76794549,re,r,rp,ep,e:GetLabel())
end
-- 过滤函数，检查是否为「星读之魔术师」，且不被禁止放置于灵摆区或在有空位时可特殊召唤
function c76794549.rpfilter(c,e,tp)
	return c:IsCode(94415058) and (not c:IsForbidden()
		-- 或者检查自己怪兽区有空位且「星读之魔术师」可以被特殊召唤
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 检查手卡·卡组是否存在可放置或特殊召唤的「星读之魔术师」，并设置破坏自身的操作信息
function c76794549.rptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·卡组是否存在至少1只满足条件的「星读之魔术师」
	if chk==0 then return Duel.IsExistingMatchingCard(c76794549.rpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置破坏灵摆区这张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理，破坏灵摆区的这张卡后从手卡·卡组选1只「星读之魔术师」放置于灵摆区或特殊召唤
function c76794549.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与效果关联后将其破坏并判断是否成功破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 提示控制者选择1只「星读之魔术师」
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76794549,6))  --"请选择1只「星读之魔术师」"
		-- 从自己手卡·卡组选择1只「星读之魔术师」
		local g=Duel.SelectMatchingCard(tp,c76794549.rpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()==0 then return end
		local tc=g:GetFirst()
		local op=0
		-- 检查自己怪兽区是否有空位且选中的「星读之魔术师」可否特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 当放置与特殊召唤均可行时，让控制者选择在灵摆区域放置或特殊召唤
			op=Duel.SelectOption(tp,aux.Stringid(76794549,1),aux.Stringid(76794549,2))  --"灵摆区域放置/特殊召唤"
		else
			-- 当无法特殊召唤时，提供在灵摆区域放置的选项
			op=Duel.SelectOption(tp,aux.Stringid(76794549,1))  --"灵摆区域放置"
		end
		if op==0 then
			-- 将选中的「星读之魔术师」表侧表示放置到自己的灵摆区域
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			-- 将选中的「星读之魔术师」表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 发动条件检查，确认触发自定义破坏事件的受影响玩家包含自己
function c76794549.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 检查自己怪兽区是否有空位且此卡可特殊召唤，并设置操作信息
function c76794549.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否至少有1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将手卡的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤函数，检查是否为本回合被破坏且在墓地或表侧存在的怪兽，且卡组存在其可加手的同名怪兽
function c76794549.thfilter1(c,tp,id)
	return c:IsType(TYPE_MONSTER) and c:GetFlagEffect(76794549)~=0
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		-- 检查自己卡组是否存在该被破坏怪兽的可加入手卡的同名怪兽
		and Duel.IsExistingMatchingCard(c76794549.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤函数，检查是否为指定卡号且可加入手卡的怪兽
function c76794549.thfilter2(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 效果处理，将此卡从手卡特殊召唤后，可选取1只本回合被破坏的怪兽并从卡组把其1只同名怪兽加入手卡
function c76794549.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡表侧表示特殊召唤并判断是否成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 从双方墓地·除外区·额外卡组获取本回合被破坏且卡组有同名怪兽可检索的怪兽
		local g=Duel.GetMatchingGroup(c76794549.thfilter1,tp,0x70,0x70,nil,tp,Duel.GetTurnCount())
		-- 询问控制者是否将被破坏怪兽的同名怪兽加入手卡
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(76794549,4)) then  --"是否把破坏怪兽的同名怪兽加入手卡？"
			-- 中断当前效果处理，使后续检索加手与前面的特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 提示控制者选择本回合被破坏的1只怪兽作为检索参照
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76794549,7))  --"请选择这个回合被破坏的1只怪兽"
			local cg=g:Select(tp,1,1,nil)
			-- 为选中的本回合被破坏怪兽显示提示动画
			Duel.HintSelection(cg)
			-- 提示控制者从卡组选择要加入手卡的同名怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从自己卡组选择1只与参照怪兽同名的怪兽
			local sg=Duel.SelectMatchingCard(tp,c76794549.thfilter2,tp,LOCATION_DECK,0,1,1,nil,cg:GetFirst():GetCode())
			-- 将选中的同名怪兽加入自己手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 过滤函数，检查是否为手卡·表侧场上·墓地中属于四龙字段且可作为代价除外的怪兽
function c76794549.cfilter(c)
	return c:IsSetCard(0x10f2,0x2073,0x2017,0x1046)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 子集检查目标函数，验证将此卡与选出的4只怪兽除外后额外卡组是否仍有空位召唤「霸王龙 扎克」
function c76794549.hngoal(g,e,tp,c)
	local sg=Group.FromCards(c)
	sg:Merge(g)
	-- 检查额外卡组是否存在在移除指定5张卡后仍可融合召唤出场的「霸王龙 扎克」
	return Duel.IsExistingMatchingCard(c76794549.hnfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
-- 过滤函数，检查额外卡组怪兽是否为「霸王龙 扎克」、可当作融合召唤特殊召唤且额外出场空位充足
function c76794549.hnfilter(c,e,tp,sg)
	return c:IsCode(13331639) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		-- 检查在指定素材离场后，从额外卡组特殊召唤「霸王龙 扎克」的怪兽区空位是否足够
		and (not sg or Duel.GetLocationCountFromEx(tp,tp,sg,c)>0)
end
-- 发动代价处理，检查并选择把场上的此卡与手卡·场上·墓地的四龙怪兽各1只表侧除外
function c76794549.hncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己手卡·场上·墓地中所有满足四龙字段且可作为代价除外的怪兽
	local mg=Duel.GetMatchingGroup(c76794549.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查额外卡组是否存在满足融合召唤条件的「霸王龙 扎克」
		and Duel.IsExistingMatchingCard(c76794549.hnfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
		and mg:CheckSubGroupEach(c76794549.hnchecks,c76794549.hngoal,e,tp,c) end
	-- 提示控制者选择作为发动代价除外的四龙怪兽各1只
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=mg:SelectSubGroupEach(tp,c76794549.hnchecks,false,c76794549.hngoal,e,tp,c)
	sg:AddCard(c)
	-- 将选中的4只四龙怪兽和场上的这张卡一起表侧表示除外作为代价
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 检查必须融合素材限制并设置从额外卡组特殊召唤「霸王龙 扎克」的操作信息
function c76794549.hntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否受“必须使用特定融合素材”的效果限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	-- 设置从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理，从额外卡组选择1只「霸王龙 扎克」当作融合召唤表侧表示特殊召唤并完成正规召唤手续
function c76794549.hnop(e,tp,eg,ep,ev,re,r,rp)
	-- 若受到必须使用特定融合素材的效果限制则结束处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示控制者从额外卡组选择要融合召唤的「霸王龙 扎克」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己额外卡组选择1只「霸王龙 扎克」
	local g=Duel.SelectMatchingCard(tp,c76794549.hnfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将「霸王龙 扎克」当作融合召唤表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
