--デトネーション・コード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「拓扑」连接怪兽存在的场合，以连接怪兽以外的自己墓地1只龙族·机械族·电子界族的暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡从魔法与陷阱区域除外的场合，下个回合的准备阶段才能发动。这张卡在自己场上盖放。
function c41348446.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「拓扑」连接怪兽存在的场合，以连接怪兽以外的自己墓地1只龙族·机械族·电子界族的暗属性怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41348446,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,41348446)
	e2:SetCondition(c41348446.spcon)
	e2:SetTarget(c41348446.sptg)
	e2:SetOperation(c41348446.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡从魔法与陷阱区域除外的场合，下个回合的准备阶段才能发动。这张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_REMOVE)
	e3:SetOperation(c41348446.spreg)
	c:RegisterEffect(e3)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41348446,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCategory(CATEGORY_SSET)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1,41348447)
	e4:SetCondition(c41348446.setcon)
	e4:SetTarget(c41348446.settg)
	e4:SetOperation(c41348446.setop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 检查场上是否存在「拓扑」连接怪兽
function c41348446.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x16e)
end
-- 检查场上是否存在「拓扑」连接怪兽
function c41348446.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「拓扑」连接怪兽
	return Duel.IsExistingMatchingCard(c41348446.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤满足龙族·机械族·电子界族、暗属性、非连接怪兽的墓地怪兽
function c41348446.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE+RACE_CYBERSE) and c:IsAttribute(ATTRIBUTE_DARK)
		and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标的过滤条件
function c41348446.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41348446.spfilter(chkc,e,tp) end
	-- 判断是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c41348446.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c41348446.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c41348446.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 记录该卡被除外时的回合数
function c41348446.spreg(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsPreviousLocation(LOCATION_SZONE) then
		-- 记录下个回合的准备阶段
		e:SetLabel(Duel.GetTurnCount()+1)
		e:GetHandler():RegisterFlagEffect(41348446,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 判断是否为下个回合的准备阶段且该卡被除外过
function c41348446.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为下个回合的准备阶段且该卡被除外过
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(41348446)>0
end
-- 设置盖放效果的处理信息
function c41348446.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置效果处理信息为盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行盖放操作
function c41348446.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡在自己场上盖放
		Duel.SSet(tp,c)
	end
end
