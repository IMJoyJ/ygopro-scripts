--灰滅の劫火
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「灰灭之都 奥布西地暮」在自己或对方的场地区域表侧表示放置。
-- ②：以对方场上1张表侧表示卡和自己墓地1只8星以上的炎族·暗属性怪兽为对象才能发动。作为对象的场上的卡送去墓地，作为对象的墓地的怪兽在对方场上守备表示特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（卡片发动时的效果处理）和②效果（场地区域的起动效果）。
function s.initial_effect(c)
	-- 将「灰灭之都 奥布西地暮」（卡号3055018）加入此卡的关联卡片密码列表中。
	aux.AddCodeList(c,3055018)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「灰灭之都 奥布西地暮」在自己或对方的场地区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：以对方场上1张表侧表示卡和自己墓地1只8星以上的炎族·暗属性怪兽为对象才能发动。作为对象的场上的卡送去墓地，作为对象的墓地的怪兽在对方场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「灰灭之都 奥布西地暮」的条件：卡名正确、未被禁止且能在自己或对方场上唯一存在。
function s.stfilter(c,tp)
	return c:IsCode(3055018) and not c:IsForbidden() and (c:CheckUniqueOnField(tp) or c:CheckUniqueOnField(1-tp))
end
-- ①效果（卡片发动时的效果处理）的执行函数：可选择将卡组的「灰灭之都 奥布西地暮」放置在自己或对方的场地区域。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足放置条件的「灰灭之都 奥布西地暮」。
	local g=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_DECK,0,nil,tp)
	-- 若卡组中存在符合条件的卡，则询问玩家是否选择发动该效果进行放置。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把「灰灭之都 奥布西地暮」放置？"
		-- 向玩家发送提示信息，要求选择要放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 让玩家从卡组选择1张符合条件的「灰灭之都 奥布西地暮」。
		local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then
			local p=0
			-- 判断该卡是否只能在自己场上放置，或者在双方场上都能放置时由玩家选择是否在自己场上放置。
			if tc:CheckUniqueOnField(tp) and (not tc:CheckUniqueOnField(1-tp) or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then  --"是否在自己场上放置？"
				p=tp
			else
				p=1-tp
			end
			-- 获取目标玩家场地区域（序号5）已存在的场地魔法卡。
			local fc=Duel.GetFieldCard(p,LOCATION_SZONE,5)
			if fc then
				-- 因规则原因将原本存在的场地魔法卡送去墓地。
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果处理，使后续的放置动作与送墓不视为同时处理。
				Duel.BreakEffect()
			end
			-- 将选择的「灰灭之都 奥布西地暮」在目标玩家的场地区域表侧表示放置，并适用其效果。
			Duel.MoveToField(tc,tp,p,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end
-- 过滤对方场上可送去墓地的表侧表示卡，且该卡送墓后对方场上必须有可用的怪兽区域。
function s.tgfilter(c,tp)
	-- 判定卡片是否为表侧表示、能否送去墓地，且该卡离开场上后对方场上是否有空余的怪兽区域用于特殊召唤。
	return c:IsFaceup() and c:IsAbleToGrave() and Duel.GetMZoneCount(1-tp,c,tp,LOCATION_REASON_TOFIELD)>0
end
-- 过滤自己墓地中满足条件的怪兽：8星以上的炎族·暗属性怪兽，且能以守备表示特殊召唤到对方场上。
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_PYRO) and c:IsLevelAbove(8)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- ②效果的靶向与发动准备函数：检测并选择对方场上1张表侧表示卡和自己墓地1只符合条件的怪兽作为对象，并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 判定对方场上是否存在符合送墓条件的表侧表示卡。
		return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil,tp)
			-- 判定自己墓地中是否存在符合特殊召唤条件的8星以上炎族·暗属性怪兽。
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 向玩家发送提示信息，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择对方场上1张表侧表示卡作为效果对象。
	local g1=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只符合条件的怪兽作为效果对象。
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：将选中的1张场上的卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
	-- 设置连锁操作信息：将选中的1只墓地的怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
-- ②效果的执行函数：将作为对象的场上的卡送去墓地，若成功送墓，则将作为对象的墓地怪兽在对方场上守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联的对象卡片集合。
	local tg=Duel.GetTargetsRelateToChain()
	local tc1=tg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD):GetFirst()
	local tc2=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	-- 判定场上的对象卡是否存在，并将其因效果送去墓地，确认其已成功进入墓地。
	if tc1 and Duel.SendtoGrave(tc1,REASON_EFFECT)>0 and tc1:IsLocation(LOCATION_GRAVE)
		-- 判定墓地的对象怪兽是否存在，且不受「王家之谷」等墓地干涉效果的影响。
		and tc2 and aux.NecroValleyFilter()(tc2) then
		-- 将作为对象的墓地怪兽在对方场上以表侧守备表示特殊召唤。
		Duel.SpecialSummon(tc2,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
