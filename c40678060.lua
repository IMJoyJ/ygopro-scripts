--天子の指輪
-- 效果：
-- 有装备卡装备的自己场上的怪兽才能装备。
-- ①：「天子的指轮」在自己场上只能有1张表侧表示存在。
-- ②：对方发动的魔法卡的效果1回合只有1次无效化。
-- ③：1回合1次，这张卡装备中的场合才能发动。自己回复500基本分。那之后，这张卡破坏，以下效果适用。
-- ●只要这张卡装备过的怪兽在怪兽区域表侧表示存在，对方不能把那只怪兽作为效果的对象。
local s,id,o=GetID()
-- 注册“天子的指轮”的装备魔法发动、装备对象限制、场上同名卡唯一、对方魔法无效化、回复/破坏并赋予抗性等全部效果。
function s.initial_effect(c)
	-- 有装备卡装备的自己场上的怪兽才能装备。（装备魔法发动并选择符合条件的怪兽）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 有装备卡装备的自己场上的怪兽才能装备。（装备对象限制，仅允许装备给有装备卡的自己怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	c:SetUniqueOnField(1,0,id)
	-- ②：对方发动的魔法卡的效果1回合只有1次无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，这张卡装备中的场合才能发动。自己回复500基本分。那之后，这张卡破坏，以下效果适用。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_RECOVER+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.rdptg)
	e4:SetOperation(s.rdpop)
	c:RegisterEffect(e4)
end
-- 筛选条件：怪兽必须是自己场上且装备有至少1张装备卡。
function s.filter(c)
	return c:GetEquipCount()>0
end
-- 装备魔法发动时：选择自己场上1只装备有装备卡的怪兽作为对象，并登记将该卡装备给对象的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 发动时合法性检查：不存在满足条件的怪兽时不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示“请选择要装备的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己场上选择1只装备有装备卡的怪兽为对象，并将其锁定为当前连锁的对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记本次效果处理中将进行的“装备”操作：把这张卡装备给所选对象。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：这张卡与对象怪兽仍与效果相关且对象表侧表示时，将这张卡装备给那只怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽（第一目标）。
	local tc=Duel.GetFirstTarget()
	-- 确认关联与表侧表示后，执行装备。
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then Duel.Equip(tp,c,tc) end
end
-- 装备对象限制判定：只能装备给自己控制且已装备有装备卡的怪兽。
function s.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:GetEquipCount()>0
end
-- 无效对方魔法的触发条件：对方玩家发动魔法卡效果且该效果正在连锁处理中。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL)
end
-- 无效处理：展示这张卡并将对方发动的魔法卡效果无效化（1回合1次）。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示“天子的指轮”的卡图，宣告无效效果发动。
	Duel.Hint(HINT_CARD,0,id)
	-- 将当前连锁中的对方魔法卡效果无效化。
	Duel.NegateEffect(ev,true)
end
-- 不取对象，登记回复500LP和破坏这张卡的操作信息，并允许发动。
function s.rdptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：自己回复500基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
	-- 登记操作信息：破坏这张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理：回复500LP成功后破坏这张卡，然后给其装备过的怪兽赋予“不能成为对方效果对象”的抗性。
function s.rdpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 实际回复500LP，并判断回复是否成功（大于0才继续）。
	if Duel.Recover(tp,500,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续破坏和赋予抗性视为不同时点处理。
		Duel.BreakEffect()
		-- 破坏这张卡；若破坏失败则终止后续赋予抗性。
		if Duel.Destroy(c,REASON_EFFECT)<=0 then return end
		-- ●只要这张卡装备过的怪兽在怪兽区域表侧表示存在，对方不能把那只怪兽作为效果的对象。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"「天子的指轮」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetOwnerPlayer(tp)
		e1:SetValue(s.tgval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
-- 抗性判定：效果发动者为这张卡的持有者/控制者的对手玩家时，该怪兽不能成为其效果对象。
function s.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
