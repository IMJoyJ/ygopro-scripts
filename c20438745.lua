--灼熱王パイロン
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●可以给与对方基本分1000分伤害。这个效果1回合只能使用1次。
function c20438745.initial_effect(c)
	-- 为这张卡添加二重怪兽属性，使其在场上或墓地当作通常怪兽使用，并支持进行“当作通常召唤使用的再度召唤”来变成效果怪兽。
	aux.EnableDualAttribute(c)
	-- 这张卡当作效果怪兽使用并得到以下效果。●可以给与对方基本分1000分伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20438745,0))  --"1000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置该效果的发动条件：仅当这张卡处于二重怪兽的再度召唤状态（即当作效果怪兽使用中）时才能发动。
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c20438745.target)
	e1:SetOperation(c20438745.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动时的目标/条件判定：无额外发动条件；通过SetTargetPlayer和SetTargetParam指定对象玩家为对方、伤害参数为1000，并登记伤害类操作信息。
function c20438745.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁效果的对象玩家设置为对方的玩家（1-tp），即这次伤害的承受方。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁效果的对象参数设置为1000，作为后续实际造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：该效果属于伤害效果（CATEGORY_DAMAGE），作用对象为对方玩家（1-tp），预计伤害值为1000；由于不取对象卡，targets参数设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 定义效果处理时的执行函数：从连锁信息中读取之前设定的对象玩家和伤害参数，然后实际造成对应的效果伤害。
function c20438745.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家（对方）和对象参数（1000），作为造成伤害的目标与数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害（REASON_EFFECT）的方式对玩家p造成d点（1000点）基本分伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
