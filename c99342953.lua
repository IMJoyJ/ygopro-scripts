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
-- 用于判断被破坏的怪兽是否为名字带有「外星」的怪兽（即是否满足放置指示物条件）
function c99342953.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0xc)
end
-- 当有被破坏的怪兽时触发，检查是否有名字带有「外星」的怪兽被破坏
function c99342953.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99342953.ctfilter,1,nil)
end
-- 将1个A指示物放置到此卡上
function c99342953.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x100e,1)
end
-- 支付效果代价：移除场上2个A指示物
function c99342953.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以移除场上2个A指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x100e,2,REASON_COST) end
	-- 执行移除场上2个A指示物的操作
	Duel.RemoveCounter(tp,1,1,0x100e,2,REASON_COST)
end
-- 用于筛选墓地里名字带有「外星」且可特殊召唤的怪兽
function c99342953.filter(c,e,tp)
	return c:IsSetCard(0xc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择条件：从自己墓地选择1只名字带有「外星」的怪兽作为目标
function c99342953.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c99342953.filter(chkc,e,tp) end
	-- 判断场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c99342953.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽作为特殊召唤的目标
	local g=Duel.SelectTarget(tp,c99342953.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表明将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作：将选定的怪兽特殊召唤到场上
function c99342953.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
