--機動砦 ストロング・ホールド
-- 效果：
-- ①：这张卡发动后变成效果怪兽（机械族·地·4星·攻0/守2000）在怪兽区域守备表示特殊召唤。这张卡也当作陷阱卡使用。
-- ②：自己场上有「绿色零件」「红色零件」「黄色零件」存在的场合，这张卡的效果特殊召唤的这张卡的攻击力上升3000。
function c13955608.initial_effect(c)
	-- 为卡片注册关联的零件卡代码，用于后续效果判断
	aux.AddCodeList(c,41172955,86445415,13839120)
	-- ①：这张卡发动后变成效果怪兽（机械族·地·4星·攻0/守2000）在怪兽区域守备表示特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c13955608.target)
	e1:SetOperation(c13955608.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「绿色零件」「红色零件」「黄色零件」存在的场合，这张卡的效果特殊召唤的这张卡的攻击力上升3000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(3000)
	e2:SetCondition(c13955608.atkcon)
	c:RegisterEffect(e2)
end
-- 目标函数：判断是否可以发动此卡
function c13955608.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤此卡为陷阱怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13955608,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息，表明将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动函数：执行此卡的特殊召唤效果
function c13955608.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查玩家是否可以特殊召唤此卡
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,13955608,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_TRAP+TYPE_EFFECT)
	-- 将此卡以守备表示特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_DEFENSE)
end
-- 过滤函数：判断场上是否存在指定代码的表侧表示卡
function c13955608.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 条件函数：判断是否满足攻击力上升的条件
function c13955608.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查场上是否存在绿色零件
	return Duel.IsExistingMatchingCard(c13955608.cfilter,tp,LOCATION_ONFIELD,0,1,nil,41172955)
		-- 检查场上是否存在红色零件
		and Duel.IsExistingMatchingCard(c13955608.cfilter,tp,LOCATION_ONFIELD,0,1,nil,86445415)
		-- 检查场上是否存在黄色零件
		and Duel.IsExistingMatchingCard(c13955608.cfilter,tp,LOCATION_ONFIELD,0,1,nil,13839120)
		and e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
