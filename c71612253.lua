--DDD狙撃王テル
-- 效果：
-- 5星怪兽×2
-- 这张卡也能在自己场上的4阶「DDD」超量怪兽上面重叠来超量召唤。
-- ①：自己受到效果伤害的自己·对方回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力下降1000，给与对方1000伤害。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「DD」卡或「契约书」卡送去墓地。
function c71612253.initial_effect(c)
	aux.AddXyzProcedure(c,nil,5,2,c71612253.ovfilter,aux.Stringid(71612253,0))  --"是否在4阶的「DDD」超量怪兽上面重叠来超量召唤?"
	c:EnableReviveLimit()
	-- ①：自己受到效果伤害的自己·对方回合1次，把这张卡1个超量素材取除，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力·守备力下降1000，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71612253,1))  --"下降攻守并给与伤害"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE)
	e1:SetCountLimit(1)
	e1:SetCondition(c71612253.condition)
	e1:SetCost(c71612253.cost)
	e1:SetTarget(c71612253.target)
	e1:SetOperation(c71612253.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「DD」卡或「契约书」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71612253,2))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(c71612253.tgcon)
	e2:SetTarget(c71612253.tgtg)
	e2:SetOperation(c71612253.tgop)
	c:RegisterEffect(e2)
	if not c71612253.global_check then
		c71612253.global_check=true
		-- 这张卡也能在自己场上的4阶「DDD」超量怪兽上面重叠来超量召唤。/①：自己受到效果伤害
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(c71612253.checkop)
		-- 注册全局环境下的效果，用于监测玩家受到效果伤害的事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤自身重叠超量召唤所需的素材怪兽（自己场上表侧表示的4阶「DDD」超量怪兽）
function c71612253.ovfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x10af) and c:IsRank(4)
end
-- 受到效果伤害时，为受到伤害的玩家注册一个当回合有效的标记（Flag）
function c71612253.checkop(e,tp,eg,ep,ev,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 then
		-- 为受到效果伤害的玩家注册一个持续到回合结束的标识效果，用于记录其在本回合内受到过效果伤害
		Duel.RegisterFlagEffect(ep,71612253,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判定效果①的发动条件（本回合自己受到过效果伤害，且不在伤害计算后）
function c71612253.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否拥有受到效果伤害的标记，并确认当前不处于伤害计算后
	return Duel.GetFlagEffect(tp,71612253)~=0 and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果①的代价：取除这张卡的1个超量素材
function c71612253.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的靶向选择：选择场上1只表侧表示怪兽为对象，并声明给与对方伤害的操作信息
function c71612253.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要作为效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前处理的连锁的操作信息为“给与对方1000点伤害”
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果①的处理：使作为对象的怪兽攻击力·守备力下降1000，并给与对方1000点伤害
function c71612253.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力·守备力下降1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		-- 给与对方玩家1000点效果伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
-- 判定效果②的发动条件（这张卡必须从场上送去墓地）
function c71612253.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中满足条件的「DD」卡或「契约书」卡，且该卡能被送去墓地
function c71612253.tgfilter(c)
	return c:IsSetCard(0xaf,0xae) and c:IsAbleToGrave()
end
-- 效果②的靶向选择：检查卡组中是否存在可送去墓地的目标卡，并声明送去墓地的操作信息
function c71612253.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以送去墓地的「DD」卡或「契约书」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c71612253.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前处理的连锁的操作信息为“从卡组将1张卡送去墓地”
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组选择1张「DD」卡或「契约书」卡送去墓地
function c71612253.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组中选择1张满足条件的「DD」卡或「契约书」卡
	local g=Duel.SelectMatchingCard(tp,c71612253.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
