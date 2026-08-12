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
	-- ①：对方对怪兽的特殊召唤成功的场合，以除外的1只自己的「玄化」怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段除外。
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
	-- ②：这张卡已在魔法与陷阱区域存在的状态，这张卡以外的自己的「玄化」卡被除外的场合，以对方场上1张卡为对象才能发动。那张卡除外。
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
-- 判断怪兽是否为对方召唤的
function c52714670.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 判断是否有对方特殊召唤成功的怪兽
function c52714670.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52714670.cfilter,1,nil,1-tp)
end
-- 判断除外区的怪兽是否为「玄化」且可特殊召唤
function c52714670.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x105) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标时的过滤条件，用于特殊召唤效果
function c52714670.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c52714670.spfilter(chkc,e,tp) end
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的除外怪兽
		and Duel.IsExistingTarget(c52714670.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的除外怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c52714670.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果的执行逻辑
function c52714670.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效并进行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:RegisterFlagEffect(52714670,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 创建一个在下个回合结束时除外特殊召唤怪兽的效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		-- 设置该效果将在下个回合结束时触发
		e2:SetLabel(Duel.GetTurnCount()+1)
		e2:SetLabelObject(tc)
		e2:SetCondition(c52714670.ermcon)
		e2:SetOperation(c52714670.ermop)
		-- 将该效果注册到玩家场上
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断是否到了应除外怪兽的回合
function c52714670.ermcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(52714670)~=0 then
		-- 判断当前回合数是否等于设定的回合数
		return Duel.GetTurnCount()==e:GetLabel()
	else
		e:Reset()
		return false
	end
end
-- 执行将怪兽除外的操作
function c52714670.ermop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将目标怪兽除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
-- 判断被除外的卡是否为「玄化」且为己方控制
function c52714670.rmcfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x105) and c:IsPreviousControler(tp)
end
-- 判断是否有己方「玄化」卡被除外
function c52714670.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52714670.rmcfilter,1,e:GetHandler(),tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 设置选择目标时的过滤条件，用于除外效果
function c52714670.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查场上是否存在可除外的对方卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择符合条件的对方场上的卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将要除外卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 处理除外效果的执行逻辑
function c52714670.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
