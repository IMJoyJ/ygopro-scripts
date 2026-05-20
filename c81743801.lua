--竜王キング・レックス
-- 效果：
-- ①：这张卡的攻击破坏对方怪兽时才能发动。这次战斗阶段中，这张卡只再1次可以攻击。
-- ②：这张卡在这个回合没有召唤·反转召唤·特殊召唤的场合，1回合1次，以对方场上最多2只怪兽为对象才能发动。那些怪兽破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含效果①（战破追加攻击）和效果②（未召唤回合起动破坏）。
function s.initial_effect(c)
	-- ①：这张卡的攻击破坏对方怪兽时才能发动。这次战斗阶段中，这张卡只再1次可以攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在这个回合没有召唤·反转召唤·特殊召唤的场合，1回合1次，以对方场上最多2只怪兽为对象才能发动。那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：此卡作为攻击怪兽，且通过战斗破坏了对方怪兽。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击怪兽是否为自身，且自身在战斗中破坏了对方怪兽。
	return Duel.GetAttacker()==e:GetHandler() and aux.bdocon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果①的发动目标：检查自身是否仍处于战斗中，且当前未获得追加攻击效果。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsRelateToBattle() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
-- 效果①的效果处理：给自身添加在本次战斗阶段中可以再进行1次攻击的效果。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsRelateToBattle() or not c:IsFaceup() then return end
	-- 这次战斗阶段中，这张卡只再1次可以攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	c:RegisterEffect(e1)
end
-- 效果②的发动条件：这张卡在当前回合没有进行过通常召唤、反转召唤或特殊召唤。
function s.condition(e)
	return not e:GetHandler():IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
-- 效果②的发动目标：选择对方场上最多2只怪兽作为破坏对象并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1只可以作为对象选择的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1到2只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,2,nil)
	-- 设置效果处理信息，表明此连锁将破坏所选的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果②的效果处理：将仍存在于场上的对象怪兽破坏。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在连锁处理时仍然符合对象条件的卡片。
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 将这些目标怪兽因效果破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
