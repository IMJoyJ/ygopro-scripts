--機動石器ドグラード
-- 效果：
-- 包含岩石族怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己墓地1只岩石族怪兽为对象才能发动。这张卡的攻击力上升作为对象的怪兽的攻击力数值。
-- ②：对方主要阶段，以持有这张卡的攻击力以下的攻击力的场上1只其他怪兽为对象才能发动。这张卡的攻击力下降作为对象的怪兽的攻击力数值，作为对象的怪兽破坏。
local s,id,o=GetID()
-- 初始化怪兽的全部效果：设置连接召唤条件（2只以上且含岩石族）、苏生限制，以及①特殊召唤时上升攻击力的诱发选发效果和②对方主要阶段下降攻击力并破坏的诱发即时效果。
function s.initial_effect(c)
	-- 为这张卡添加连接召唤手续：必须以2只以上怪兽为连接素材，且其中至少包含1只岩石族怪兽（由s.lcheck判定）。
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以自己墓地1只岩石族怪兽为对象才能发动。这张卡的攻击力上升作为对象的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段，以持有这张卡的攻击力以下的攻击力的场上1只其他怪兽为对象才能发动。这张卡的攻击力下降作为对象的怪兽的攻击力数值，作为对象的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力下降并破坏"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 连接素材的额外筛选函数：判定候选连接素材组g中是否存在至少1只岩石族怪兽，用于满足“包含岩石族怪兽”的连接素材要求。
function s.lcheck(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_ROCK)
end
-- ①效果选择墓地岩石族怪兽的过滤函数：对象必须是岩石族怪兽，且攻击力在1以上。
function s.atkfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAttackAbove(1)
end
-- ①效果的取对象处理：进行对象合法性检查和存在性检查，并选择自己墓地1只岩石族怪兽作为效果对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and s.atkfilter(chk) end
	-- 效果发动前的存在性检查：确认自己墓地存在至少1只满足条件的岩石族怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择效果的对象”的提示信息，用于选择①效果对象的交互提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地选择1只岩石族怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- ①效果处理：若这张卡仍表侧表示且与效果有关联，对象仍与效果有关联，则让这张卡的攻击力上升对象怪兽攻击力的数值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升作为对象的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件函数：只有当前回合是对方回合且处于主要阶段时，才允许发动。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方主要阶段：当前回合玩家不是这张卡的控制者，且处于主要阶段。
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- ②效果选择对象的过滤函数：对象需表侧表示，攻击力在1以上且不超过这张卡当前的攻击力。
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsAttackAbove(1)
end
-- ②效果的取对象处理：进行对象合法性检查和存在性检查，选择场上1只攻击力不高于这张卡当前攻击力的其他表侧怪兽，并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,atk) end
	-- 效果发动前的存在性检查：确认场上存在至少1只满足条件的其他表侧怪兽（攻击力不高于本卡攻击力），否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,atk) end
	-- 向玩家显示“请选择要破坏的卡”的提示信息，用于选择②效果破坏对象的交互提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1只满足条件的其他表侧怪兽（除本卡外）作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,atk)
	-- 登记效果处理的破坏操作信息：将选中的对象作为即将被效果破坏的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理前的合法性检查：若这张卡已里侧表示、或与效果失去关联、或当前攻击力小于对象攻击力，或对象已不在场/与效果失去关联/非表侧怪兽/攻击力不足，则本次效果不处理。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetAttack()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:GetAttack()<atk
		or not tc:IsRelateToEffect(e) or not tc:IsFaceup() or not tc:IsType(TYPE_MONSTER) or atk<=0 then
		return
	end
	-- 这张卡的攻击力下降作为对象的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-atk)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) and tc:IsRelateToEffect(e) then
		-- 以效果破坏对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
