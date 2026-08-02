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
	-- 1回合1次，可以把场上存在的2个A指示物取除，自己墓地存在的1只名字带有「外星」的怪兽特殊召唤。
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
-- 过滤条件：判断被破坏前是否是场上表侧表示的「外星」怪兽
function c99342953.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0xc)
end
-- 效果触发条件：判断被破坏的卡中是否包含表侧表示的「外星」怪兽
function c99342953.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99342953.ctfilter,1,nil)
end
-- 效果处理：给这张卡放置1个A指示物
function c99342953.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x100e,1)
end
-- 效果发动代价：把场上存在的2个A指示物取除
function c99342953.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果是检查阶段，判断场上是否可以取除2个A指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x100e,2,REASON_COST) end
	-- 将场上存在的2个A指示物取除
	Duel.RemoveCounter(tp,1,1,0x100e,2,REASON_COST)
end
-- 过滤条件：判断是否是「外星」怪兽且能被特殊召唤
function c99342953.filter(c,e,tp)
	return c:IsSetCard(0xc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标：以自己墓地1只「外星」怪兽为对象
function c99342953.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c99342953.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的「外星」怪兽
		and Duel.IsExistingTarget(c99342953.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示消息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c99342953.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前处理的连锁操作信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将目标怪兽特殊召唤
function c99342953.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
