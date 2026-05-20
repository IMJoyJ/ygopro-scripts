--火竜の火炎弾
-- 效果：
-- 自己场上有龙族怪兽表侧表示存在的场合，从下面效果选择1个发动：
-- ●给与对方基本分800分伤害。
-- ●选择场上表侧表示存在的1只守备力800以下的怪兽破坏。
function c55991637.initial_effect(c)
	-- 自己场上有龙族怪兽表侧表示存在的场合，从下面效果选择1个发动：●给与对方基本分800分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55991637,0))  --"给予对方基本分800分伤害"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c55991637.condition)
	e1:SetTarget(c55991637.damtg)
	e1:SetOperation(c55991637.damop)
	c:RegisterEffect(e1)
	-- 自己场上有龙族怪兽表侧表示存在的场合，从下面效果选择1个发动：●选择场上表侧表示存在的1只守备力800以下的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55991637,1))  --"选择场上表侧表示存在的1只守备力800以下的怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c55991637.condition)
	e2:SetTarget(c55991637.destg)
	e2:SetOperation(c55991637.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的龙族怪兽
function c55991637.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 发动条件：自己场上存在表侧表示的龙族怪兽
function c55991637.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的龙族怪兽
	return Duel.IsExistingMatchingCard(c55991637.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 伤害效果的发动准备
function c55991637.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示发动了“给予对方基本分800分伤害”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为800
	Duel.SetTargetParam(800)
	-- 设置当前连锁的操作信息为：给与对方玩家800分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 伤害效果的处理
function c55991637.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤条件：场上表侧表示且守备力在800以下的怪兽
function c55991637.dfilter(c)
	return c:IsFaceup() and c:IsDefenseBelow(800)
end
-- 破坏效果的发动准备
function c55991637.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c55991637.dfilter(chkc) end
	-- 检查场上是否存在可以作为对象的、表侧表示且守备力在800以下的怪兽
	if chk==0 then return Duel.IsExistingTarget(c55991637.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动了“选择场上表侧表示存在的1只守备力800以下的怪兽破坏”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置选择卡片时的提示信息为“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示且守备力在800以下的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c55991637.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理
function c55991637.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c55991637.dfilter(tc) and tc:IsRelateToEffect(e) then
		-- 因效果破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
