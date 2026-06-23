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
-- 过滤函数，用于筛选满足条件的「元素英雄」通常怪兽（可加入手牌）
function c37412656.filter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- 过滤函数，用于筛选攻击力不超过指定值的对方场上怪兽
function c37412656.dfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 效果处理时点，设置效果目标为己方墓地的「元素英雄」通常怪兽
function c37412656.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37412656.filter(chkc) end
	-- 检查是否满足发动条件：己方墓地存在符合条件的「元素英雄」通常怪兽
	if chk==0 then return Duel.IsExistingTarget(c37412656.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1只「元素英雄」通常怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c37412656.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	local tc=g:GetFirst()
	-- 获取满足条件的对方场上怪兽组（攻击力不超过加入手牌怪兽的攻击力）
	local dg=Duel.GetMatchingGroup(c37412656.dfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
	if dg:GetCount()>0 then
		-- 设置操作信息：若存在符合条件的对方怪兽，则将其破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	end
end
-- 效果发动时处理，将目标怪兽加入手牌，并选择破坏对方场上符合条件的怪兽
function c37412656.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且成功加入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择攻击力不超过目标怪兽攻击力的对方场上1只怪兽
		local dg=Duel.SelectMatchingCard(tp,c37412656.dfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
		if dg:GetCount()>0 then
			-- 中断当前效果处理，使后续破坏效果视为不同时处理
			Duel.BreakEffect()
			-- 以效果原因破坏选中的对方怪兽
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
