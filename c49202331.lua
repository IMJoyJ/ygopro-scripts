--CX 超巨大空中要塞バビロン
-- 效果：
-- 11星怪兽×3
-- 这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏的怪兽的原本攻击力一半数值的伤害。此外，这张卡有「超巨大空中宫殿 钟声协和号」在作为超量素材的场合，得到以下效果。
-- ●这张卡战斗破坏怪兽的场合，可以通过把这张卡1个超量素材取除，只再1次可以继续攻击。这个效果1回合只能使用1次。
function c49202331.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以3只11星怪兽为素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,11,3)
	c:EnableReviveLimit()
	-- 这张卡战斗破坏怪兽送去墓地时，给与对方基本分破坏的怪兽的原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49202331,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置伤害效果的发动条件：仅当这张卡战斗破坏怪兽并将其送去墓地时才会触发。
	e1:SetCondition(aux.bdgcon)
	e1:SetTarget(c49202331.damtg)
	e1:SetOperation(c49202331.damop)
	c:RegisterEffect(e1)
	-- 此外，这张卡有「超巨大空中宫殿 钟声协和号」在作为超量素材的场合，得到以下效果。●这张卡战斗破坏怪兽的场合，可以通过把这张卡1个超量素材取除，只再1次可以继续攻击。这个效果1回合只能使用1次。
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
-- 伤害效果的发动判定与信息记录：把被战斗破坏的怪兽设为对象，计算其原本攻击力一半（向下取整且最低为0）作为伤害值，指定对方为对象玩家，并写入伤害效果的操作信息。
function c49202331.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	-- 将被这张卡战斗破坏的那只怪兽设置为连锁对象，以便后续根据其攻击力计算伤害并确认关联。
	Duel.SetTargetCard(bc)
	local dam=math.floor(bc:GetAttack()/2)
	if dam<0 then dam=0 end
	-- 将伤害的对象玩家设置为对方玩家（1-tp），表示此伤害由对方承受。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的伤害数值参数设置为计算出的dam，供后续效果处理时使用。
	Duel.SetTargetParam(dam)
	-- 设置效果操作信息：声明本连锁将造成CATEGORY_DAMAGE的伤害，对象玩家为对方，伤害量为dam；对象卡暂不指定（nil），参数为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的实际处理：确认对象卡仍与效果关联后，从连锁信息取出对象玩家和伤害值，对对方造成效果伤害。
function c49202331.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出先前设置的对象卡（被战斗破坏的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 从当前连锁信息中取得对象玩家（即伤害承受方）。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=math.floor(tc:GetAttack()/2)
		if dam<0 then dam=0 end
		-- 向玩家p造成dam点伤害，伤害原因为效果（REASON_EFFECT）。
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
-- 连续攻击效果的发动条件：此卡本次战斗破坏怪兽且仍可继续攻击，并且超量素材中含有卡号3814632（超巨大空中宫殿 钟声协和号）。
function c49202331.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定此卡确实与本次战斗有关且还可继续攻击，满足连续攻击效果的发动前提。
	return aux.bdcon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable()
		and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,3814632)
end
-- 连续攻击效果的发动代价：检查并从这张卡上取除1个超量素材。
function c49202331.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 连续攻击效果的处理：使这张卡在本次战斗阶段中获得一次额外的攻击机会。
function c49202331.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使此卡可以再进行一次攻击（追加一次攻击）。
	Duel.ChainAttack()
end
