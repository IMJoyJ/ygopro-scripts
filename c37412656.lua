--ヒーロー・ブラスト
-- 效果：
-- ①：以自己墓地1只「元素英雄」通常怪兽为对象才能发动。那只怪兽加入手卡。那之后，选持有加入手卡的怪兽的攻击力以下的攻击力的对方场上1只怪兽破坏。
function c37412656.initial_effect(c)
	-- ①：以自己墓地1只「元素英雄」通常怪兽为对象才能发动。那只怪兽加入手卡。那之后，选持有加入手卡的怪兽的攻击力以下的攻击力的对方场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c37412656.target)
	e1:SetOperation(c37412656.activate)
	c:RegisterEffect(e1)
end
-- 检查卡片是否为「元素英雄」通常怪兽且能够加入手卡，用于筛选自己墓地中可作为对象的卡。
function c37412656.filter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 检查对方场上的怪兽是否为表侧表示且攻击力不高于指定攻击力（即被加入手卡的怪兽的攻击力），用于筛选后续可破坏的怪兽。
function c37412656.dfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 效果发动时的目标选择与操作信息登记：从自己墓地选择1只「元素英雄」通常怪兽为对象，并登记回手牌与破坏的操作信息；同时预检索对方场上符合条件的表侧怪兽，若存在则登记破坏信息。
function c37412656.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37412656.filter(chkc) end
	-- 发动条件检查：确认自己墓地是否存在至少1只满足条件的「元素英雄」通常怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c37412656.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择卡片提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足条件的「元素英雄」通常怪兽，并将其设为效果处理时的对象。
	local g=Duel.SelectTarget(tp,c37412656.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记回手牌的操作信息：将选定的对象怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	local tc=g:GetFirst()
	-- 检索对方场上所有表侧表示且攻击力在被选择怪兽当前攻击力以下的怪兽，作为可能被破坏的目标集合。
	local dg=Duel.GetMatchingGroup(c37412656.dfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
	if dg:GetCount()>0 then
		-- 若存在符合条件的对方怪兽，登记破坏的操作信息，预定破坏数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	end
end
-- 效果处理时的操作：先确认对象怪兽仍与效果关联并加入手牌；若成功加入手牌，则选择对方场上1只攻击力在加入手牌怪兽攻击力以下的表侧表示怪兽破坏。
function c37412656.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择墓地对象的怪兽卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果关联，并尝试将其加入手牌；若成功加入手牌（返回值非0），继续执行后续破坏处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 弹出选择卡片提示，提示玩家选择要破坏的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从对方场上选择1只攻击力在已加入手牌怪兽攻击力以下的表侧表示怪兽作为破坏对象。
		local dg=Duel.SelectMatchingCard(tp,c37412656.dfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
		if dg:GetCount()>0 then
			-- 中断当前效果处理，使后续的破坏处理视为不同时进行的独立效果处理，避免错误的时点触发。
			Duel.BreakEffect()
			-- 以效果原因破坏所选择的对方场上怪兽。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
