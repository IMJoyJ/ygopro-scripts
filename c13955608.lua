--機動砦 ストロング・ホールド
-- 效果：
-- ①：这张卡发动后变成效果怪兽（机械族·地·4星·攻0/守2000）在怪兽区域守备表示特殊召唤。这张卡也当作陷阱卡使用。
-- ②：自己场上有「绿色零件」「红色零件」「黄色零件」存在的场合，这张卡的效果特殊召唤的这张卡的攻击力上升3000。
function c13955608.initial_effect(c)
	-- 登记本卡效果涉及的「绿色零件」「红色零件」「黄色零件」的卡号（41172955/86445415/13839120），以便在规则上认定这些卡名被此卡记载，后续可用于关联检索。
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
-- 效果发动的条件判定：确认已满足发动前提、自己主要怪兽区域有空位，且当前玩家能够把此卡作为效果怪兽特殊召唤。
function c13955608.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己的主要怪兽区域是否存在至少1个空位，用于后续特殊召唤这张陷阱怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认玩家tp可以特殊召唤一只卡号为13955608的怪兽，其参数为：效果·陷阱怪兽、地属性、机械族、4星、攻击力0/守备力2000。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13955608,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 将本次效果要进行的特殊召唤信息登记为操作信息，声明对象为这张卡自身、数量为1，以便系统在效果处理时正确结算并允许其他卡响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：再次确认玩家仍可特殊召唤该陷阱怪兽；然后通过AddMonsterAttribute让此卡获得怪兽属性（陷阱+效果），最后以表侧守备表示将这张卡特殊召唤到自己的主要怪兽区域，同时继续当作陷阱卡使用。
function c13955608.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次检查玩家是否仍能合法特殊召唤该怪兽；若不能（例如区域被占用或受到限制）则直接终止本次特殊召唤处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,13955608,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_TRAP+TYPE_EFFECT)
	-- 将这张卡以自身效果（SUMMON_VALUE_SELF）特殊召唤：不检查召唤条件（nocheck=true），但保留苏生限制（nolimit=false），以表侧守备表示特殊召唤到玩家tp的场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_DEFENSE)
end
-- 定义过滤函数cfilter：判断一张卡是否满足“表侧表示”且“卡号等于指定code”（即三种零件之一）。
function c13955608.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 攻击力上升的适用条件：自己场上有表侧表示的绿色零件、红色零件、黄色零件各至少一张，且这张卡是由自身效果特殊召唤（召唤类型为SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF）。
function c13955608.atkcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上有表侧表示的「绿色零件」（卡号41172955）存在。
	return Duel.IsExistingMatchingCard(c13955608.cfilter,tp,LOCATION_ONFIELD,0,1,nil,41172955)
		-- 检查自己场上有表侧表示的「红色零件」（卡号86445415）存在。
		and Duel.IsExistingMatchingCard(c13955608.cfilter,tp,LOCATION_ONFIELD,0,1,nil,86445415)
		-- 检查自己场上有表侧表示的「黄色零件」（卡号13839120）存在。
		and Duel.IsExistingMatchingCard(c13955608.cfilter,tp,LOCATION_ONFIELD,0,1,nil,13839120)
		and e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
