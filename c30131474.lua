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
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有「枪管」连接怪兽存在的场合，自己·对方的准备阶段以自己墓地1只「弹丸」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
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
-- 判断怪兽是否满足：表侧表示且属于「枪管」系列且为连接怪兽，用于检查自己场上是否存在符合条件的「枪管」连接怪兽。
function c30131474.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10f) and c:IsType(TYPE_LINK)
end
-- ①效果的发动条件：自己场上存在至少1只表侧表示的「枪管」连接怪兽。
function c30131474.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足cfilter条件的「枪管」连接怪兽。
	return Duel.IsExistingMatchingCard(c30131474.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤自己墓地中属于「弹丸」系列且能够被当前效果特殊召唤的怪兽。
function c30131474.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标选择处理：若指定对象则确认其位置和合法性；发动时确认自己场上有空位且墓地存在可特殊召唤的「弹丸」怪兽作为对象。
function c30131474.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30131474.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己主要怪兽区域有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在能够成为对象的「弹丸」怪兽。
		and Duel.IsExistingTarget(c30131474.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的「弹丸」怪兽中选择1只作为效果对象，并设为当前连锁的目标。
	local g=Duel.SelectTarget(tp,c30131474.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，标记本次效果涉及特殊召唤及目标卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽特殊召唤，并为其注册在结束阶段破坏的持续效果。
function c30131474.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区域仍有空位，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联后，以表侧表示特殊召唤该怪兽（逐步特殊召唤以便附加后续破坏效果）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(30131474,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c30131474.descon)
		e1:SetOperation(c30131474.desop)
		-- 将结束阶段破坏效果的持续效果注册到场上，使其在该怪兽所在玩家的结束阶段时生效。
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成所有逐步特殊召唤，确认特殊召唤成功。
	Duel.SpecialSummonComplete()
end
-- 结束阶段破坏的效果条件：核对被特殊召唤的怪兽是否仍是本效果特殊召唤的那只，若已不是则取消破坏。
function c30131474.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(30131474)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段时，执行对标记怪兽的破坏处理。
function c30131474.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏之前特殊召唤的怪兽。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
