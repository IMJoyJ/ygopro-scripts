--CX ダーク・フェアリー・チア・ガール
-- 效果：
-- 5星怪兽×3
-- 这张卡从场上送去墓地时，从卡组抽1张卡。此外，这张卡有「妖精啦啦队少女」在作为超量素材的场合，得到以下效果。
-- ●这张卡战斗破坏对方怪兽时，把这张卡1个超量素材取除才能发动。给与对方基本分自己手卡数量×400的数值的伤害。
function c23454876.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：将等级5的任意怪兽3只作为超量素材叠放，对应“5星怪兽×3”的召唤条件。
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- 这张卡从场上送去墓地时，从卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetDescription(aux.Stringid(23454876,0))  --"抽卡"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c23454876.drcon)
	e1:SetTarget(c23454876.drtg)
	e1:SetOperation(c23454876.drop)
	c:RegisterEffect(e1)
	-- ●这张卡战斗破坏对方怪兽时，把这张卡1个超量素材取除才能发动。给与对方基本分自己手卡数量×400的数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetDescription(aux.Stringid(23454876,1))  --"LP伤害"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c23454876.damcon)
	e2:SetCost(c23454876.damcost)
	e2:SetTarget(c23454876.damtg)
	e2:SetOperation(c23454876.damop)
	c:RegisterEffect(e2)
end
-- 抽卡效果的发动条件：判断这张卡之前所在位置是否为场上，即满足“这张卡从场上送去墓地时”的触发时机。
function c23454876.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 抽卡效果的目标与发动信息设定：效果发动时无需选择对象，将对象玩家设为自己、抽卡数设为1，并登记抽卡效果的操作信息。
function c23454876.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为发动玩家自己，表明由这张卡的持有者抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置本次效果的操作信息为抽卡效果：目标玩家为发动方自己（tp），预计处理时抽卡数量为1，供“抽卡时不抽卡”等相关效果判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际处理：从连锁信息中取出之前设定的对象玩家和抽卡数量，并让该玩家抽相应数量的卡。
function c23454876.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取对象玩家和对象参数，分别赋给变量p（抽卡玩家）和d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 伤害效果的发动条件：这张卡的超量素材中存在卡号51960178（即「妖精啦啦队少女」），并且这张卡在战斗破坏对方怪兽的相关战斗中作为正面战斗怪兽参与。
function c23454876.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡的超量素材组中是否存在卡号51960178的「妖精啦啦队少女」，且通过aux.bdocon确认该卡与本次战斗破坏对方怪兽的事件相关，并且是攻击方（与对方怪兽战斗）。
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,51960178) and aux.bdocon(e,tp,eg,ep,ev,re,r,rp)
end
-- 伤害效果的代价处理：发动时移除这张卡的1个超量素材作为代价；先检查能否移除，能则实际执行移除。
function c23454876.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 伤害效果的目标设定：选择对方玩家作为受伤害对象，并计算伤害值为自己手卡数量×400，然后登记伤害效果的操作信息。
function c23454876.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp），确定给与对方基本分伤害。
	Duel.SetTargetPlayer(1-tp)
	-- 计算伤害值：自己手牌数量（tp方手牌区）乘以400，得到将给与对方的伤害数值。
	local dam=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*400
	-- 将计算得到的伤害值设定为当前连锁的对象参数，供效果处理时读取。
	Duel.SetTargetParam(dam)
	-- 设置本次效果的操作信息为伤害效果：目标玩家为对方（1-tp），伤害数值为dam，用于连锁判定与相关效果响应。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的实际处理：获取之前设定的对象玩家，并重新计算当前手牌数×400的伤害值，对对方造成伤害。
function c23454876.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家（对方玩家）作为伤害对象。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在效果处理阶段重新计算伤害值：此时自己手卡数量×400，确保与实际手牌数一致。
	local dam=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*400
	-- 给与玩家p以效果原因（REASON_EFFECT）造成dam点伤害，即完成“给与对方基本分自己手卡数量×400的数值的伤害”的处理。
	Duel.Damage(p,dam,REASON_EFFECT)
end
