--クロノグラフ・マジシャン
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「时读之魔术师」在自己的灵摆区域放置或特殊召唤。
-- 【怪兽效果】
-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从手卡把1只怪兽特殊召唤。
-- ②：把自己的手卡·场上·墓地的「灵摆龙」「超量龙」「同调龙」「融合龙」怪兽各1只和场上的这张卡除外才能发动。把1只「霸王龙 扎克」当作融合召唤从额外卡组特殊召唤。
function c12289247.initial_effect(c)
	-- 注册卡片脚本中涉及到的特定卡片密码（霸王龙 扎克）
	aux.AddCodeList(c,13331639)
	-- 为怪兽添加灵摆怪兽的基本属性和效果
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组选1只「时读之魔术师」在自己的灵摆区域放置或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12289247,0))  --"这张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,12289247)
	e1:SetTarget(c12289247.rptg)
	e1:SetOperation(c12289247.rpop)
	c:RegisterEffect(e1)
	-- ①：自己场上的卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从手卡把1只怪兽特殊召唤。
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
		-- 自己场上的卡被战斗·效果破坏的场合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c12289247.regcon)
		ge1:SetOperation(c12289247.regop)
		-- 注册全局效果，用于在任何卡片被破坏时进行检测
		Duel.RegisterEffect(ge1,0)
	end
end
-- 创建一个条件检查数组，用于依次校验四种龙（灵摆、超量、同调、融合）
c12289247.hnchecks=aux.CreateChecks(Card.IsSetCard,{0x10f2,0x2073,0x2017,0x1046})
-- 过滤函数：检查卡片是否因战斗或效果被破坏，且原持有者为指定玩家且原位置在场上
function c12289247.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 全局效果的发动条件：检查是否有玩家场上的卡被破坏
function c12289247.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c12289247.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c12289247.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 全局效果的操作：根据破坏情况触发自定义事件，并记录受影响的玩家
function c12289247.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 抛出一个自定义事件，通知手卡中的刻读之魔术士有卡被破坏
	Duel.RaiseEvent(eg,EVENT_CUSTOM+12289247,re,r,rp,ep,e:GetLabel())
end
-- 过滤函数：检索「时读之魔术师」并检查其是否能放置在灵摆区或特殊召唤
function c12289247.rpfilter(c,e,tp)
	return c:IsCode(20409757) and (not c:IsForbidden()
		-- 检查怪兽区域是否有空位以及该卡是否可以特殊召唤
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 灵摆效果的发动准备：检查手卡或卡组是否存在可操作的「时读之魔术师」
function c12289247.rptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或卡组是否存在满足条件的「时读之魔术师」
	if chk==0 then return Duel.IsExistingMatchingCard(c12289247.rpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：包含破坏自身的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果的处理：破坏自身并从手卡或卡组选「时读之魔术师」放置或特招
function c12289247.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于发动位置则将其破坏，破坏成功后执行后续处理
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 给玩家发送提示信息：请选择1只「时读之魔术师」
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(12289247,6))  --"请选择1只「时读之魔术师」"
		-- 从手卡或卡组选择1只满足条件的「时读之魔术师」
		local g=Duel.SelectMatchingCard(tp,c12289247.rpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		local op=0
		-- 检查怪兽区域是否有空位且该卡是否可以特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 让玩家选择将卡放置在灵摆区域或进行特殊召唤
			op=Duel.SelectOption(tp,aux.Stringid(12289247,1),aux.Stringid(12289247,2))  --"灵摆区域放置" / "特殊召唤"
		else
			-- 因不满足特招条件，玩家只能选择将卡放置在灵摆区域
			op=Duel.SelectOption(tp,aux.Stringid(12289247,1))  --"灵摆区域放置"
		end
		if op==0 then
			-- 将选中的卡片移动到玩家的灵摆区域
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			-- 将选中的卡片特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 怪兽效果①的发动条件：检查触发事件的玩家是否为自己或双方
function c12289247.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 怪兽效果①的发动准备：检查自身是否能特殊召唤
function c12289247.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有空位且自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 怪兽效果①的处理：特殊召唤自身，并可选从手卡特招一只怪兽
function c12289247.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试特殊召唤自身，若特殊召唤失败则不执行后续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
		return
	end
	-- 获取手卡中所有可以特殊召唤的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,nil,e,0,tp,false,false)
	-- 检查手卡是否有可特招的怪兽且场上有空余位置
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否要从手卡把1只怪兽特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(12289247,4)) then  --"是否从手卡把怪兽特殊召唤？"
		-- 中断效果处理，使后续的特殊召唤不与前面的处理视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的手卡怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：检查是否为手卡、场上或墓地的四种龙怪兽且能被除外
function c12289247.cfilter(c)
	return c:IsSetCard(0x10f2,0x2073,0x2017,0x1046)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 检查选定的素材组是否能满足特殊召唤「霸王龙 扎克」的条件
function c12289247.hngoal(g,e,tp,c)
	local sg=Group.FromCards(c)
	sg:Merge(g)
	-- 检查额外卡组是否存在满足条件的「霸王龙 扎克」
	return Duel.IsExistingMatchingCard(c12289247.hnfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
-- 过滤函数：检查是否为「霸王龙 扎克」且满足融合召唤的特殊召唤条件
function c12289247.hnfilter(c,e,tp,sg)
	return c:IsCode(13331639) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		-- 检查在素材离场后，是否具备从额外卡组特殊召唤怪兽所需的可用区域
		and (not sg or Duel.GetLocationCountFromEx(tp,tp,sg,c)>0)
end
-- 怪兽效果②的消耗处理：检查并选择除外自身及四种龙怪兽
function c12289247.hncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取手卡、场上、墓地中所有可作为素材的龙怪兽组
	local mg=Duel.GetMatchingGroup(c12289247.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查额外卡组是否存在可以特殊召唤的「霸王龙 扎克」
		and Duel.IsExistingMatchingCard(c12289247.hnfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and mg:CheckSubGroupEach(c12289247.hnchecks,c12289247.hngoal,e,tp,c) end
	-- 提示玩家选择要除外的素材卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=mg:SelectSubGroupEach(tp,c12289247.hnchecks,false,c12289247.hngoal,e,tp,c)
	sg:AddCard(c)
	-- 将选定的素材卡片以正面表示除外作为发动代价
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 怪兽效果②的发动准备：检查融合素材限制
function c12289247.hntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在必须作为融合素材使用的规则限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) end
	-- 设置效果处理信息：包含从额外卡组特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果②的处理：将「霸王龙 扎克」当作融合召唤特殊召唤
function c12289247.hnop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查是否存在必须作为融合素材使用的规则限制
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从额外卡组选择1只满足条件的「霸王龙 扎克」
	local g=Duel.SelectMatchingCard(tp,c12289247.hnfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的怪兽当作融合召唤特殊召唤到场上
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
