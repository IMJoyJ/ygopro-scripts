--サラマングレイト・リヴァイブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只炎属性怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只「转生炎兽」怪兽和自己墓地1只同名怪兽为对象才能发动。那只墓地的怪兽回到卡组，那只自己场上的怪兽的攻击力直到回合结束时上升自身的原本攻击力数值。
local s,id,o=GetID()
-- 注册两个效果，分别对应①和②效果
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
	-- 限制效果只能在伤害计算前发动
	e2:SetCondition(aux.dscon)
	-- 支付将此卡除外的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的墓地炎属性怪兽
function s.sfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置①效果的发动条件和目标选择
function s.stgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.sfilter(chkc,e,tp) end
	-- 判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行①效果的处理
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选场上符合条件的转生炎兽怪兽
function s.atkfilter1(c,e,tp)
	return c:IsSetCard(0x119) and c:IsFaceup() and c:GetBaseAttack()>0
		-- 判断墓地是否存在同名怪兽
		and Duel.IsExistingTarget(s.atkfilter2,tp,LOCATION_GRAVE,0,1,c,c:GetCode())
end
-- 筛选墓地同名怪兽
function s.atkfilter2(c,code)
	return c:IsCode(code) and c:IsAbleToDeck()
end
-- 设置②效果的发动条件和目标选择
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断场上是否存在符合条件的转生炎兽怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的转生炎兽怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上转生炎兽怪兽
	local g=Duel.SelectTarget(tp,s.atkfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择墓地同名怪兽
	local g2=Duel.SelectTarget(tp,s.atkfilter2,tp,LOCATION_GRAVE,0,1,1,g:GetFirst(),g:GetFirst():GetCode())
	-- 设置操作信息，表示将怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,1,0,0)
end
-- 执行②效果的处理
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取连锁中的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sc=g:GetFirst()
	if sc==tc then sc=g:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and sc:IsRelateToEffect(e)
		-- 将目标怪兽送回卡组
		and Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		local atk=tc:GetBaseAttack()
		-- 使场上怪兽的攻击力上升其原本攻击力数值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
