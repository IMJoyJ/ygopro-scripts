--メタファイズ・ディメンション
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方对怪兽的特殊召唤成功的场合，以除外的1只自己的「玄化」怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
-- ②：这张卡已在魔法与陷阱区域存在的状态，这张卡以外的自己的「玄化」卡被除外的场合，以对方场上1张卡为对象才能发动。那张卡除外。
function c52714670.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方对怪兽的特殊召唤成功的场合，以除外的1只自己的「玄化」怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52714670,1))  --"发动并使用①效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,52714670)
	e2:SetCondition(c52714670.spcon)
	e2:SetTarget(c52714670.sptg)
	e2:SetOperation(c52714670.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡已在魔法与陷阱区域存在的状态，这张卡以外的自己的「玄化」卡被除外的场合，以对方场上1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52714670,2))  --"除外对方的卡"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,52714671)
	e4:SetCondition(c52714670.rmcon)
	e4:SetTarget(c52714670.rmtg)
	e4:SetOperation(c52714670.rmop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断该怪兽是否由玩家tp特殊召唤成功，用于检测特殊召唤成功的怪兽是否由对方玩家进行的特殊召唤。
function c52714670.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- ①效果的发动条件：本次特殊召唤成功的怪兽中存在至少1只由对方玩家（1-tp）特殊召唤的怪兽。
function c52714670.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52714670.cfilter,1,nil,1-tp)
end
-- 筛选可作为对象特殊召唤的自己的「玄化」怪兽：表侧表示、卡名属于0x105「玄化」字段，且能被玩家tp用该效果特殊召唤（满足召唤条件与苏生限制）。
function c52714670.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x105) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标选择与合法性判定：确认对象位于除外区、属于自己且符合特殊召唤条件；发动时还需自己主要怪兽区有空位，并且除外区存在至少1只符合条件的「玄化」怪兽。
function c52714670.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c52714670.spfilter(chkc,e,tp) end
	-- ①效果的发动条件之一：自己场上必须存在可用于特殊召唤的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ①效果的发动条件之二：除外区存在至少1只满足条件的自己的「玄化」怪兽可作为对象。
		and Duel.IsExistingTarget(c52714670.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家发送选择提示消息，提示其选择要特殊召唤的卡（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的除外区选择1只符合条件的「玄化」怪兽作为效果对象，并设为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c52714670.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 登记操作信息：该效果处理时将把对象g（1张）特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：把对象怪兽特殊召唤；成功后为该怪兽打上标记，并注册一个持续效果，在下个回合的结束阶段将其除外。
function c52714670.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果选择的对象卡（即要特殊召唤的「玄化」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与本效果关联后，将其表侧表示特殊召唤到自己场上；若特殊召唤成功则继续执行后续的除外效果设置。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:RegisterFlagEffect(52714670,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 将该延迟除外效果要执行的结束阶段回合数记录为下一个回合（当前回合数+1）。
		e2:SetLabel(Duel.GetTurnCount()+1)
		e2:SetLabelObject(tc)
		e2:SetCondition(c52714670.ermcon)
		e2:SetOperation(c52714670.ermop)
		-- 把该延迟除外效果注册到游戏中（归属当前玩家tp），使其在后续结束阶段时检查并执行。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 延迟除外效果的触发条件：特殊召唤的怪兽仍带有标记，并且当前回合已到达设定的下个回合结束阶段；若怪兽已无标记则效果自动重置。
function c52714670.ermcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(52714670)~=0 then
		-- 判断当前回合数是否等于预先记录的下个回合（即结束阶段是否到来）。
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 延迟除外效果的处理：将该怪兽以表侧表示除外（原因：效果）。
function c52714670.ermop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将指定怪兽以表侧表示除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 筛选条件：被除外的卡是表侧表示的自己的「玄化」卡，且被除外前也由自己控制（即自己的「玄化」卡被除外）。
function c52714670.rmcfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x105) and c:IsPreviousControler(tp)
end
-- ②效果的发动条件：本次除外事件中存在至少1张除自身以外的自己的「玄化」卡被除外，且此卡效果处于有效状态。
function c52714670.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52714670.rmcfilter,1,e:GetHandler(),tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- ②效果的目标选择与合法性判定：选择对方场上1张可以被除外的卡作为对象；发动时需对方场上有可除外的卡。
function c52714670.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- ②效果的发动条件：对方场上存在至少1张可以被除外的卡作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择提示消息，提示其选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上的1张可以除外的卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：该效果处理时将把对象g（1张）除外（CATEGORY_REMOVE）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果处理：确认对象卡仍与本效果关联后，将其表侧表示除外。
function c52714670.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果选择的对象卡（对方场上的那张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
