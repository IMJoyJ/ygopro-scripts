--ZERO－MAX
-- 效果：
-- 自己手卡是0张的场合，选择自己墓地存在的1只名字带有「永火」的怪兽才能发动。选择的怪兽特殊召唤，持有比特殊召唤的怪兽的攻击力低的攻击力的场上表侧表示存在的怪兽全部破坏。这张卡发动的回合，自己不能进行战斗阶段。
function c30562585.initial_effect(c)
	-- 效果原文内容：自己手卡是0张的场合，选择自己墓地存在的1只名字带有「永火」的怪兽才能发动。选择的怪兽特殊召唤，持有比特殊召唤的怪兽的攻击力低的攻击力的场上表侧表示存在的怪兽全部破坏。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c30562585.condition)
	e1:SetCost(c30562585.cost)
	e1:SetTarget(c30562585.target)
	e1:SetOperation(c30562585.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断自己手卡是否为0张
function c30562585.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己手卡是否为0张
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 效果作用：设置发动时的费用，使自己在发动回合不能进入战斗阶段
function c30562585.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断当前阶段是否不是主要阶段2
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	-- 效果原文内容：自己手卡是0张的场合，选择自己墓地存在的1只名字带有「永火」的怪兽才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将不能进入战斗阶段的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：定义过滤函数，筛选名字带有「永火」且能特殊召唤的怪兽
function c30562585.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置效果目标，判断是否满足特殊召唤条件
function c30562585.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30562585.filter(chkc,e,tp) end
	-- 效果作用：判断自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断自己墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c30562585.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择目标怪兽
	local g=Duel.SelectTarget(tp,c30562585.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	local tc=g:GetFirst()
	-- 效果作用：获取场上攻击力低于特殊召唤怪兽攻击力的怪兽组
	local dg=Duel.GetMatchingGroup(c30562585.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,tc,tc:GetAttack())
	-- 效果作用：设置操作信息，确定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果作用：定义过滤函数，筛选场上表侧表示且攻击力低于指定值的怪兽
function c30562585.dfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
-- 效果作用：处理效果发动后的操作，特殊召唤目标怪兽并破坏符合条件的怪兽
function c30562585.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：判断目标怪兽是否有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 效果作用：中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 效果作用：获取场上攻击力低于特殊召唤怪兽攻击力的怪兽组
		local dg=Duel.GetMatchingGroup(c30562585.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,tc,tc:GetAttack())
		if dg:GetCount()>0 then
			-- 效果作用：将符合条件的怪兽破坏
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
