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
	-- 设置该效果的Value为aux.tgoval，即当对方发动卡的效果并以这张卡为对象时，因对象选择者不是这张卡的控制者，使这张卡不能成为对方效果的对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ③：这张卡的效果特殊召唤的这张卡存在的状态，每次自己的魔法与陷阱区域的卡在怪兽区域特殊召唤，以场上1张卡为对象才能发动。那张卡破坏。
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
-- 效果①的发动合法性判定：在发动时检查己方主要怪兽区是否有空位、是否满足将这张卡作为效果怪兽特殊召唤的条件，若满足则效果可以发动。
function c23626223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查己方主要怪兽区是否存在至少1个可用的空格。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方玩家是否可以将这张卡以岩石族·地·7星·攻0/守2500的效果怪兽形式特殊召唤到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,23626223,0,TYPES_EFFECT_TRAP_MONSTER,0,2500,7,RACE_ROCK,ATTRIBUTE_EARTH) end
	-- 设置本次操作信息，声明将要通过这个效果把这张卡自身进行特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：让这张卡变为效果怪兽（也当作陷阱卡），并将其特殊召唤到己方主要怪兽区。
function c23626223.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理前再次确认此时仍能满足特殊召唤条件，若不能则中止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,23626223,0,TYPES_EFFECT_TRAP_MONSTER,0,2500,7,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 以自身效果（SUMMON_VALUE_SELF）将这张卡表侧表示特殊召唤到自己场上；第一个true表示不检查召唤条件，第二个false表示仍检查苏生限制。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 该过滤器用于筛选“当作怪兽使用的陷阱卡”：表侧表示、原本种类包含陷阱卡且当前也属于怪兽卡的卡。
function c23626223.tgfilter(c)
	return c:IsFaceup() and bit.band(c:GetOriginalType(),TYPE_TRAP)~=0 and c:IsType(TYPE_MONSTER)
end
-- ②效果的适用条件：这张卡是由自身效果特殊召唤的，并且己方场上存在这张卡以外的当作怪兽使用的陷阱卡。
function c23626223.tgcon(e)
	local c=e:GetHandler()
	-- 检查己方怪兽区是否存在至少1张满足tgfilter条件的卡，且该卡不是这张卡自身。
	return Duel.IsExistingMatchingCard(c23626223.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,c)
		and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 该过滤器用于判定一张卡是否刚刚从自己的魔法与陷阱区域特殊召唤到怪兽区域。
function c23626223.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
end
-- ③效果的触发条件：这张卡由自身效果特殊召唤且不在本次特殊召唤的怪兽群中，同时本次特殊召唤的怪兽里至少有一张是从自己的魔法与陷阱区域特殊召唤上来的卡。
function c23626223.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and not eg:IsContains(c) and eg:IsExists(c23626223.cfilter,1,nil,tp)
end
-- ③效果发动时的取对象处理：选择场上1张卡作为破坏对象，并设置对应的破坏操作信息。
function c23626223.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动合法性检查：场上是否存在至少1张可以成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操控者显示选择提示，提示文本为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方玩家从双方场上选择1张卡作为这个效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次操作信息，声明将对选择的对象进行破坏，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：将步骤中选择并仍与效果关联的对象卡进行破坏。
function c23626223.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
