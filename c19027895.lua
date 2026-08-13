--サラマングレイト・リヴァイブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只「转生炎兽」怪兽和自己墓地1只同名怪兽为对象才能发动。那只墓地的怪兽回到卡组，那只自己场上的怪兽的攻击力直到回合结束时上升自身的原本攻击力数值。
local s,id,o=GetID()
-- 定义初始化函数，为卡片注册两个效果：①发动时以自己墓地1只炎属性怪兽为对象特殊召唤；②在墓地除外自身，以场上「转生炎兽」怪兽和墓地同名怪兽为对象，墓地怪兽回卡组，场上怪兽攻击力上升原本攻击力。
function s.initial_effect(c)
	-- ①：以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.stgt)
	e1:SetOperation(s.sop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「转生炎兽」怪兽和自己墓地1只同名怪兽为对象才能发动。那只墓地的怪兽回到卡组，那只自己场上的怪兽的攻击力直到回合结束时上升自身的原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动条件：只能在伤害步骤且伤害计算前发动（不能在伤害计算后发动）。
	e2:SetCondition(aux.dscon)
	-- 设置②效果的发动COST：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 定义①效果对象的过滤条件：选择自己墓地的炎属性怪兽，且该怪兽能被当前效果特殊召唤。
function s.sfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标判定/发动条件检查：若系统传入chkc则验证该对象是否为自己墓地且满足特召条件的炎属性怪兽；否则在chk==0时验证发动条件（是否有空位和可选对象）。
function s.stgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.sfilter(chkc,e,tp) end
	-- 发动条件之一：自己主要怪兽区有空位可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在至少1只满足特召条件的炎属性怪兽可以作为对象。
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只满足条件的炎属性怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：本次效果将进行特殊召唤，对象为选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：若对象仍与效果关联，将其特殊召唤。
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到我的场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果第一个对象的过滤条件：自己场上表侧表示的「转生炎兽」怪兽，原本攻击力大于0，且墓地存在可回卡组的同名怪兽。
function s.atkfilter1(c,e,tp)
	return c:IsSetCard(0x119) and c:IsFaceup() and c:GetBaseAttack()>0
		-- 确认墓地存在1只与该场上怪兽同名的、可以返回卡组的怪兽，作为②效果第二个对象。
		and Duel.IsExistingTarget(s.atkfilter2,tp,LOCATION_GRAVE,0,1,c,c:GetCode())
end
-- 定义②效果第二个对象的过滤条件：墓地中与指定卡码相同的怪兽，且可以返回卡组。
function s.atkfilter2(c,code)
	return c:IsCode(code) and c:IsAbleToDeck()
end
-- ②效果的目标选择：先选择场上1只表侧表示的「转生炎兽」怪兽，再选择墓地1只同名怪兽，并保存场上怪兽为标签对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- ②效果的发动条件：自己场上有满足条件的表侧表示「转生炎兽」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的「转生炎兽」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「转生炎兽」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.atkfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择要返回卡组的墓地同名怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择墓地中与所选场上怪兽同名的1只怪兽作为第二个对象。
	local g2=Duel.SelectTarget(tp,s.atkfilter2,tp,LOCATION_GRAVE,0,1,1,g:GetFirst(),g:GetFirst():GetCode())
	-- 设置连锁处理信息：本次效果包含将墓地怪兽返回卡组的处理。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,1,0,0)
end
-- ②效果处理：先将墓地同名怪兽洗回卡组，若成功，将场上「转生炎兽」怪兽的攻击力上升其原本攻击力数值，直到回合结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 取得②效果发动时选择的所有对象卡（场上怪兽和墓地怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sc=g:GetFirst()
	if sc==tc then sc=g:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and sc:IsRelateToEffect(e)
		-- 将墓地同名怪兽以效果返回卡组并洗牌，确认处理成功后才能执行攻击力上升。
		and Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		local atk=tc:GetBaseAttack()
		-- 那只自己场上的怪兽的攻击力直到回合结束时上升自身的原本攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
