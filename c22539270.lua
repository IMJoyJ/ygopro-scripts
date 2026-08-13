--スクラップ・オイルゾーン
-- 效果：
-- 选择自己墓地存在的1只名字带有「废铁」的怪兽发动。选择的怪兽从墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这张卡不在场上存在时，那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。这张卡发动的回合，自己不能进行战斗阶段。
function c22539270.initial_effect(c)
	-- 选择自己墓地存在的1只名字带有「废铁」的怪兽发动。选择的怪兽从墓地特殊召唤。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c22539270.cost)
	e1:SetTarget(c22539270.target)
	e1:SetOperation(c22539270.operation)
	c:RegisterEffect(e1)
	-- 这张卡不在场上存在时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c22539270.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c22539270.descon2)
	e3:SetOperation(c22539270.desop2)
	c:RegisterEffect(e3)
	-- 这个效果特殊召唤的怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
	-- 这个效果特殊召唤的怪兽的效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_DISABLE_EFFECT)
	e5:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e5)
end
-- 发动时的代价处理：仅在主要阶段1可发动，发动后为发动者附加本回合不能进入战斗阶段的誓约效果。
function c22539270.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：当前阶段必须是主要阶段1，否则不能发动。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 选择自己墓地存在的1只名字带有「废铁」的怪兽发动。选择的怪兽从墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这张卡不在场上存在时，那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能进入战斗阶段的誓约效果注册到玩家tp身上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：怪兽属于废铁系列（0x24），且能够被tp玩家以表侧表示特殊召唤（满足苏生限制等召唤条件）。
function c22539270.filter(c,e,tp)
	return c:IsSetCard(0x24) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择对象的处理：检查己方主怪兽区有空位，且墓地存在至少1只满足条件的废铁怪兽；存在时进入选择对象步骤。
function c22539270.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22539270.filter(chkc,e,tp) end
	-- 合法条件：己方主怪兽区必须存在可用的空格，否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 合法条件：自己墓地存在至少1只满足filter条件的废铁怪兽，且它能成为此效果对象。
		and Duel.IsExistingTarget(c22539270.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的废铁怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c22539270.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果包含特殊召唤，对象为g，数量为1，用于后续连锁判断（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：在对象怪兽仍与效果关联时，将其以表侧表示特殊召唤到己方场上；成功后让这张卡与那只怪兽建立永续对象关系，以便后续无效化与破坏联动。
function c22539270.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联且满足特殊召唤条件后，将对象特殊召唤（作为连锁处理中的一只怪兽）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
		-- 完成特殊召唤手续，触发召唤成功的时点。
		Duel.SpecialSummonComplete()
	end
end
-- 这张卡离场时，若其永续对象怪兽仍在场上，则将该对象怪兽破坏。
function c22539270.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果方式破坏对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 条件判断：这张卡的永续对象怪兽从场上离开时，满足条件。
function c22539270.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 当条件满足时，将这张卡自身破坏。
function c22539270.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果方式破坏这张卡自身。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
