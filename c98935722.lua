--星遺物に眠る深層
-- 效果：
-- ①：这张卡的发动时，可以以自己墓地1只5星以上的怪兽为对象。那个场合，那只怪兽特殊召唤。这张卡从场上离开时那只怪兽破坏。
-- ②：只要自己场上有「机界骑士」怪兽存在，和那怪兽相同纵列发动的对方怪兽的效果无效化。
function c98935722.initial_effect(c)
	-- ①：这张卡的发动时，可以以自己墓地1只5星以上的怪兽为对象。那个场合，那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c98935722.target)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c98935722.checkop)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c98935722.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：只要自己场上有「机界骑士」怪兽存在，和那怪兽相同纵列发动的对方怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c98935722.discon)
	e4:SetOperation(c98935722.disop)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地等级5以上且可以特殊召唤的怪兽
function c98935722.spfilter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡片发动时的效果处理，若满足条件则可选择是否取墓地怪兽为对象
function c98935722.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c98935722.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 检查自己墓地是否存在满足条件的5星以上怪兽
	if Duel.IsExistingTarget(c98935722.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否选择发动特殊召唤墓地怪兽的效果
		and Duel.SelectYesNo(tp,aux.Stringid(98935722,0)) then  --"是否把墓地怪兽特殊召唤？"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c98935722.activate)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择自己墓地1只5星以上的怪兽作为效果的对象
		local g=Duel.SelectTarget(tp,c98935722.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 设置特殊召唤的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 特殊召唤作为对象的怪兽，并将该怪兽与这张卡建立对象关联
function c98935722.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将对象怪兽以表侧表示特殊召唤（分步处理）
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
-- 在这张卡即将离场前，检查其效果是否被无效，并用Label记录状态
function c98935722.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 这张卡从场上离开时，若未被无效，则破坏作为对象的怪兽
function c98935722.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏作为对象的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤自己场上表侧表示的、且与指定纵列相同的「机界骑士」怪兽
function c98935722.cfilter(c,seq2)
	-- 获取怪兽在主要怪兽区或额外怪兽区的实际纵列序号
	local seq1=aux.MZoneSequence(c:GetSequence())
	return c:IsFaceup() and c:IsSetCard(0x10c) and seq1==4-seq2
end
-- 检查对方怪兽效果发动的纵列是否与自己场上的「机界骑士」怪兽相同
function c98935722.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发效果的连锁发生的位置和位置序号
	local loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	-- 将触发效果的怪兽位置序号转换为标准的纵列序号
	seq=aux.MZoneSequence(seq)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE
		-- 检查自己场上是否存在与该效果发动位置相同纵列的「机界骑士」怪兽
		and Duel.IsExistingMatchingCard(c98935722.cfilter,tp,LOCATION_MZONE,0,1,nil,seq)
end
-- 无效该对方怪兽的效果
function c98935722.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示该卡片效果正在适用（显示卡片动画）
	Duel.Hint(HINT_CARD,0,98935722)
	-- 无效该连锁的效果
	Duel.NegateEffect(ev)
end
