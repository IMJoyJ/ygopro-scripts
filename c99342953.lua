--古代遺跡コードA
-- 效果：
-- 每次场上表侧表示存在的名字带有「外星」的怪兽被破坏，给这张卡放置1个A指示物。1回合1次，可以把场上存在的2个A指示物取除，自己墓地存在的1只名字带有「外星」的怪兽特殊召唤。
function c99342953.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次场上表侧表示存在的名字带有「外星」的怪兽被破坏，给这张卡放置1个A指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c99342953.ctcon)
	e2:SetOperation(c99342953.ctop)
	c:RegisterEffect(e2)
	-- 1回合1次，可以把场上存在的2个A指示物去除，以自己墓地1只名字带有「外星」的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99342953,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c99342953.spcost)
	e3:SetTarget(c99342953.sptg)
	e3:SetOperation(c99342953.spop)
	c:RegisterEffect(e3)
end
c99342953.counter_add_list={0x100e}
c99342953.mentioned_counter={
	[0x100e]=true,
}
-- 指示物放置条件过滤：从怪兽区域表侧表示离开且原卡名包含「外星」的怪兽
function c99342953.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0xc)
end
-- 指示物放置效果触发条件：存在满足条件的「外星」怪兽被破坏
function c99342953.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99342953.ctfilter,1,nil)
end
-- 指示物放置效果处理：为自身放置1个A指示物
function c99342953.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x100e,1)
end
-- 特殊召唤效果Cost：从自己场上去除2个A指示物
function c99342953.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：判断场上是否有至少2个A指示物可去除
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x100e,2,REASON_COST) end
	-- Cost支付：从场上去除2个A指示物
	Duel.RemoveCounter(tp,1,1,0x100e,2,REASON_COST)
end
-- 特殊召唤目标过滤：自己墓地包含「外星」的怪兽
function c99342953.filter(c,e,tp)
	return c:IsSetCard(0xc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果发动准备与目标选择
function c99342953.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c99342953.filter(chkc,e,tp) end
	-- 判断自己怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在可特殊召唤的「外星」怪兽
		and Duel.IsExistingTarget(c99342953.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「外星」怪兽作为目标
	local g=Duel.SelectTarget(tp,c99342953.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤选中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果处理：将目标怪兽表侧表示特殊召唤
function c99342953.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
