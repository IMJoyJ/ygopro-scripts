--D・チャッカン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：可以把自己场上存在的1只怪兽解放给与对方基本分600分伤害。这个效果1回合只能使用1次。
-- ●守备表示：1回合1次，可以给与对方基本分300分伤害。
function c66331855.initial_effect(c)
	-- ●攻击表示：可以把自己场上存在的1只怪兽解放给与对方基本分600分伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66331855,0))  --"给予对方600伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c66331855.cona)
	e1:SetCost(c66331855.costa)
	e1:SetTarget(c66331855.tga)
	e1:SetOperation(c66331855.op)
	c:RegisterEffect(e1)
	-- ●守备表示：1回合1次，可以给与对方基本分300分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66331855,1))  --"给予对方300伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c66331855.cond)
	e2:SetTarget(c66331855.tgd)
	e2:SetOperation(c66331855.op)
	c:RegisterEffect(e2)
end
-- 攻击表示效果的发动条件：自身未被无效且处于攻击表示
function c66331855.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 守备表示效果的发动条件：自身未被无效且处于守备表示
function c66331855.cond(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 攻击表示效果的发动代价：解放自己场上的1只怪兽
function c66331855.costa(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否存在至少1只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,1,nil) end
	-- 让玩家选择自己场上1只可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,nil)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 攻击表示效果的发动准备：设置对方玩家为效果对象，并声明600点伤害的操作信息
function c66331855.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设为效果处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果参数（伤害值）设定为600
	Duel.SetTargetParam(600)
	-- 设置当前连锁的操作信息为给与对方玩家600点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 守备表示效果的发动准备：设置对方玩家为效果对象，并声明300点伤害的操作信息
function c66331855.tgd(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设为效果处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果参数（伤害值）设定为300
	Duel.SetTargetParam(300)
	-- 设置当前连锁的操作信息为给与对方玩家300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 效果处理：获取设定的对象玩家和伤害值，并给与该玩家对应的效果伤害
function c66331855.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
