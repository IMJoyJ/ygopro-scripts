--烈華砲艦ナデシコ
-- 效果：
-- 3星怪兽×3
-- 把这张卡1个超量素材取除才能发动。给与对方基本分对方手卡数量×200的数值的伤害。「烈华炮舰 抚子」的效果1回合只能使用1次。
function c40424929.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可用任意3只3星怪兽叠放进行XYZ召唤（素材数量为3）。
	aux.AddXyzProcedure(c,nil,3,3)
	c:EnableReviveLimit()
	-- 3星怪兽×3；把这张卡1个超量素材取除才能发动。给与对方基本分对方手卡数量×200的数值的伤害。「烈华炮舰 抚子」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40424929,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,40424929)
	e1:SetCost(c40424929.damcost)
	e1:SetTarget(c40424929.damtg)
	e1:SetOperation(c40424929.damop)
	c:RegisterEffect(e1)
end
-- 代价函数：chk==0时为发动前检查能否将移除1个超量素材作为代价；实际发动时移除这张卡的1个超量素材作为代价。
function c40424929.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 目标函数：发动时检查对方是否有手牌，确定对方为对象玩家，并按对方手牌数×200设置伤害的操作信息。
function c40424929.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方手牌数量必须大于0（即对方有手卡时效果才可能发动）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 获取对方当前的手牌数量，保存为变量ct。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 将当前连锁的效果对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息：本次处理为伤害效果，目标玩家为对方，预计伤害数值为ct×200。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
-- 效果处理函数：从连锁信息中取得对象玩家，计算其手牌数量，给对方造成手牌数×200的伤害。
function c40424929.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的对象玩家（即伤害目标玩家），赋给p。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家p当前的手牌数量，赋给ct。
	local ct=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	-- 以效果伤害的方式，给目标玩家p造成ct×200点伤害。
	Duel.Damage(p,ct*200,REASON_EFFECT)
end
