--フィッシュボーグ－ハープナー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡和手卡1只水属性怪兽给对方观看才能发动。那2只之内的1只特殊召唤，另1只丢弃。
-- ②：这张卡作为水属性同调怪兽的同调素材送去墓地的场合才能发动。对方场上1只效果怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 注册卡片效果：①手卡展示特召/丢弃的起动效果，②作为水属性同调素材送墓时无效对方怪兽的诱发效果。
function s.initial_effect(c)
	-- ①：把手卡的这张卡和手卡1只水属性怪兽给对方观看才能发动。那2只之内的1只特殊召唤，另1只丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为水属性同调怪兽的同调素材送去墓地的场合才能发动。对方场上1只效果怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效对方怪兽"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中未公开的水属性怪兽，且该怪兽与这张卡中必须有一张能特召、另一张能送墓。
function s.costfilter(c,ec,e,tp)
	if not c:IsAttribute(ATTRIBUTE_WATER) or c:IsPublic() then return false end
	local g=Group.FromCards(c,ec)
	return g:IsExists(s.tgspfilter,1,nil,g,e,tp)
end
-- 过滤可特殊召唤且卡片组中存在另一张可送去墓地的卡。
function s.tgspfilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsAbleToGrave,1,c)
end
-- ①效果的发动代价：展示手卡的这张卡和另1只水属性怪兽，并记录另一张卡的信息。
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身未公开，且手卡中存在满足过滤条件的水属性怪兽。
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c,c,e,tp) end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手卡选择1只满足条件的水属性怪兽。
	local sc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c,c,e,tp):GetFirst()
	-- 给对方玩家确认选择的怪兽。
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切自身手卡。
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- ①效果的发动准备：检查怪兽区域空位，并设置丢弃手卡与特殊召唤的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置丢弃1张手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,LOCATION_HAND)
	-- 设置特殊召唤1只手卡怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的效果处理：在展示的两张卡中选择1只特殊召唤，另1只作为丢弃送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若无空位则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToEffect,nil,e)
	if fg:GetCount()~=2 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=fg:FilterSelect(tp,s.tgspfilter,1,1,nil,fg,e,tp)
	-- 若成功特殊召唤选择的怪兽，则进行后续处理。
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 将另一只怪兽因效果丢弃送去墓地。
		Duel.SendtoGrave(g-sg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- ②效果的发动条件：这张卡作为水属性同调怪兽的同调素材送去墓地。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsAttribute(ATTRIBUTE_WATER)
end
-- ②效果的发动准备：获取对方场上可无效的怪兽，并设置无效效果的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有可无效化的怪兽。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置无效场上1张卡的效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,LOCATION_MZONE)
end
-- ②效果的效果处理：选择对方场上1只效果怪兽，直到回合结束时将其效果无效。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1只可无效化的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 闪烁显示所选择的怪兽。
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	if tc then
		-- 使与目标怪兽相关的连锁效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 效果直到回合结束时无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果直到回合结束时无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 效果直到回合结束时无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
