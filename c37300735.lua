--TG ジェット・ファルコン
-- 效果：
-- 这张卡作为同调召唤的素材送去墓地的场合，给与对方基本分500分伤害。
function c37300735.initial_effect(c)
	-- 这张卡作为同调召唤的素材送去墓地的场合，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37300735,0))  --"给予对方500伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c37300735.damcon)
	e1:SetTarget(c37300735.damtg)
	e1:SetOperation(c37300735.damop)
	c:RegisterEffect(e1)
end
-- damcon条件：效果触发时，此卡必须位于墓地，且其离开场上的原因是作为同调召唤的素材（REASON_SYNCHRO）。
function c37300735.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- damtg目标处理：该效果不取对象，因此发动条件直接通过；将对方玩家设为效果对象，登记伤害数值500，并设置连锁的操作信息为对对方造成500点伤害。
function c37300735.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果对象参数设置为500，即后续要造成的伤害数值。
	Duel.SetTargetParam(500)
	-- 登记当前连锁的操作信息：效果分类为伤害效果（CATEGORY_DAMAGE），目标玩家为对方（1-tp），伤害数值为500，用于其他卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- damop处理：从连锁信息中读取目标玩家和伤害参数，对对方造成相应效果伤害。
function c37300735.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中同时获取效果对象玩家（CHAININFO_TARGET_PLAYER）和参数（CHAININFO_TARGET_PARAM），分别赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以REASON_EFFECT（效果）为原因，对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
