--仕込み爆弾
-- 效果：
-- ①：给与对方为对方场上的卡数量×300伤害。
-- ②：场上的这张卡被对方破坏送去墓地的场合发动。给与对方1000伤害。
function c18252559.initial_effect(c)
	-- ①：给与对方为对方场上的卡数量×300伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18252559.target)
	e1:SetOperation(c18252559.activate)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被对方破坏送去墓地的场合发动。给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c18252559.damcon)
	e2:SetTarget(c18252559.damtg)
	e2:SetOperation(c18252559.damop)
	c:RegisterEffect(e2)
end
-- 第一个效果的发动时点处理：检查对方场上是否有卡作为发动条件，若有则将对方玩家设为效果对象，计算伤害值（对方场上卡数×300），并将伤害信息登记到连锁操作信息中。
function c18252559.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：对方场上没有卡时该效果不能发动（chk==0且场上卡数为0则返回false）。
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)>0 end
	-- 将当前连锁的效果对象玩家设置为对方玩家（1-tp），使后续效果处理时可获取该对象。
	Duel.SetTargetPlayer(1-tp)
	-- 获取对方场上的卡数量并乘以300，作为将要造成的伤害数值。
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)*300
	-- 登记操作信息：本次连锁处理会以对方玩家为对象造成dam点伤害，供系统用于伤害相关效果的联动判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 第一个效果的实际处理：从连锁信息中取出对象玩家，效果处理时重新计算对方场上的卡数×300，并对对方造成该数值的效果伤害。
function c18252559.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出效果的对象玩家（即之前设置的对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时重新获取对方场上的卡数量并乘以300，得到实际伤害值。
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)*300
	-- 以效果原因对玩家p造成dam点伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
-- 第二个效果的诱发条件判定：这张卡因对方（rp==1-tp）的效果被破坏并送去墓地，且该卡之前位于场上、之前控制者为这张卡的原控制者tp时，条件成立并发动。
function c18252559.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 第二个效果的发动时处理：该效果为必发效果，无需额外检查，直接将对方玩家设为对象、伤害参数设为1000，并登记操作信息。
function c18252559.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设置为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁效果的对象参数为1000，表示随后要造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：本次连锁处理会以对方玩家为对象造成1000点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 第二个效果的处理：从连锁信息中取出对象玩家和伤害参数（1000），并对对方造成该数值的效果伤害。
function c18252559.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中同时取出对象玩家p和对象参数d（即伤害值1000）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
