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
-- 过滤卡组中可以送去墓地的战士族·地属性怪兽
function c77590412.tgfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToGrave()
end
-- 表示形式变更及送墓效果的发动条件检测
function c77590412.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos()
		-- 并且检查卡组中是否存在满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c77590412.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的分类为将此卡改变表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
	-- 设置效果处理的分类为从卡组将1只怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 表示形式变更及送墓效果处理，此卡变为守备表示且成功时，将卡组中1只战士族·地属性怪兽送去墓地
function c77590412.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取卡组中所有满足条件的战士族·地属性怪兽
	local g=Duel.GetMatchingGroup(c77590412.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 若此卡表侧且攻击表示存在，且与效果相关，改变其表示形式为表侧守备表示成功
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)>0 and #g>0 then
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 判断必须攻击的对象是否为此卡
function c77590412.atklimit(e,c)
	return c==e:GetHandler()
end
-- 过滤墓地中可以特殊召唤的6星以上的战士族·地属性怪兽
function c77590412.clfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特召墓地怪兽并转移攻击对象效果的发动条件检测与靶向选择对象
function c77590412.cltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c77590412.clfilter(chkc,e,tp) end
	-- 若为检测阶段，则判断此卡离开后可用怪兽区数量是否大于0且此卡是否能送去墓地
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGrave()
		-- 并且检查墓地中是否存在满足特殊召唤条件的6星以上战士族·地属性怪兽
		and Duel.IsExistingTarget(c77590412.clfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77590412.clfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理的分类为将此卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	-- 设置效果处理的分类为将目标怪兽特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 使攻击怪兽与此效果建立联系以配合后续的攻击转移
	Duel.GetAttacker():CreateEffectRelation(e)
end
-- 特召墓地怪兽并转移攻击对象效果处理，将此卡送去墓地，并特殊召唤选中的墓地怪兽，最后将攻击对象转移为该特召怪兽
function c77590412.clop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象中用于特殊召唤的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若此卡成功送去墓地，且效果对象怪兽与此效果的关联依然有效
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e)
		-- 并且该效果对象怪兽特殊召唤成功
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取此次战斗中发起攻击的怪兽
		local a=Duel.GetAttacker()
		if a:IsAttackable() and a:IsRelateToEffect(e) and not a:IsImmuneToEffect(e) then
			-- 中断当前效果处理，使后续的转移攻击对象步骤与特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 将攻击怪兽的攻击对象转移为刚特殊召唤的怪兽
			Duel.ChangeAttackTarget(tc)
		end
	end
end
