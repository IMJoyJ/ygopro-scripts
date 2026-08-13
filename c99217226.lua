--結束と絆の超魔導剣士
-- 效果：
-- 调整＋调整以外的原本攻击力和原本守备力是2500的怪兽1只以上
-- ①：只要同调召唤的这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：只要自己墓地有卡25张以上存在，同调召唤的这张卡的攻击力·守备力上升双方的场上·墓地的卡数量×100。
-- ③：1回合1次，对方墓地有卡25张以上存在，魔法卡发动时才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 注册卡片全部效果：添加同调召唤手续（调整+调整以外原本攻守2500的怪兽1只以上），并注册①的对效果破坏/取对象抗性、②的攻防上升、③的魔法发动无效并破坏。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整以外的怪兽必须满足s.synfilter（原本攻击力和守备力均为2500），且数量为1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(s.synfilter),1)
	c:EnableReviveLimit()
	-- ①：只要同调召唤的这张卡在怪兽区域存在，这张卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	-- 设置“不会被对方的效果破坏”的判定函数：当效果来自对方时返回true。
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ①：只要同调召唤的这张卡在怪兽区域存在，对方不能把这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.indcon)
	-- 设置“不能成为对方效果对象”的判定函数：当效果来自对方时返回true。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：只要自己墓地有卡25张以上存在，同调召唤的这张卡的攻击力·守备力上升双方的场上·墓地的卡数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- ③：1回合1次，对方墓地有卡25张以上存在，魔法卡发动时才能发动。那个发动无效并破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))  --"发动无效"
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.negcon)
	e5:SetTarget(s.negtg)
	e5:SetOperation(s.negop)
	c:RegisterEffect(e5)
end
-- 条件函数：判断该卡是否为同调召唤状态（用于限制①的抗性和②的攻防上升仅在同调召唤后适用）。
function s.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 同调素材过滤：调整以外的怪兽必须是原本攻击力和原本守备力都为2500的怪兽。
function s.synfilter(c)
	return c:GetBaseAttack()==2500 and c:GetBaseDefense()==2500
end
-- ②的适用条件：该卡为同调召唤，并且自己墓地有25张以上的卡。
function s.atkcon(e)
	local c=e:GetHandler()
	-- 条件判断：该卡是同调召唤，且自己墓地卡数≥25。
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_GRAVE,0)>=25
end
-- 计算攻击力上升值的函数：双方场上和墓地的卡总数×100。
function s.atkval(e,c)
	-- 返回攻击力上升数值：双方的场上·墓地的卡数量×100。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD)*100
end
-- ③的发动条件：对方墓地有25张以上卡，且本次连锁为魔法卡的发动（可被无效），同时该卡不是战斗破坏确定状态。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 条件细节：对方墓地≥25；发动的是魔法卡（EFFECT_TYPE_ACTIVATE）；该连锁可以被无效。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=25 and re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- ③的发动时处理：无取对象，登记“无效发动”的操作信息；若该魔法卡可被破坏且与效果关联，则同时登记“破坏”操作信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记将连锁上的魔法卡的发动无效（CATEGORY_NEGATE）的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记将连锁上的魔法卡破坏（CATEGORY_DESTROY）的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效那个魔法卡的发动，若该卡仍在连锁上且与效果关联，则将其破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查无效发动是否成功，且该魔法卡仍与所发动的效果相关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将那张被无效发动的魔法卡破坏（因效果破坏）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
