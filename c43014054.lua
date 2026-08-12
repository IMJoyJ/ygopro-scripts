--バイス・バーサーカー
-- 效果：
-- 这张卡作为同调召唤的素材送去墓地的场合，给与那个玩家2000分伤害。此外，这张卡为同调素材的同调怪兽的攻击力直到这个回合的结束阶段时上升2000。
function c43014054.initial_effect(c)
	-- 创建一个诱发必发效果，用于处理作为同调素材时的伤害效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43014054,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c43014054.damcon)
	e1:SetTarget(c43014054.damtg)
	e1:SetOperation(c43014054.damop)
	c:RegisterEffect(e1)
	-- 为效果e1绑定成为素材的触发怪兽，确保能正确识别本次召唤的原因怪兽
	aux.CreateMaterialReasonCardRelation(c,e1)
end
-- 判断该卡是否作为同调召唤的素材被送入墓地
function c43014054.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 设置连锁处理的目标卡片、玩家和参数，准备执行伤害效果
function c43014054.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToEffect(e) and rc:IsFaceup() then
		-- 将触发效果的目标怪兽设置为本次同调召唤所使用的怪兽
		Duel.SetTargetCard(rc)
	end
	-- 将连锁处理的目标玩家设置为该卡的控制者
	Duel.SetTargetPlayer(rp)
	-- 将连锁处理的目标参数设置为2000点伤害
	Duel.SetTargetParam(2000)
	-- 设置本次连锁的操作信息为造成2000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,rp,2000)
end
-- 执行伤害效果并为同调怪兽增加攻击力
function c43014054.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成2000点伤害
	Duel.Damage(p,d,REASON_EFFECT)
	-- 获取本次连锁处理的目标怪兽
	local rc=Duel.GetFirstTarget()
	if rc and rc:IsFaceup() and rc:IsRelateToChain() then
		-- 为该同调怪兽在结束阶段时增加2000点攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(2000)
		rc:RegisterEffect(e1)
	end
end
