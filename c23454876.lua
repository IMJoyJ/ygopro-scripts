--CX ダーク・フェアリー・チア・ガール
-- 效果：
-- 5星怪兽×3
-- 这张卡从场上送去墓地时，从卡组抽1张卡。此外，这张卡有「妖精啦啦队少女」在作为超量素材的场合，得到以下效果。
-- ●这张卡战斗破坏对方怪兽时，把这张卡1个超量素材取除才能发动。给与对方基本分自己手卡数量×400的数值的伤害。
function c23454876.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为5的怪兽3只作为素材
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- 这张卡从场上送去墓地时，从卡组抽1张卡
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
	-- 这张卡战斗破坏对方怪兽时，把这张卡1个超量素材取除才能发动。给与对方基本分自己手卡数量×400的数值的伤害。
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
-- 效果发动条件：这张卡是从场上送去墓地
function c23454876.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置抽卡效果的目标玩家和抽卡数量
function c23454876.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1张卡
	Duel.SetTargetParam(1)
	-- 设置效果的操作信息为抽卡效果，抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数：执行抽卡操作
function c23454876.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，抽1张卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 效果发动条件：这张卡有「妖精啦啦队少女」在作为超量素材的场合，并且与对方怪兽战斗破坏
function c23454876.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有「妖精啦啦队少女」作为超量素材，并且满足战斗破坏条件
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,51960178) and aux.bdocon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果发动费用：去除1个超量素材
function c23454876.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置伤害效果的目标玩家和伤害值
function c23454876.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 计算手卡数量乘以400作为伤害值
	local dam=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*400
	-- 设置效果的目标参数为计算出的伤害值
	Duel.SetTargetParam(dam)
	-- 设置效果的操作信息为伤害效果，对对方造成指定伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理函数：执行伤害效果
function c23454876.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算手卡数量乘以400作为伤害值
	local dam=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*400
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
