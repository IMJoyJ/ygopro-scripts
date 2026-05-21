--プロモーション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只3星以下的战士族·地属性怪兽为对象才能发动。那只怪兽送去墓地，从卡组把1只4星以上的战士族·地属性怪兽特殊召唤。那之后，原本的种族·属性是战士族·地属性的「人偶」怪兽在自己场上存在的场合，这个效果特殊召唤的怪兽的攻击力·守备力上升对方墓地的卡数量×100。
function c88617904.initial_effect(c)
	-- ①：以自己场上1只3星以下的战士族·地属性怪兽为对象才能发动。那只怪兽送去墓地，从卡组把1只4星以上的战士族·地属性怪兽特殊召唤。那之后，原本的种族·属性是战士族·地属性的「人偶」怪兽在自己场上存在的场合，这个效果特殊召唤的怪兽的攻击力·守备力上升对方墓地的卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,88617904+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c88617904.target)
	e1:SetOperation(c88617904.operation)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的3星以下的地属性·战士族怪兽
function c88617904.tgfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelBelow(3)
		-- 检查卡片是否能送去墓地，且该卡送去墓地后有可用的怪兽区域
		and c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤卡组中4星以上的地属性·战士族怪兽
function c88617904.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与可行性检查
function c88617904.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c88617904.tgfilter(chkc,tp) end
	-- 检查自己场上是否存在符合条件的可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c88617904.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查卡组中是否存在符合特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c88617904.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88617904.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置将对象怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置从卡组特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：将对象怪兽送去墓地，从卡组特殊召唤怪兽，并根据条件上升其攻击力·守备力
function c88617904.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用效果，并将其送去墓地
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 获取卡组中所有符合特殊召唤条件的怪兽
		local g=Duel.GetMatchingGroup(c88617904.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if g:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 将选择的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			-- 检查自己场上是否存在原本种族·属性是战士族·地属性的「人偶」怪兽
			if Duel.IsExistingMatchingCard(c88617904.atkfilter,tp,LOCATION_MZONE,0,1,nil) then
				-- 中断当前效果处理，使后续的攻击力·守备力上升处理不与特殊召唤同时进行
				Duel.BreakEffect()
				-- 计算对方墓地的卡片数量乘以100的数值
				local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)*100
				-- 这个效果特殊召唤的怪兽的攻击力·守备力上升对方墓地的卡数量×100
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(ct)
				sc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				sc:RegisterEffect(e2)
			end
		end
	end
end
-- 过滤原本种族为战士族、原本属性为地属性且卡名含有「人偶」的表侧表示怪兽
function c88617904.atkfilter(c)
	return c:GetOriginalRace()==RACE_WARRIOR and c:GetOriginalAttribute()==ATTRIBUTE_EARTH and c:IsSetCard(0x83) and c:IsFaceup()
end
