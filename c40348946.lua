--ハイパー・シンクロン
-- 效果：
-- 这张卡被龙族怪兽的同调召唤使用送去墓地的场合，这张卡为同调素材的同调怪兽的攻击力上升800，结束阶段时从游戏中除外。
function c40348946.initial_effect(c)
	-- 这张卡被龙族怪兽的同调召唤使用送去墓地的场合，这张卡为同调素材的同调怪兽的攻击力上升800，结束阶段时从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40348946,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c40348946.con)
	e1:SetTarget(c40348946.tg)
	e1:SetOperation(c40348946.op)
	c:RegisterEffect(e1)
	-- 为作为素材的这张卡c登记其与主效果e1之间的关联关系，使以它为素材的同调怪兽能被后续效果正确追踪，从而施加攻击力上升及结束阶段除外。
	aux.CreateMaterialReasonCardRelation(c,e1)
end
-- 效果发动条件：这张卡作为同调素材被送去墓地后位于墓地、那次同调召唤的原因为REASON_SYNCHRO，并且因同调召唤出场的同调怪兽是龙族。
function c40348946.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and c:GetReasonCard():IsRace(RACE_DRAGON)
end
-- 效果目标选择：取得这次同调召唤所出场的同调怪兽rc，若它仍与效果相关且表侧表示，则在发动确认阶段返回true并将其设为效果处理时要涉及的对象。
function c40348946.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	if chk==0 then return rc:IsRelateToEffect(e) and rc:IsFaceup() end
	-- 将同调怪兽rc登记为当前连锁处理的对象，便于后续通过Duel.GetFirstTarget()取得该怪兽。
	Duel.SetTargetCard(rc)
end
-- 效果处理：若作为对象的同调怪兽仍与连锁相关、表侧表示且不免疫此效果，则给它注册攻击力上升800的效果，并为其放置标识；同时为当前玩家场上注册一个在结束阶段进行除外的持续效果e2。
function c40348946.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中之前被设为对象的同调怪兽sync。
	local sync=Duel.GetFirstTarget()
	if not sync:IsRelateToChain() or sync:IsFacedown() or sync:IsImmuneToEffect(e) then return end
	-- 这张卡为同调素材的同调怪兽的攻击力上升800
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sync:RegisterEffect(e1)
	sync:RegisterFlagEffect(40348946,RESET_EVENT+RESETS_STANDARD,0,1)
	-- 结束阶段时从游戏中除外
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCountLimit(1)
	e2:SetLabelObject(sync)
	e2:SetCondition(c40348946.rmcon)
	e2:SetOperation(c40348946.rmop)
	-- 将结束阶段除外的持续效果e2注册到当前玩家场上，使其在结束阶段检查并执行对应除外。
	Duel.RegisterEffect(e2,tp)
end
-- 结束阶段除外效果的条件：记录的同调怪兽仍带有本效果设置的标识时条件成立；若标识已消失，则重置该持续效果并返回false。
function c40348946.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(40348946)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行结束阶段除外：取得记录的同调怪兽tc，并将其除外。
function c40348946.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将同调怪兽tc以表侧表示除外，处理原因为效果。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
