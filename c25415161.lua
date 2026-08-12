--スプリガンズ・インタールーダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把卡的效果发动时才能发动。自己场上1只「护宝炮妖」超量怪兽回到额外卡组。那之后，从以下效果选1个适用。
-- ●那个发动的效果无效。
-- ●从自己墓地把1只8星怪兽特殊召唤。
-- ②：自己场上的表侧表示的超量怪兽因效果从场上离开的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
function c25415161.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：对方把卡的效果发动时才能发动。自己场上1只「护宝炮妖」超量怪兽回到额外卡组。那之后，从以下效果选1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25415161,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,25415161)
	e1:SetCondition(c25415161.condition)
	e1:SetTarget(c25415161.target)
	e1:SetOperation(c25415161.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的超量怪兽因效果从场上离开的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25415161,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,25415162)
	e2:SetCondition(c25415161.atkcon)
	e2:SetTarget(c25415161.atktg)
	e2:SetOperation(c25415161.atkop)
	c:RegisterEffect(e2)
end
-- 效果发动时的处理条件：对方发动效果
function c25415161.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤满足条件的8星怪兽
function c25415161.spfilter(c,e,tp)
	return c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 根据solve参数决定是否应用王家长眠之谷的过滤条件
function c25415161.spsfilter(c,e,tp,solve)
	if solve then
		-- 应用王家长眠之谷的过滤条件
		return aux.NecroValleyFilter(c25415161.spfilter)(c,e,tp)
	else
		return c25415161.spfilter(c,e,tp)
	end
end
-- 过滤满足条件的护宝炮妖超量怪兽
function c25415161.tefilter(c,e,tp,ev,solve1,solve2)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
		-- 当无法无效效果时，检查是否有怪兽区空位
		and (solve1 or (Duel.IsChainDisablable(ev) or Duel.GetMZoneCount(tp,c)>0
		-- 当无法无效效果时，检查墓地是否有8星怪兽
		and Duel.IsExistingMatchingCard(c25415161.spsfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,solve2)))
end
-- 设置效果处理时的操作信息
function c25415161.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的护宝炮妖超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c25415161.tefilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ev) end
	-- 设置将怪兽送回额外卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_MZONE)
	-- 设置从墓地特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数：选择并送回护宝炮妖超量怪兽，然后选择效果
function c25415161.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的护宝炮妖超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择护宝炮妖超量怪兽并送回卡组
	local tc=Duel.SelectMatchingCard(tp,c25415161.tefilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ev,false,true):GetFirst()
	if not tc then
		-- 提示玩家选择要送回卡组的护宝炮妖超量怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 再次选择护宝炮妖超量怪兽并送回卡组
		tc=Duel.SelectMatchingCard(tp,c25415161.tefilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ev,true,true):GetFirst()
	end
	-- 确认护宝炮妖超量怪兽已送回卡组且在额外卡组
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 检查是否可以无效效果且墓地是否有8星怪兽
		if not Duel.IsChainDisablable(ev) and not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查墓地是否有8星怪兽
			and Duel.IsExistingMatchingCard(c25415161.spsfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,true)) then
			return
		end
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 检查是否可以无效效果且墓地是否有8星怪兽
		if Duel.IsChainDisablable(ev) and (Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
			-- 检查墓地是否有8星怪兽
			or not Duel.IsExistingMatchingCard(c25415161.spsfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,true)
			-- 选择效果：无效效果或特殊召唤8星怪兽
			or Duel.SelectOption(tp,aux.Stringid(25415161,2),1152)==0) then  --"效果无效"
			-- 使效果无效
			Duel.NegateEffect(ev)
		else
			-- 提示玩家选择要特殊召唤的8星怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择8星怪兽并特殊召唤
			local sg=Duel.SelectMatchingCard(tp,c25415161.spsfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,true)
			-- 执行特殊召唤操作
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤因效果离开场上的超量怪兽
function c25415161.atkfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_XYZ~=0
		and c:IsReason(REASON_EFFECT)
end
-- 效果发动时的处理条件：场上因效果离开的超量怪兽
function c25415161.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25415161.atkfilter,1,nil,tp)
end
-- 设置效果处理时的操作信息
function c25415161.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理函数：使对方场上所有怪兽攻击力下降1000
function c25415161.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 设置攻击力下降1000的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
