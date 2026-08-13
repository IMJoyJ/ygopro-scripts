--ZERO－MAX
-- 效果：
-- 自己手卡是0张的场合，选择自己墓地存在的1只名字带有「永火」的怪兽才能发动。选择的怪兽特殊召唤，持有比特殊召唤的怪兽的攻击力低的攻击力的场上表侧表示存在的怪兽全部破坏。这张卡发动的回合，自己不能进行战斗阶段。
function c30562585.initial_effect(c)
	-- 对应效果原文：‘自己手卡是0张的场合，选择自己墓地存在的1只名字带有「永火」的怪兽才能发动。选择的怪兽特殊召唤，持有比特殊召唤的怪兽的攻击力低的攻击力的场上表侧表示存在的怪兽全部破坏。这张卡发动的回合，自己不能进行战斗阶段。’
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
-- 定义效果发动条件函数：自己手牌必须为0张时才允许发动。
function c30562585.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手牌（LOCATION_HAND）数量是否为0，作为发动条件的判定结果。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 定义发动代价：当前阶段不能是主要阶段2；发动后给自己附加‘本回合不能进入战斗阶段’的誓约效果。
function c30562585.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：若当前阶段是主要阶段2则不能发动（因为发动后不能再进入战斗阶段）。
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	-- 对应效果原文：‘选择自己墓地存在的1只名字带有「永火」的怪兽才能发动。选择的怪兽特殊召唤，持有比特殊召唤的怪兽的攻击力低的攻击力的场上表侧表示存在的怪兽全部破坏。这张卡发动的回合，自己不能进行战斗阶段。’
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘不能进入战斗阶段’的永续效果注册给当前玩家tp，使其本回合生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义可选怪兽的过滤条件：必须是名字带有「永火」（0xb）且满足特殊召唤条件的怪兽。
function c30562585.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动时的目标选择：检查我方主要怪兽区有空位，且墓地存在符合条件的「永火」怪兽可选择。
function c30562585.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30562585.filter(chkc,e,tp) end
	-- 发动合法性检测：我方主要怪兽区必须有可用空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检测墓地是否存在1只以上满足「永火」且可特殊召唤的怪兽作为对象。
		and Duel.IsExistingTarget(c30562585.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足filter的「永火」怪兽作为效果对象，并登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c30562585.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果包含特殊召唤，将选中的怪兽作为特殊召唤对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	local tc=g:GetFirst()
	-- 以选中的怪兽的攻击力为基准，检索场上所有表侧表示且攻击力低于该攻击力的怪兽，作为拟破坏对象。
	local dg=Duel.GetMatchingGroup(c30562585.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,tc,tc:GetAttack())
	-- 设置操作信息：本效果包含破坏，将上述符合条件的怪兽组作为破坏对象，数量为其总数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 定义破坏对象的过滤条件：怪兽必须是表侧表示且攻击力低于指定攻击力（特殊召唤怪兽的攻击力）。
function c30562585.dfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk
end
-- 定义效果处理：将选中的墓地「永火」怪兽特殊召唤；若特殊召唤成功，则破坏场上所有表侧表示且攻击力低于该怪兽攻击力的怪兽。
function c30562585.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽（墓地那只「永火」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联且能成功以表侧表示特殊召唤；只有特殊召唤成功才继续处理破坏。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使后续破坏与特殊召唤视为不同时处理，避免错时点。
		Duel.BreakEffect()
		-- 特殊召唤成功后，重新以该怪兽当前攻击力为基准，检索场上所有表侧表示且攻击力低于该攻击力的怪兽作为破坏对象。
		local dg=Duel.GetMatchingGroup(c30562585.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,tc,tc:GetAttack())
		if dg:GetCount()>0 then
			-- 以效果破坏这些符合条件的怪兽。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
