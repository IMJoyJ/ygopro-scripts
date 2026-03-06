--ガガガマンサー
-- 效果：
-- ①：1回合1次，以「我我我术士」以外的自己墓地1只「我我我」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「我我我」怪兽不能特殊召唤。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
function c28884172.initial_effect(c)
	-- ①：1回合1次，以「我我我术士」以外的自己墓地1只「我我我」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是「我我我」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28884172,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c28884172.sptg)
	e1:SetOperation(c28884172.spop)
	c:RegisterEffect(e1)
	-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，以自己场上1只超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28884172,1))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c28884172.atkcon)
	e2:SetTarget(c28884172.atktg)
	e2:SetOperation(c28884172.atkop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的墓地「我我我」怪兽（排除自己）
function c28884172.spfilter(c,e,tp)
	return c:IsSetCard(0x54) and not c:IsCode(28884172) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件（包括场上是否有空位和墓地是否有符合条件的怪兽）
function c28884172.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c28884172.spfilter(chkc,e,tp) end
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否有符合条件的怪兽
		and Duel.IsExistingTarget(c28884172.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c28884172.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，并设置不能特殊召唤的效果
function c28884172.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 设置不能特殊召唤的效果，限制玩家不能特殊召唤非「我我我」怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c28884172.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤的限制条件（非「我我我」怪兽不能特殊召唤）
function c28884172.splimit(e,c)
	return not c:IsSetCard(0x54)
end
-- 判断是否满足效果发动条件（超量素材被取除送去墓地且为超量怪兽效果发动）
function c28884172.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 判断目标是否为表侧表示的超量怪兽
function c28884172.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 判断是否满足攻击力上升的条件（场上存在表侧表示的超量怪兽）
function c28884172.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28884172.atkfilter(chkc) end
	-- 判断场上是否存在表侧表示的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c28884172.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标超量怪兽
	Duel.SelectTarget(tp,c28884172.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行攻击力上升效果
function c28884172.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给目标超量怪兽的攻击力加上500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
