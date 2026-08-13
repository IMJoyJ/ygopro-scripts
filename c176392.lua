--コアキメイル・テストベッド
-- 效果：
-- 场上表侧表示存在的名字带有「核成」的怪兽在结束阶段时被破坏的场合，可以作为代替把这张卡破坏。此外，场上表侧表示存在的名字带有「核成」的怪兽在结束阶段时被破坏时，可以在自己场上把1只「核成衍生物」（岩石族·地·4星·攻/守1800）特殊召唤。
function c176392.initial_effect(c)
	-- 场上表侧表示存在的名字带有「核成」的怪兽在结束阶段时被破坏的场合，可以作为代替把这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c176392.descon)
	e1:SetTarget(c176392.destg)
	e1:SetValue(c176392.repval)
	c:RegisterEffect(e1)
	-- 此外，场上表侧表示存在的名字带有「核成」的怪兽在结束阶段时被破坏时，可以在自己场上把1只「核成衍生物」（岩石族·地·4星·攻/守1800）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(176392,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c176392.spcon)
	e2:SetTarget(c176392.sptg)
	e2:SetOperation(c176392.spop)
	c:RegisterEffect(e2)
end
-- 该函数是效果e1的代破发动条件：仅在当前阶段为结束阶段时才适用代替破坏效果。
function c176392.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为结束阶段（PHASE_END），以确保代破效果只在结束阶段生效。
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 筛选条件：被破坏的卡必须是表侧表示、位于怪兽区域、属于「核成」字段，且其破坏原因不是“代替破坏”（REASON_REPLACE），用于选出可以被代破的核成怪兽。
function c176392.rfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x1d) and not c:IsReason(REASON_REPLACE)
end
-- 代破效果e1的Target函数：在chk==0时检查是否存在符合条件的核成怪兽被破坏，并且这张卡自身可被破坏且未处于预定破坏状态；满足则返回true以允许玩家选择是否代破。
function c176392.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c176392.rfilter,1,c)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 向当前玩家弹出是否用这张卡代替破坏的确认询问（提示文本编号96）。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 将「核成试验台」自身以效果破坏+代替破坏的原因（REASON_EFFECT+REASON_REPLACE）破坏，从而代替原本要被破坏的核成怪兽。
		Duel.Destroy(c,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 代破效果e1的Value函数：判断要被破坏的c是否满足可被代替破坏的条件——表侧表示、属于「核成」字段，且不是这张「核成试验台」自身（因为自身是代替破坏的代价）。
function c176392.repval(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1d) and c~=e:GetHandler()
end
-- 筛选本次破坏事件中的怪兽：被破坏前位于怪兽区域、之前为表侧表示、之前卡名含有「核成」字段的卡，用于触发衍生物特招。
function c176392.spfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x1d)
end
-- 特殊召唤衍生物效果的发动条件：当前处于结束阶段，且本次破坏事件中存在符合条件的「核成」怪兽被破坏。
function c176392.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 综合判定：是否处于结束阶段且有符合条件的「核成」怪兽被破坏（eg中存在满足spfilter的卡）。
	return Duel.GetCurrentPhase()==PHASE_END and eg:IsExists(c176392.spfilter,1,nil)
end
-- 特殊召唤衍生物效果的Target函数：在chk==0时确认自己怪兽区有空位且可以特殊召唤「核成衍生物」，满足则效果可发动，并设置操作信息。
function c176392.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查当前玩家能否特殊召唤「核成衍生物」（卡号176393，岩石族·地·4星·攻/守1800，衍生物）到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,176393,0x1d,TYPES_TOKEN_MONSTER,1800,1800,4,RACE_ROCK,ATTRIBUTE_EARTH) end
	-- 设置操作信息：本连锁将生成1只衍生物，分类为CATEGORY_TOKEN。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本连锁将进行1只怪兽的特殊召唤，分类为CATEGORY_SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤衍生物的效果处理函数：确认仍有空位且玩家仍可特招后，生成「核成衍生物」并以表侧攻击表示特殊召唤到自己场上。
function c176392.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己场上是否有怪兽区空位，没有则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时再次确认玩家仍能特殊召唤「核成衍生物」，不能则直接结束处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,176393,0x1d,TYPES_TOKEN_MONSTER,1800,1800,4,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	-- 创建1只「核成衍生物」（卡号176393）的衍生物，控制者为当前玩家tp。
	local token=Duel.CreateToken(tp,176393)
	-- 将生成的「核成衍生物」以表侧攻击表示特殊召唤到当前玩家tp的场上（不检查召唤条件、不限制苏生限制）。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
