--星遺物との邂逅
-- 效果：
-- ①：场上的「星杯」怪兽的攻击力·守备力上升300。
-- ②：1回合1次，自己场上的表侧表示的「星杯」怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地1只「星杯」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c61654098.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「星杯」怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	-- 设置效果影响的对象为「星杯」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xfd))
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己场上的表侧表示的「星杯」怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合，以自己墓地1只「星杯」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(61654098,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c61654098.spcon)
	e4:SetTarget(c61654098.sptg)
	e4:SetOperation(c61654098.spop)
	c:RegisterEffect(e4)
end
-- 过滤因战斗破坏或因对方效果离场的自己场上表侧表示的「星杯」怪兽
function c61654098.spcfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0xfd)
		and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
-- 检查是否有符合条件的「星杯」怪兽离场
function c61654098.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c61654098.spcfilter,1,nil,tp,rp)
end
-- 过滤自己墓地中可以特殊召唤的「星杯」怪兽
function c61654098.filter(c,e,tp)
	return c:IsSetCard(0xfd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标选择与合法性检测
function c61654098.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c61654098.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的「星杯」怪兽
		and Duel.IsExistingTarget(c61654098.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「星杯」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c61654098.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理，将选中的墓地怪兽守备表示特殊召唤
function c61654098.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
