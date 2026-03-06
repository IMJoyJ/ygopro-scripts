--苦紋様の土像
-- 效果：
-- ①：这张卡发动后变成效果怪兽（岩石族·地·7星·攻0/守2500）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ②：只要这张卡以外的当作怪兽使用的陷阱卡在怪兽区域存在，对方不能把这张卡的效果特殊召唤的这张卡作为效果的对象。
-- ③：这张卡的效果特殊召唤的这张卡存在的状态，自己的魔法与陷阱区域的卡在怪兽区域特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c23626223.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（岩石族·地·7星·攻0/守2500）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c23626223.target)
	e1:SetOperation(c23626223.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡以外的当作怪兽使用的陷阱卡在怪兽区域存在，对方不能把这张卡的效果特殊召唤的这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c23626223.tgcon)
	-- 不会成为对方的卡的效果对象的过滤函数的简单写法，用在效果注册里 SetValue
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ③：这张卡的效果特殊召唤的这张卡存在的状态，自己的魔法与陷阱区域的卡在怪兽区域特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23626223,0))  --"卡片破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c23626223.descon)
	e3:SetTarget(c23626223.destg)
	e3:SetOperation(c23626223.desop)
	c:RegisterEffect(e3)
end
-- 判断是否满足特殊召唤条件，包括场地空位和是否可以特殊召唤该怪兽
function c23626223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有足够的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤该怪兽（包括属性、等级、种族等）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,23626223,0,TYPES_EFFECT_TRAP_MONSTER,0,2500,7,RACE_ROCK,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动效果时执行的特殊召唤操作，将此卡以效果怪兽形式特殊召唤
function c23626223.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否可以特殊召唤该怪兽，防止重复检查
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,23626223,0,TYPES_EFFECT_TRAP_MONSTER,0,2500,7,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 执行特殊召唤操作，将此卡以效果怪兽形式特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 过滤函数，用于判断场上是否有当作怪兽使用的陷阱卡
function c23626223.tgfilter(c)
	return c:IsFaceup() and bit.band(c:GetOriginalType(),TYPE_TRAP)~=0 and c:IsType(TYPE_MONSTER)
end
-- 条件函数，判断是否满足效果②的触发条件
function c23626223.tgcon(e)
	local c=e:GetHandler()
	-- 检查场上是否存在当作怪兽使用的陷阱卡
	return Duel.IsExistingMatchingCard(c23626223.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c)
		and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数，用于判断是否为从魔法与陷阱区域特殊召唤的卡
function c23626223.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
end
-- 条件函数，判断是否满足效果③的触发条件
function c23626223.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and not eg:IsContains(c) and eg:IsExists(c23626223.cfilter,1,nil,tp)
end
-- 设置效果③的目标选择函数，选择场上一张卡作为破坏对象
function c23626223.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判断是否满足选择目标的条件，即场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，表示将要破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果③的破坏操作，将目标卡破坏
function c23626223.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行破坏操作，将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
