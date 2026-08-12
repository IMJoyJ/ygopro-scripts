--ワンショット・ブースター
-- 效果：
-- 自己对怪兽的召唤成功的回合，这张卡可以从手卡特殊召唤。可以把这张卡解放，这个回合和自己怪兽进行战斗的1只对方怪兽破坏。
function c60187739.initial_effect(c)
	-- 自己对怪兽的召唤成功的回合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c60187739.spcon)
	c:RegisterEffect(e1)
	-- 可以把这张卡解放，这个回合和自己怪兽进行战斗的1只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60187739,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c60187739.cost)
	e2:SetTarget(c60187739.target)
	e2:SetOperation(c60187739.operation)
	c:RegisterEffect(e2)
	if not c60187739.global_check then
		c60187739.global_check=true
		c60187739[0]=false
		c60187739[1]=false
		-- 自己对怪兽的召唤成功的回合
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c60187739.checkop)
		-- 注册全局效果，用于监听并记录玩家召唤成功事件。
		Duel.RegisterEffect(ge1,0)
		-- 自己对怪兽的召唤成功的回合
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c60187739.clear)
		-- 注册全局效果，在每个回合的抽卡阶段开始时重置召唤记录。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 召唤成功时的操作，将对应玩家在本回合召唤成功的标记设为true。
function c60187739.checkop(e,tp,eg,ep,ev,re,r,rp)
	c60187739[ep]=true
end
-- 重置函数，将双方玩家在本回合召唤成功的标记重置为false。
function c60187739.clear(e,tp,eg,ep,ev,re,r,rp)
	c60187739[0]=false
	c60187739[1]=false
end
-- 特殊召唤规则的允许条件函数。
function c60187739.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家本回合是否召唤过怪兽，且怪兽区域有空位。
	return c60187739[c:GetControler()] and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤条件：选择场上表侧表示且在本回合进行过战斗的怪兽。
function c60187739.filter(c)
	return c:IsFaceup() and c:GetBattledGroupCount()~=0
end
-- 效果发动的代价（Cost）判定与执行函数。
function c60187739.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果的目标选择与发动准备函数。
function c60187739.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c60187739.filter(chkc) end
	-- 检查对方场上是否存在至少1只满足条件（本回合进行过战斗）的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c60187739.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c60187739.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果会破坏选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理（Operation）函数。
function c60187739.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏目标怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
