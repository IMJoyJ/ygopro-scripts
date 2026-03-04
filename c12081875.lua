--轟雷機龍－サンダー・ドラゴン
-- 效果：
-- 雷族怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡是已连接召唤的场合，从自己墓地的怪兽以及除外的自己怪兽之中以1只「雷龙」怪兽为对象才能发动。那只怪兽记述的把自身从手卡丢弃发动的效果适用。那之后，那只怪兽回到卡组最上面或者最下面。
-- ②：自己场上的雷族怪兽被战斗·效果破坏的场合，可以作为代替把自己墓地3张卡除外。
function c12081875.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2个雷族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_THUNDER),2)
	-- ①：这张卡是已连接召唤的场合，从自己墓地的怪兽以及除外的自己怪兽之中以1只「雷龙」怪兽为对象才能发动。
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
-- 效果发动的条件：这张卡必须是通过连接召唤方式出场的
function c12081875.effcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤满足条件的「雷龙」怪兽，用于效果的对象选择
function c12081875.efffilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x11c) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())) then return false end
	local te=c.discard_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg and tg(e,tp,eg,ep,ev,re,r,rp,0)
end
-- 设置效果的目标选择处理，包括选择墓地或除外区的「雷龙」怪兽
function c12081875.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c12081875.efffilter(chkc,e,tp,eg,ep,ev,re,r,rp) end
	-- 检查是否存在满足条件的「雷龙」怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c12081875.efffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择满足条件的「雷龙」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c12081875.efffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	-- 设置效果操作信息，标记将选择的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	local tc=g:GetFirst()
	-- 清除当前效果的已选择对象
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
	local te=tc.discard_effect
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
-- 效果的处理函数，用于执行选择怪兽的效果
function c12081875.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		local te=tc.discard_effect
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 判断是否选择将怪兽送回卡组顶端或底端
		if tc:IsExtraDeckMonster() or Duel.SelectOption(tp,aux.Stringid(12081875,1),aux.Stringid(12081875,2))==0 then  --"回到卡组最上面"
			-- 将怪兽送回卡组顶端
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将怪兽送回卡组底端
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
-- 过滤满足条件的雷族怪兽，用于代替破坏的效果
function c12081875.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_THUNDER) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 设置代替破坏效果的目标处理函数
function c12081875.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c12081875.repfilter,1,nil,tp)
		-- 检查自己墓地中是否存在至少3张可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,3,nil) end
	-- 询问玩家是否发动此效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		-- 选择3张可除外的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,3,3,nil)
		-- 将选择的卡除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	end
	return false
end
-- 设置代替破坏效果的值，返回是否满足代替破坏条件
function c12081875.repval(e,c)
	return c12081875.repfilter(c,e:GetHandlerPlayer())
end
