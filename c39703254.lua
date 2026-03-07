--トマボー
-- 效果：
-- 场上表侧表示存在的这张卡以外的1只植物族怪兽成为对方的魔法·陷阱卡的效果的对象时才能发动。把自己场上存在的这张卡解放，从自己卡组抽2张卡。
function c39703254.initial_effect(c)
	-- 创建效果，设置效果描述为抽卡，分类为抽卡效果，属性为以玩家为目标，类型为诱发即时效果，触发事件为连锁发动，发动位置为主怪区，条件函数为condition，费用函数为cost，目标函数为target，效果处理函数为operation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39703254,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c39703254.condition)
	e1:SetCost(c39703254.cost)
	e1:SetTarget(c39703254.target)
	e1:SetOperation(c39703254.operation)
	c:RegisterEffect(e1)
end
-- 连锁发动时的条件判断：对方发动魔法或陷阱卡且具有取对象效果，且该效果的对象为1张卡，该卡必须是植物族且表侧表示，且不是此卡本身
function c39703254.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tg=g:GetFirst()
	local c=e:GetHandler()
	return tg~=c and tg:IsFaceup() and tg:IsRace(RACE_PLANT)
end
-- 费用函数：检查此卡是否可以被解放，若可以则进行解放操作
function c39703254.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡从场上解放作为发动费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 目标函数：检查玩家是否可以抽2张卡，若可以则设置目标玩家为当前玩家，设置目标参数为2，设置操作信息为抽2张卡
function c39703254.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的操作对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的操作对象参数为2
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为抽卡效果，抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：获取连锁的目标玩家和参数，执行抽卡效果
function c39703254.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡，抽卡原因设为效果
	Duel.Draw(p,d,REASON_EFFECT)
end
