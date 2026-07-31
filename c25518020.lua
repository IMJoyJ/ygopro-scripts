--マシン・デベロッパー
-- 效果：
-- 场上表侧表示存在的机械族怪兽的攻击力上升200。每次场上存在的机械族怪兽被破坏，给这张卡放置2个废品指示物。可以把这张卡送去墓地，从自己墓地选择持有这张卡放置的废品指示物数量以下的等级的1只机械族怪兽特殊召唤。
function c25518020.initial_effect(c)
	c:EnableCounterPermit(0x1d)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的机械族怪兽的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 选择满足条件的机械族怪兽作为目标。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_MACHINE))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	-- 每次场上存在的机械族怪兽被破坏，给这张卡放置2个废品指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c25518020.ctcon)
	e3:SetOperation(c25518020.ctop)
	c:RegisterEffect(e3)
	-- 可以把这张卡送去墓地，从自己墓地选择持有这张卡放置的废品指示物数量以下的等级的1只机械族怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(25518020,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c25518020.spcost)
	e4:SetTarget(c25518020.sptg)
	e4:SetOperation(c25518020.spop)
	c:RegisterEffect(e4)
end
c25518020.mentioned_counter={
	[0x1d]=true,
}
-- 判断被破坏的怪兽是否为机械族且在场上正面表示过。
function c25518020.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)~=0
end
-- 判断是否有满足条件的怪兽被破坏。
function c25518020.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25518020.ctfilter,1,nil)
end
-- 给这张卡放置2个废品指示物。
function c25518020.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1d,2)
end
-- 支付将此卡送去墓地作为代价。
function c25518020.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabel(e:GetHandler():GetCounter(0x1d))
	-- 将此卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选满足等级、种族且可特殊召唤的怪兽。
function c25518020.filter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标时的条件，确保能选出符合条件的怪兽。
function c25518020.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c25518020.filter(chkc,e,tp,e:GetLabel()) end
	-- 判断场上是否有空位可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足等级和种族要求的机械族怪兽。
		and Duel.IsExistingTarget(c25518020.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler():GetCounter(0x1d)) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽作为目标。
	local g=Duel.SelectTarget(tp,c25518020.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabel())
	-- 设置操作信息，表明将要特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作。
function c25518020.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选定的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_MACHINE) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
