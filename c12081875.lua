--轟雷機龍－サンダー・ドラゴン
-- 效果：
-- 雷族怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡是已连接召唤的场合，从自己墓地的怪兽以及除外的自己怪兽之中以1只「雷龙」怪兽为对象才能发动。那只怪兽记述的把自身从手卡丢弃发动的效果适用。那之后，那只怪兽回到卡组最上面或者最下面。
-- ②：自己场上的雷族怪兽被战斗·效果破坏的场合，可以作为代替把自己墓地3张卡除外。
function c12081875.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以2只以上雷族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_THUNDER),2)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡是已连接召唤的场合，从自己墓地的怪兽以及除外的自己怪兽之中以1只「雷龙」怪兽为对象才能发动。那只怪兽记述的把自身从手卡丢弃发动的效果适用。那之后，那只怪兽回到卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12081875,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,12081875)
	e1:SetCondition(c12081875.effcon)
	e1:SetTarget(c12081875.efftg)
	e1:SetOperation(c12081875.effop)
	c:RegisterEffect(e1)
	-- ②：自己场上的雷族怪兽被战斗·效果破坏的场合，可以作为代替把自己墓地3张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c12081875.reptg)
	e2:SetValue(c12081875.repval)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：判定这张卡是否以连接召唤方式出场，是则满足发动条件。
function c12081875.effcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果选择对象的过滤条件：对象必须是卡名含「雷龙」的怪兽卡，位于自己墓地或表侧除外区，能够回到卡组，且拥有“把自身从手卡丢弃发动”的效果，并且该效果在当前情境下可以发动/适用。
function c12081875.efffilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x11c) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())) then return false end
	local te=c.discard_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg and tg(e,tp,eg,ep,ev,re,r,rp,0)
end
-- ①效果发动时的目标选择处理：检查是否存在合法对象；若存在则让玩家选择1张符合条件的「雷龙」怪兽，设定返回卡组的操作信息，将所选对象与该效果建立关联，并调用所选对象自身记载的“丢弃自身发动”效果的Target函数进行后续处理。
function c12081875.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c12081875.efffilter(chkc,e,tp,eg,ep,ev,re,r,rp) end
	-- 发动时合法性检查：确认自己墓地或表侧除外区是否存在至少1只满足条件的「雷龙」怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c12081875.efffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	-- 给当前玩家显示选择对象的提示信息，提示文字为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让当前玩家从自己墓地或除外区中选择1张符合条件的「雷龙」怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c12081875.efffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	-- 设置当前连锁的操作信息：本效果处理将涉及1张卡返回卡组（CATEGORY_TODECK），对象为已选择的目标。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	local tc=g:GetFirst()
	-- 清除当前连锁的常规对象记录，因为后续需要手动将目标与效果关联，避免标准对象机制产生干扰。
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	local te=tc.discard_effect
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
-- ①效果处理时：获取之前保存的「雷龙」怪兽；若仍与效果关联，则适用该怪兽记述的“从手卡丢弃自身发动”的效果；之后将该怪兽送回卡组最上面或最下面（玩家选择，额外卡组怪兽则直接送回）。
function c12081875.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		local te=tc.discard_effect
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		-- 中断当前效果处理流程，使后续的送回卡组处理与之前适用的丢弃自身效果不在同一时点处理，避免错失时点。
		Duel.BreakEffect()
		-- 判断目标回卡组的位置：若是额外卡组怪兽，或玩家选择“回到卡组最上面”，则执行回卡组顶端；否则回卡组底端。
		if tc:IsExtraDeckMonster() or Duel.SelectOption(tp,aux.Stringid(12081875,1),aux.Stringid(12081875,2))==0 then  --"回到卡组最上面/回到卡组最下面"
			-- 将目标怪兽以效果原因送回持有者卡组最上面（额外卡组怪兽则回到额外卡组）。
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将目标怪兽以效果原因送回持有者卡组最下面。
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
-- ②效果替换破坏的判定过滤：被破坏的怪兽必须是己方表侧表示的雷族怪兽，位于怪兽区域，且破坏原因包含战斗或效果，且该破坏不是由“代替破坏”产生的，才可由②效果代替。
function c12081875.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_THUNDER) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的触发判定：若场上存在将被战斗或效果破坏的己方表侧雷族怪兽，并且自己墓地有至少3张可以除外的卡，则满足发动条件。
function c12081875.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c12081875.repfilter,1,nil,tp)
		-- 追加检查：自己墓地是否存在至少3张可以除外的卡（作为代替除外所需的代价）。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,3,nil) end
	-- 在满足条件时，询问当前玩家是否发动②效果来替代这次破坏。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 给当前玩家显示选择要除外的卡的提示信息，提示文字为“请选择要除外的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让当前玩家从自己墓地选择3张可以除外的卡。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,3,3,nil)
		-- 将选择的3张卡以表侧表示除外，除外原因包含效果和代替，作为该次破坏的代替处理。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	end
	return false
end
-- ②效果的Value函数：判断被破坏的怪兽c是否满足repfilter（己方表侧雷族怪兽且被战斗/效果破坏且非代替破坏），决定是否适用代替破坏。
function c12081875.repval(e,c)
	return c12081875.repfilter(c,e:GetHandlerPlayer())
end
