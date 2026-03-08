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
	-- 为成为素材的卡片与其对应的素材触发效果建立关联，确保在效果处理期间能够正确识别并获取本次召唤所使用的原因怪兽。
	aux.CreateMaterialReasonCardRelation(c,e1)
end
-- 效果条件：这张卡在墓地且因同调召唤成为素材，且使它成为素材的怪兽为龙族。
function c40348946.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and c:GetReasonCard():IsRace(RACE_DRAGON)
end
-- 效果目标：设置使这张卡成为素材的同调怪兽为效果目标。
function c40348946.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	if chk==0 then return rc:IsRelateToEffect(e) and rc:IsFaceup() end
	-- 将目标怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(rc)
end
-- 效果处理：若目标怪兽存在于连锁中且正面表示且未被效果免疫，则给该怪兽增加800攻击力，并注册结束阶段除外效果。
function c40348946.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果目标，即使这张卡成为素材的同调怪兽。
	local sync=Duel.GetFirstTarget()
	if not sync:IsRelateToChain() or sync:IsFacedown() or sync:IsImmuneToEffect(e) then return end
	-- 使目标怪兽的攻击力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sync:RegisterEffect(e1)
	sync:RegisterFlagEffect(40348946,RESET_EVENT+RESETS_STANDARD,0,1)
	-- 在结束阶段时从游戏中除外目标怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCountLimit(1)
	e2:SetLabelObject(sync)
	e2:SetCondition(c40348946.rmcon)
	e2:SetOperation(c40348946.rmop)
	-- 将结束阶段除外效果注册到场上。
	Duel.RegisterEffect(e2,tp)
end
-- 判断目标怪兽是否已注册flag，若已注册则继续执行除外操作。
function c40348946.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(40348946)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
-- 将目标怪兽从游戏中除外。
function c40348946.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因将目标怪兽从游戏中除外。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
end
