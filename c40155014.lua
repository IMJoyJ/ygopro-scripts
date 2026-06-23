--騎士魔防陣
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以场上1张表侧表示的怪兽卡为对象才能发动。那张卡除外。下个回合的准备阶段，这个效果除外的怪兽在持有者场上特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只「百夫长骑士」同调怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力下降1500。
local s,id,o=GetID()
-- 创建两个效果，分别对应卡片效果①和②
function s.initial_effect(c)
	-- 效果①：以场上1张表侧表示的怪兽卡为对象才能发动。那张卡除外。下个回合的准备阶段，这个效果除外的怪兽在持有者场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果②：把墓地的这张卡除外，以自己墓地1只「百夫长骑士」同调怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力下降1500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	-- 效果②的发动需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：对象怪兽必须表侧表示、类型为怪兽、可以除外
function s.filter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0 and c:IsAbleToRemove()
end
-- 处理效果①的发动，选择对象怪兽并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	-- 检查是否满足效果①的发动条件，即场上是否存在可除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一张可除外的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理效果①的发动效果，将对象怪兽除外并注册后续特殊召唤效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍然在场上且成功除外
	if not tc:IsRelateToEffect(e) or Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)<1
		or not tc:IsLocation(LOCATION_REMOVED) then return end
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	-- 注册一个在下个准备阶段触发的持续效果，用于将除外的怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	-- 记录当前回合数用于后续判断
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetLabelObject(tc)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
	-- 将注册的持续效果加入游戏环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否到了下个准备阶段并满足特殊召唤条件
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 判断当前回合数是否等于记录的回合数+1且对象怪兽仍处于除外状态
	return Duel.GetTurnCount()==e:GetLabel()+1 and tc:GetFlagEffect(id)>0
end
-- 执行特殊召唤操作，将对象怪兽在持有者场上特殊召唤
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将对象怪兽特殊召唤到场上
	Duel.SpecialSummon(tc,0,tp,tc:GetOwner(),false,false,POS_FACEUP)
end
-- 过滤条件：对象怪兽必须为「百夫长骑士」同调怪兽、可以特殊召唤
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果②的发动，选择对象怪兽并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp) end
	-- 检查是否满足效果②的发动条件，即墓地是否存在符合条件的怪兽且场上存在召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在符合条件的怪兽
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地一张符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果②的发动效果，将对象怪兽特殊召唤并降低其攻击力
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍然在墓地且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 创建一个使对象怪兽攻击力下降1500的效果并注册到对象怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-1500)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
