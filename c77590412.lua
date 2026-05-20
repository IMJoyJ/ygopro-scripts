--パペット・ルーク
-- 效果：
-- ①：这张卡召唤成功时才能发动。这张卡变成守备表示，从卡组把1只战士族·地属性怪兽送去墓地。
-- ②：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须向这张卡作出攻击。
-- ③：1回合1次，这张卡被选择作为攻击对象时，以自己墓地1只6星以上的战士族·地属性怪兽为对象才能发动。场上的这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，攻击对象转移为那只怪兽。
function c77590412.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。这张卡变成守备表示，从卡组把1只战士族·地属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c77590412.tgtg)
	e1:SetOperation(c77590412.tgop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须向这张卡作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e3:SetValue(c77590412.atklimit)
	c:RegisterEffect(e3)
	-- ③：1回合1次，这张卡被选择作为攻击对象时，以自己墓地1只6星以上的战士族·地属性怪兽为对象才能发动。场上的这张卡送去墓地，作为对象的怪兽特殊召唤。那之后，攻击对象转移为那只怪兽。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(c77590412.cltg)
	e4:SetOperation(c77590412.clop)
	c:RegisterEffect(e4)
end
-- 过滤卡组中满足“战士族·地属性且能送去墓地”条件的卡片
function c77590412.tgfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToGrave()
end
-- 召唤成功时效果的发动准备，检查自身是否为攻击表示以及卡组中是否存在可送去墓地的怪兽
function c77590412.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos()
		-- 检查卡组中是否存在至少1只满足条件的战士族·地属性怪兽
		and Duel.IsExistingMatchingCard(c77590412.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果包含将自身表示形式改变的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
	-- 设置操作信息，表示该效果包含从卡组将1张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 召唤成功时效果的处理：将自身变为守备表示，并从卡组将1只战士族·地属性怪兽送去墓地
function c77590412.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取卡组中所有满足条件的战士族·地属性怪兽
	local g=Duel.GetMatchingGroup(c77590412.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 检查自身是否表侧攻击表示存在且因该效果成功变为表侧守备表示，并且卡组中存在符合条件的怪兽
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE) and #g>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 限制对方怪兽若攻击则必须以这张卡为攻击对象
function c77590412.atklimit(e,c)
	return c==e:GetHandler()
end
-- 过滤墓地中满足“6星以上的战士族·地属性且可以特殊召唤”条件的怪兽
function c77590412.clfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 被选择作为攻击对象时效果的发动准备，检查自身是否能送去墓地、是否有可用怪兽区域以及墓地中是否存在符合条件的对象
function c77590412.cltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c77590412.clfilter(chkc,e,tp) end
	-- 检查自身离开场上后是否有可用的怪兽区域，以及自身是否能送去墓地
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGrave()
		-- 检查自己墓地是否存在至少1只满足条件的6星以上战士族·地属性怪兽
		and Duel.IsExistingTarget(c77590412.clfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c77590412.clfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示该效果包含将自身送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	-- 设置操作信息，表示该效果包含特殊召唤目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 建立攻击怪兽与当前效果的联系，用于后续转移攻击对象时的状态判定
	Duel.GetAttacker():CreateEffectRelation(e)
end
-- 被选择作为攻击对象时效果的处理：将自身送去墓地，特殊召唤墓地的目标怪兽，并将攻击对象转移为该怪兽
function c77590412.clop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查自身是否与效果相关，并成功将自身送去墓地，且目标怪兽仍与效果相关
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e)
		-- 将作为对象的怪兽在自己场上表侧表示特殊召唤
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取当前进行攻击的怪兽
		local a=Duel.GetAttacker()
		if a:IsAttackable() and a:IsRelateToEffect(e) and not a:IsImmuneToEffect(e) then
			-- 中断当前效果处理，使后续的转移攻击对象处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 将对方怪兽的攻击对象转移为特殊召唤的那只怪兽
			Duel.ChangeAttackTarget(tc)
		end
	end
end
