--プリーステス・オーム
-- 效果：
-- 可以把自己场上表侧表示存在的1只暗属性怪兽作为祭品，给与对方基本分800分伤害。
function c27869883.initial_effect(c)
	-- 可以把自己场上表侧表示存在的1只暗属性怪兽作为祭品，给与对方基本分800分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27869883,0))  --"800伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c27869883.damcost)
	e1:SetTarget(c27869883.damtg)
	e1:SetOperation(c27869883.damop)
	c:RegisterEffect(e1)
end
-- 定义可供解放的怪兽过滤条件：必须为表侧表示且属性为暗属性。
function c27869883.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 起动效果的代价操作：从自己场上选择1只表侧表示的暗属性怪兽解放，作为发动效果的代价。
function c27869883.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查自己场上是否存在至少1只表侧表示且暗属性的可解放怪兽，若存在则允许发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c27869883.cfilter,1,nil) end
	-- 从自己场上选择1只表侧表示且暗属性的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c27869883.cfilter,1,1,nil)
	-- 将选择的怪兽解放，作为效果发动所支付的代价。
	Duel.Release(g,REASON_COST)
end
-- 效果发动时设置对象玩家和伤害参数，并登记伤害效果的操作信息。
function c27869883.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方玩家（即1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为800，表示这次伤害的数值。
	Duel.SetTargetParam(800)
	-- 登记操作信息，声明将对对方玩家造成800点伤害，供连锁时点等判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,800)
end
-- 效果处理阶段执行伤害：从连锁信息中取出对象玩家和伤害值，给对方造成效果伤害。
function c27869883.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数（伤害值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给对象玩家p造成d点效果伤害，伤害来源为效果。
	Duel.Damage(p,d,REASON_EFFECT)
end
