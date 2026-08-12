--CX 超巨大空中要塞バビロン
-- 效果：
-- 11星怪兽×3
-- 这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏的怪兽的原本攻击力一半数值的伤害。此外，这张卡有「超巨大空中宫殿 钟声协和号」在作为超量素材的场合，得到以下效果。
-- ●这张卡战斗破坏怪兽的场合，可以通过把这张卡1个超量素材取除，只再1次可以继续攻击。这个效果1回合只能使用1次。
function c49202331.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为11的怪兽3只进行叠放
	aux.AddXyzProcedure(c,nil,11,3)
	c:EnableReviveLimit()
	-- 这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏的怪兽的原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49202331,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测当前怪兽是否参与了战斗破坏对方怪兽的事件
	e1:SetCondition(aux.bdgcon)
	e1:SetTarget(c49202331.damtg)
	e1:SetOperation(c49202331.damop)
	c:RegisterEffect(e1)
	-- 此外，这张卡有「超巨大空中宫殿 钟声协和号」在作为超量素材的场合，得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49202331,1))  --"连续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1)
	e2:SetCondition(c49202331.atcon)
	e2:SetCost(c49202331.atcost)
	e2:SetOperation(c49202331.atop)
	c:RegisterEffect(e2)
end
-- 设置伤害计算函数，确定目标怪兽并计算伤害值
function c49202331.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将被战斗破坏的怪兽设为连锁处理对象
	Duel.SetTargetCard(bc)
	local dam=math.floor(bc:GetAttack()/2)
	if dam<0 then dam=0 end
	-- 设定伤害接受方为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设定伤害值参数
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息，指定伤害效果类别和目标参数
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行伤害处理函数，对目标玩家造成相应伤害
function c49202331.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的处理对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 从连锁信息中获取目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=math.floor(tc:GetAttack()/2)
		if dam<0 then dam=0 end
		-- 对目标玩家造成指定数值的伤害
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
-- 设置连续攻击效果的触发条件，包括战斗破坏、可连续攻击及存在特定超量素材
function c49202331.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测当前怪兽是否参与了战斗破坏对方怪兽的事件并判断是否可以进行连续攻击
	return aux.bdcon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable()
		and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,3814632)
end
-- 设置消耗超量素材的函数，检查并移除一张超量素材
function c49202331.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置连续攻击效果的操作函数，使当前攻击怪兽可再进行一次攻击
function c49202331.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前攻击怪兽可再进行一次攻击
	Duel.ChainAttack()
end
