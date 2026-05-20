--メンタル・カウンセラー リリー
-- 效果：
-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，可以支付500基本分让这张卡为同调素材的同调怪兽的攻击力直到这个回合的结束阶段时上升1000。
function c5519829.initial_effect(c)
	-- 这张卡被同调怪兽的同调召唤使用送去墓地的场合，可以支付500基本分让这张卡为同调素材的同调怪兽的攻击力直到这个回合的结束阶段时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5519829,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c5519829.con)
	e1:SetCost(c5519829.cost)
	e1:SetTarget(c5519829.tg)
	e1:SetOperation(c5519829.op)
	c:RegisterEffect(e1)
	-- 建立素材卡与因其召唤出的怪兽之间的关系，以便后续效果处理中能正确获取该同调怪兽
	aux.CreateMaterialReasonCardRelation(c,e1)
end
-- 检查触发条件：自身是否在墓地，且作为素材的原因是否为同调召唤
function c5519829.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 支付500基本分的代价处理
function c5519829.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
-- 效果的目标处理：获取作为素材召唤出的同调怪兽，并将其设为效果处理的对象
function c5519829.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	if chk==0 then return rc:IsRelateToEffect(e) and rc:IsFaceup() end
	-- 将该同调怪兽设置为当前连锁的效果处理对象
	Duel.SetTargetCard(rc)
end
-- 效果的执行处理：使目标同调怪兽的攻击力上升1000，直到回合结束阶段
function c5519829.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取之前设定的目标同调怪兽
	local sync=Duel.GetFirstTarget()
	if not sync:IsRelateToChain() or sync:IsFacedown() then return end
	-- 攻击力直到这个回合的结束阶段时上升1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	sync:RegisterEffect(e1)
end
