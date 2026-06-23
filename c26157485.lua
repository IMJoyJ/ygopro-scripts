--C・シューター
-- 效果：
-- 把自己场上存在的1只名字带有「链」的怪兽送去墓地发动。给与对方基本分800分伤害。这个效果1回合只能使用1次。
function c26157485.initial_effect(c)
	-- 创建一个起动效果，效果描述为“伤害”，分类为伤害效果，具有以玩家为对象的特性，类型为起动效果，生效位置为主怪兽区，一回合只能使用1次，费用为送去墓地，目标为对方玩家，效果处理为造成800伤害
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26157485,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c26157485.damcost)
	e1:SetTarget(c26157485.damtg)
	e1:SetOperation(c26157485.damop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上正面表示、名字带有「链」、可以作为墓地代价的怪兽
function c26157485.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x25) and c:IsAbleToGraveAsCost()
end
-- 效果费用处理函数，检查是否满足条件并选择1只符合条件的怪兽送去墓地作为代价
function c26157485.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c26157485.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c26157485.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果目标设定函数，设置效果对象为对方玩家，效果参数为800，操作信息为伤害效果
function c26157485.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁效果的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为800
	Duel.SetTargetParam(800)
	-- 设置连锁效果的操作信息为伤害效果，对象为对方玩家，伤害值为800
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理函数，获取连锁效果的目标玩家和参数，并对目标玩家造成相应伤害
function c26157485.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
