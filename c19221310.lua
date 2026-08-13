--オッドアイズ・セイバー・ドラゴン
-- 效果：
-- ①：这张卡在手卡的场合，把自己场上1只光属性怪兽解放才能发动。从手卡·卡组以及自己场上的表侧表示怪兽之中选1只「异色眼龙」送去墓地，这张卡特殊召唤。
-- ②：这张卡战斗破坏怪兽送去墓地时才能发动。选对方场上1只怪兽破坏。
function c19221310.initial_effect(c)
	-- ①：这张卡在手卡的场合，把自己场上1只光属性怪兽解放才能发动。从手卡·卡组以及自己场上的表侧表示怪兽之中选1只「异色眼龙」送去墓地，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19221310,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c19221310.spcost)
	e1:SetTarget(c19221310.sptg)
	e1:SetOperation(c19221310.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽送去墓地时才能发动。选对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19221310,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置②效果的发动条件：这张卡战斗破坏怪兽并将其送去墓地时才能发动（aux.bdgcon检查此卡与战斗的关联及战斗对象在墓地且为怪兽）。
	e2:SetCondition(aux.bdgcon)
	e2:SetTarget(c19221310.destg)
	e2:SetOperation(c19221310.desop)
	c:RegisterEffect(e2)
end
-- 定义①效果解放对象的过滤器：选择光属性怪兽作为解放代价；需考虑解放后场上是否有空位，且需保证手卡·卡组或自己场上表侧表示中存在可送去墓地的「异色眼龙」。
function c19221310.cfilter(c,ft,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 确认从手卡·卡组以及自己场上的表侧表示怪兽之中，存在至少1只可送去墓地的「异色眼龙」（卡号53025096），且排除作为候选解放的这张怪兽c。
		and Duel.IsExistingMatchingCard(c19221310.filter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK,0,1,c)
end
-- 定义①效果的发动代价：解放自己场上1只光属性怪兽。该函数先检查能否解放，再选择1只满足条件的怪兽并解放。
function c19221310.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方主要怪兽区的可用空格数ft，用于判断解放后是否有格子特殊召唤这张卡。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在代价检查阶段，判断是否存在至少1只满足cfilter条件的光属性怪兽可以解放；ft作为额外参数用于保证腾出空格。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c19221310.cfilter,1,nil,ft,tp) end
	-- 让玩家从我方场上选择1只满足cfilter条件的光属性怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c19221310.cfilter,1,1,nil,ft,tp)
	-- 将所选怪兽以规则代价（REASON_COST）解放。
	Duel.Release(g,REASON_COST)
end
-- 定义「异色眼龙」的选卡条件：卡号为53025096（异色眼龙）、可以被送去墓地，且位于手卡、卡组或自己场上的表侧表示怪兽区域。
function c19221310.filter(c)
	return c:IsCode(53025096) and c:IsAbleToGrave()
		and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup())
end
-- 定义①效果的发动目标与处理信息：确认这张卡可以被特殊召唤，并登记“将1只「异色眼龙」从手卡·卡组或自己场上表侧表示怪兽中送去墓地”以及“这张卡特殊召唤”的操作信息。
function c19221310.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：登记本次效果包含送去墓地的处理，目标范围为自己场上的表侧表示怪兽、手卡、卡组，预计数量为1（对象未确定，target为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK)
	-- 设置操作信息：登记本次效果包含特殊召唤，对象为这张卡本身（e:GetHandler()），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义①效果的处理：选择1只「异色眼龙」送去墓地；若送墓成功且这张卡仍与效果关联，则将这张卡特殊召唤。
function c19221310.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上的表侧表示怪兽、手卡、卡组中选择1张满足filter（即「异色眼龙」）的卡。
	local g=Duel.SelectMatchingCard(tp,c19221310.filter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的卡以效果原因送去墓地，并检查是否成功送墓、该卡确实在墓地、以及这张卡仍与效果关联，以决定是否继续特殊召唤。
	if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上；不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果的发动目标与处理信息：确认对方场上有怪兽，并登记破坏对方场上1只怪兽的操作信息。
function c19221310.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标检查阶段，确认对方主要怪兽区存在至少1只怪兽，以保证效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有怪兽组成候选组g，用于登记可能被破坏的对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：登记本次效果包含破坏处理，可能破坏的对象为候选组g中的怪兽，数量为1（实际处理时再选择）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义②效果的处理：选择对方场上1只怪兽并将其破坏。
function c19221310.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1只怪兽作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选的怪兽显示选中动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 以效果原因（REASON_EFFECT）将所选怪兽破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
