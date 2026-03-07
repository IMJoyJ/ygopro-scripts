--ヴァレル・サプライヤー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有「枪管」连接怪兽存在的场合，自己·对方的准备阶段以自己墓地1只「弹丸」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c30131474.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：自己场上有「枪管」连接怪兽存在的场合，自己·对方的准备阶段以自己墓地1只「弹丸」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30131474,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,30131474)
	e2:SetCondition(c30131474.spcon)
	e2:SetTarget(c30131474.sptg)
	e2:SetOperation(c30131474.spop)
	c:RegisterEffect(e2)
end
-- 效果作用：检查场上是否存在「枪管」连接怪兽
function c30131474.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10f) and c:IsType(TYPE_LINK)
end
-- 效果作用：判断准备阶段是否满足发动条件
function c30131474.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否存在「枪管」连接怪兽
	return Duel.IsExistingMatchingCard(c30131474.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：过滤满足条件的「弹丸」怪兽
function c30131474.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置选择目标的过滤条件
function c30131474.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30131474.spfilter(chkc,e,tp) end
	-- 效果作用：判断是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断墓地是否存在满足条件的「弹丸」怪兽
		and Duel.IsExistingTarget(c30131474.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择目标怪兽
	local g=Duel.SelectTarget(tp,c30131474.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：处理特殊召唤及后续破坏效果
function c30131474.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 效果作用：获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：判断目标怪兽是否有效并进行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(30131474,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 效果原文内容：这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c30131474.descon)
		e1:SetOperation(c30131474.desop)
		-- 效果作用：注册结束阶段破坏效果
		Duel.RegisterEffect(e1,tp)
	end
	-- 效果作用：完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 效果作用：判断是否为同一场上的特殊召唤怪兽
function c30131474.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(30131474)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 效果作用：将怪兽破坏
function c30131474.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：以效果原因破坏怪兽
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
