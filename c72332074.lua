--超量必殺アルファンボール
-- 效果：
-- ①：自己场上有「超级量子战士」怪兽3种类以上存在的场合才能发动。对方场上的卡全部回到持有者卡组。那之后，对方从额外卡组把1只怪兽无视召唤条件特殊召唤。
-- ②：从自己墓地把这张卡和1只「超级量子妖精 阿尔方」除外才能发动。从卡组把1张「超级量子机舰 炎磁大母舰」发动。
function c72332074.initial_effect(c)
	-- 注册本卡效果中提及的「超级量子妖精 阿尔方」与「超级量子机舰 炎磁大母舰」的卡片密码。
	aux.AddCodeList(c,58753372,10424147)
	-- ①：自己场上有「超级量子战士」怪兽3种类以上存在的场合才能发动。对方场上的卡全部回到持有者卡组。那之后，对方从额外卡组把1只怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72332074,0))  --"回到卡组"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c72332074.condition)
	e1:SetTarget(c72332074.target)
	e1:SetOperation(c72332074.activate)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1只「超级量子妖精 阿尔方」除外才能发动。从卡组把1张「超级量子机舰 炎磁大母舰」发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72332074,1))  --"发动场地"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c72332074.actcost)
	e2:SetTarget(c72332074.acttg)
	e2:SetOperation(c72332074.actop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「超级量子战士」怪兽。
function c72332074.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10dc)
end
-- 效果①的发动条件：检查自己场上是否存在3种类以上的「超级量子战士」怪兽。
function c72332074.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上表侧表示的「超级量子战士」怪兽。
	local g=Duel.GetMatchingGroup(c72332074.cfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)>=3
end
-- 效果①的发动准备与合法性检测。
function c72332074.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张可以回到卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查对方额外卡组是否有卡，且对方是否可以进行特殊召唤。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 and Duel.IsPlayerCanSpecialSummon(1-tp) end
	-- 获取对方场上所有可以回到卡组的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息为“将对方场上的卡全部回到持有者卡组”。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 过滤额外卡组中可以无视召唤条件特殊召唤的怪兽。
function c72332074.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果①的处理：将对方场上的卡全部回到卡组，并让对方从额外卡组特殊召唤1只怪兽。
function c72332074.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以回到卡组的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	-- 将对方场上的卡全部送回持有者卡组并洗牌，若成功送回至少1张则继续处理。
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		-- 检查对方场上是否有可用的怪兽区域。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方额外卡组是否存在可以特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c72332074.spfilter,1-tp,LOCATION_EXTRA,0,1,nil,e,1-tp) then
		-- 中断当前效果处理，使后续的特殊召唤不与回到卡组视为同时处理。
		Duel.BreakEffect()
		-- 给对方玩家发送选择特殊召唤怪兽的提示信息。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让对方玩家从其额外卡组选择1只满足条件的怪兽。
		local g=Duel.SelectMatchingCard(1-tp,c72332074.spfilter,1-tp,LOCATION_EXTRA,0,1,1,nil,e,1-tp)
		local tc=g:GetFirst()
		if tc then
			-- 对方将选中的怪兽无视召唤条件以表侧表示特殊召唤到其场上。
			Duel.SpecialSummon(tc,0,1-tp,1-tp,true,false,POS_FACEUP)
		end
	end
end
-- 过滤自己墓地中可以作为发动成本除外的「超级量子妖精 阿尔方」。
function c72332074.costfilter(c)
	return c:IsCode(58753372) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动成本检测与支付。
function c72332074.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在可以除外的「超级量子妖精 阿尔方」。
		and Duel.IsExistingMatchingCard(c72332074.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 给自己玩家发送选择除外卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让自己玩家从墓地选择1只「超级量子妖精 阿尔方」。
	local g=Duel.SelectMatchingCard(tp,c72332074.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡和这张卡表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤卡组中可以发动的「超级量子机舰 炎磁大母舰」。
function c72332074.actfilter(c,tp)
	return c:IsCode(10424147) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 效果②的发动准备与合法性检测。
function c72332074.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以发动的「超级量子机舰 炎磁大母舰」。
	if chk==0 then return Duel.IsExistingMatchingCard(c72332074.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 效果②的处理：从卡组将「超级量子机舰 炎磁大母舰」放置到场上发动。
function c72332074.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张可以发动的「超级量子机舰 炎磁大母舰」。
	local tc=Duel.GetFirstMatchingCard(c72332074.actfilter,tp,LOCATION_DECK,0,nil,tp)
	if tc then
		-- 获取自己场地区域的卡。
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 根据规则将原本存在的场地魔法卡送去墓地。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理。
			Duel.BreakEffect()
		end
		-- 将选中的场地魔法卡移动到自己的场地区域表侧表示发动。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		-- 触发场地魔法卡发动的时点事件。
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end
