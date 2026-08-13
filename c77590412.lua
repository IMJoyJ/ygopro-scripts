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
-- 定义送去墓地效果的过滤器：战士族·地属性且可以被送去墓地的卡
function c77590412.tgfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToGrave()
end
-- 发动条件判定：这张卡是攻击表示且卡组存在满足条件的可送去墓地的怪兽
function c77590412.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos()
		-- 检查自己卡组是否存在至少1只满足过滤条件（战士族·地属性）的怪兽
		and Duel.IsExistingMatchingCard(c77590412.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣言将这张卡的表示形式变更为守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
	-- 设置操作信息：宣言从卡组把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：这张卡变成表侧守备表示后，从自己卡组选1只战士族·地属性怪兽送去墓地
function c77590412.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从自己卡组检索全部满足条件的战士族·地属性怪兽
	local g=Duel.GetMatchingGroup(c77590412.tgfilter,tp,LOCATION_DECK,0,nil)
	-- 确认这张卡表侧攻击表示且与效果关联，将其变成表侧守备表示，并确认卡组有可送去墓地的怪兽
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)>0 and #g>0 then
		-- 向玩家提示「请选择要送去墓地的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 把选中的怪兽以效果原因送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 攻击限制过滤器：只有这张卡本身才能作为攻击对象（对方怪兽必须攻击这张卡）
function c77590412.atklimit(e,c)
	return c==e:GetHandler()
end
-- 定义特殊召唤对象的过滤器：自己墓地6星以上的战士族·地属性且可以特殊召唤的怪兽
function c77590412.clfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象效果的发动条件与对象检查：这张卡离场后有可用怪兽区、这张卡能送去墓地，且自己墓地存在满足条件的对象怪兽
function c77590412.cltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c77590412.clfilter(chkc,e,tp) end
	-- 发动条件判定：这张卡离场后自己场上还有可用怪兽区，且这张卡能被送去墓地
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToGrave()
		-- 检查自己墓地是否存在至少1只满足条件且能成为对象的6星以上战士族·地属性怪兽
		and Duel.IsExistingTarget(c77590412.clfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地1只满足条件的6星以上战士族·地属性怪兽为对象
	local g=Duel.SelectTarget(tp,c77590412.clfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：宣言把场上的这张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,0,0)
	-- 设置操作信息：宣言将作为对象的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 让攻击怪兽与此效果建立关联，以便后续转移攻击对象时确认其状态
	Duel.GetAttacker():CreateEffectRelation(e)
end
-- 效果处理：把场上的这张卡送去墓地，将作为对象的怪兽特殊召唤，那之后把攻击对象转移为那只怪兽
function c77590412.clop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡（要特殊召唤的墓地怪兽）
	local tc=Duel.GetFirstTarget()
	-- 确认这张卡与效果关联，将其送去墓地且确实在墓地，同时对象怪兽仍与效果关联
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e)
		-- 将作为对象的怪兽以表侧表示特殊召唤到自己场上，并确认特殊召唤成功
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 取得此次进行攻击的怪兽
		local a=Duel.GetAttacker()
		if a:IsAttackable() and a:IsRelateToEffect(e) and not a:IsImmuneToEffect(e) then
			-- 中断效果处理，使攻击对象的转移与前面的处理视为不同时处理
			Duel.BreakEffect()
			-- 把攻击对象转移为那只特殊召唤的怪兽
			Duel.ChangeAttackTarget(tc)
		end
	end
end
