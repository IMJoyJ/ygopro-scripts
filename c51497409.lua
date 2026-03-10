--DDD磐石王ダリウス
-- 效果：
-- 恶魔族3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1张「契约书」卡为对象才能发动。那张卡破坏，自己从卡组抽1张。这个效果在对方回合也能发动。
-- ②：这张卡和对方怪兽进行战斗的伤害计算时，把这张卡1个超量素材取除才能发动。这张卡不会被那次战斗破坏，伤害计算后那只对方怪兽破坏，给与对方500伤害。
function c51497409.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加XYZ召唤手续，使用满足种族为恶魔族的3星怪兽作为素材进行叠放，最少需要2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),3,2)
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1张「契约书」卡为对象才能发动。那张卡破坏，自己从卡组抽1张。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51497409,0))  --"破坏并抽卡"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c51497409.cost)
	e1:SetTarget(c51497409.ddtg)
	e1:SetOperation(c51497409.ddop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害计算时，把这张卡1个超量素材取除才能发动。这张卡不会被那次战斗破坏，伤害计算后那只对方怪兽破坏，给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51497409,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(c51497409.incon)
	e2:SetCost(c51497409.cost)
	e2:SetOperation(c51497409.inop)
	c:RegisterEffect(e2)
end
-- 支付效果代价：从自己场上移除1个超量素材作为费用
function c51497409.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索满足条件的「契约书」卡过滤器函数，用于选择对象
function c51497409.ddfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- 设置效果目标选择函数，判断是否能选择满足条件的「契约书」卡
function c51497409.ddtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c51497409.ddfilter(chkc) end
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查场上是否存在满足条件的「契约书」卡
		and Duel.IsExistingTarget(c51497409.ddfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的「契约书」卡作为效果对象
	local g=Duel.SelectTarget(tp,c51497409.ddfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：将被破坏的卡加入连锁处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：将抽卡效果加入连锁处理对象
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果处理函数，若目标卡存在且被成功破坏，则进行抽卡
function c51497409.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然存在于场上并满足效果处理条件，若满足则进行破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 判断战斗中对方怪兽是否被正确选择
function c51497409.incon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp)
end
-- 执行效果处理函数，使自身在战斗中不会被破坏，并设置战斗后破坏对方怪兽并造成伤害
function c51497409.inop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 使自身在战斗中不会被破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		-- 设置战斗后触发的效果，当战斗结束时破坏对方怪兽并造成500伤害
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLED)
		e2:SetOperation(c51497409.desop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e2)
	end
end
-- 战斗结束后执行的处理函数，判断对方怪兽是否存在并将其破坏，然后对对方造成500伤害
function c51497409.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dc=c:GetBattleTarget()
	-- 判断对方怪兽是否存在且被成功破坏
	if dc and Duel.Destroy(dc,REASON_EFFECT)>0 then
		-- 给与对方玩家500点伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
