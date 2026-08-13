--バイス・バーサーカー
-- 效果：
-- 这张卡作为同调召唤的素材送去墓地的场合，给与那个玩家2000分伤害。此外，这张卡为同调素材的同调怪兽的攻击力直到这个回合的结束阶段时上升2000。
function c43014054.initial_effect(c)
	-- 这张卡作为同调召唤的素材送去墓地的场合，给与那个玩家2000分伤害。此外，这张卡为同调素材的同调怪兽的攻击力直到这个回合的结束阶段时上升2000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43014054,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c43014054.damcon)
	e1:SetTarget(c43014054.damtg)
	e1:SetOperation(c43014054.damop)
	c:RegisterEffect(e1)
	-- 为作为素材的卡c注册其与效果e1之间的关联关系，使这张卡被用作同调素材时能正确关联到利用该素材的效果，以便该同调怪兽能继承并获得攻击力上升等相关效果。
	aux.CreateMaterialReasonCardRelation(c,e1)
end
-- 伤害诱发效果的发动条件：效果持有者（这张卡）当前位于墓地，且本次作为同调召唤的素材（r==REASON_SYNCHRO），即“作为同调召唤的素材送去墓地的场合”。
function c43014054.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 伤害效果的发动时点处理：可用时返回true；取得导致这张卡位置变化的那只同调怪兽，若其与效果e1相关联且表侧表示则将其登记为连锁对象；将对象玩家设为rp（同调怪兽的控制者），伤害数值设为2000，并设置操作信息为对rp造成2000伤害。
function c43014054.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToEffect(e) and rc:IsFaceup() then
		-- 把当前连锁的对象卡片设定为那只同调怪兽，供后续处理时取得该怪兽（用于给其攻击力上升）。
		Duel.SetTargetCard(rc)
	end
	-- 把当前连锁的对象玩家设定为rp，即使用这张卡进行同调召唤的玩家，指定其承受2000分伤害。
	Duel.SetTargetPlayer(rp)
	-- 把当前连锁的对象参数设定为2000，指定伤害数值为2000。
	Duel.SetTargetParam(2000)
	-- 设置操作信息，声明本连锁将造成2000点效果伤害，伤害对象为玩家rp；targets设为nil（因为对象是玩家），count为0，供其他卡进行效果响应检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,rp,2000)
end
-- 效果处理：从连锁信息中取出对象玩家和伤害数值，给予其2000点效果伤害；然后取出之前登记的同调怪兽，若它仍表侧表示且与本连锁相关，则给它注册一个攻击力直到结束阶段上升2000的效果。
function c43014054.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家（伤害承受者）和对象参数（伤害数值），分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点伤害，reason为效果，即实际执行给与2000分伤害。
	Duel.Damage(p,d,REASON_EFFECT)
	-- 取得当前连锁的对象卡，即作为素材同调召唤出来的那只同调怪兽，以便后续判断并给予其攻击力上升效果。
	local rc=Duel.GetFirstTarget()
	if rc and rc:IsFaceup() and rc:IsRelateToChain() then
		-- 此外，这张卡为同调素材的同调怪兽的攻击力直到这个回合的结束阶段时上升2000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(2000)
		rc:RegisterEffect(e1)
	end
end
