--破械式鬼シャラ
local s,id,o=GetID()
-- 注册卡片效果，包括墓地状态检查和两个效果：手牌时的特殊召唤+破坏效果，以及墓地时的特殊召唤/回手/从墓地特殊召唤效果
function s.initial_effect(c)
	-- 为该卡注册墓地状态检测标记，防止同一连锁中重复判定
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 手牌时发动的效果：在主要阶段可以特殊召唤1只恶魔族怪兽，并且可以选择场上1张卡破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
	-- 墓地时发动的效果：当有自己场上的卡因战斗或效果被破坏时，可以选择将此卡回手或特殊召唤到场上
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
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
-- 效果发动条件：必须在主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果发动条件：必须在主要阶段
	return Duel.IsMainPhase()
end
-- 效果费用：将此卡送去墓地作为费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 特殊召唤的过滤函数，筛选恶魔族且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标设定：检查是否有满足条件的怪兽可以特殊召唤，并设置破坏目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 设置操作信息，表示将要特殊召唤1张手牌中的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 获取对方场上的所有卡作为可能的破坏目标
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if g:GetCount()>0 then
		-- 设置操作信息，表示将要破坏场上1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理函数：执行特殊召唤和破坏操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 如果成功特殊召唤，则继续执行破坏操作
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使后续效果视为错时点
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1张卡作为破坏目标
		local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
		if sg:GetCount()>0 then
			-- 显示被选为对象的卡的动画效果
			Duel.HintSelection(sg)
			-- 将选定的卡破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
-- 破坏条件过滤函数：判断是否为场上的卡因战斗或效果被破坏且不是由自身效果造成
function s.cfilter(c,tp,se,re)
	return c:IsPreviousLocation(LOCATION_ONFIELD)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(id)))
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 触发条件：当有自己场上的卡因战斗或效果被破坏时生效
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,c,tp,se,re)
end
-- 效果目标设定：检查此卡是否可以回手或特殊召唤到场上
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand()
		-- 检查场上是否有足够的空间进行特殊召唤
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)) end
end
-- 效果处理函数：根据选择将此卡回手或特殊召唤到场上，并设置其离开场后回到牌组底部
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 检查此卡是否受到王家长眠之谷的影响，若受影响则无效该效果
	if aux.NecroValleyNegateCheck(c) then return end
	-- 检查此卡是否不受王家长眠之谷影响，若受则无效该效果
	if not aux.NecroValleyFilter()(c) then return end
	local b1=c:IsAbleToHand()
	-- 判断是否可以特殊召唤到场上
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local op=0
	if b1 and not b2 then
		op=1
	elseif not b1 and b2 then
		op=2
	else
		-- 根据可选选项选择操作方式
		op=aux.SelectFromOptions(tp,{b1,1190},{b2,1152})
	end
	if op==1 then
		-- 将此卡送入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
	-- 如果选择特殊召唤，则执行特殊召唤并设置其离开场后回到牌组底部
	if op==2 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置效果：当此卡离开场时，自动回到牌组底部
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1,true)
	end
end
