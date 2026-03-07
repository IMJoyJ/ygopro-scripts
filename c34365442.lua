--Evil★Twin イージーゲーム
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以把自己场上1只「姬丝基勒」怪兽或者「璃拉」怪兽解放，从以下效果选择1个发动。
-- ●以自己场上1只「姬丝基勒」怪兽或者「璃拉」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
-- ●要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
function c34365442.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 以自己场上1只「姬丝基勒」怪兽或者「璃拉」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34365442,1))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,34365442)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c34365442.cost1)
	e1:SetTarget(c34365442.target1)
	e1:SetOperation(c34365442.activate1)
	c:RegisterEffect(e1)
	-- 要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34365442,2))  --"无效破坏效果"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,34365442)
	e3:SetCondition(c34365442.condition2)
	e3:SetCost(c34365442.cost2)
	e3:SetTarget(c34365442.target2)
	e3:SetOperation(c34365442.activate2)
	c:RegisterEffect(e3)
end
-- 过滤目标怪兽，必须是「姬丝基勒」或「璃拉」卡组且表侧表示。
function c34365442.tgfilter1(c)
	return c:IsSetCard(0x152,0x153)	and c:IsFaceup()
end
-- 过滤可解放的怪兽，必须是「姬丝基勒」或「璃拉」卡组且有攻击力、表侧表示或控制者为玩家、未战斗破坏、且场上存在满足条件的目标怪兽。
function c34365442.cfilter1(c,tp)
	return c:IsSetCard(0x152,0x153) and c:GetBaseAttack()>0
		and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查场上是否存在满足条件的目标怪兽。
		and Duel.IsExistingTarget(c34365442.tgfilter1,tp,LOCATION_MZONE,0,1,c)
end
-- 检查并选择满足条件的怪兽进行解放，将解放怪兽的原本攻击力设为效果标签值。
function c34365442.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c34365442.cfilter1,1,nil,tp) end
	-- 选择满足条件的怪兽进行解放。
	local sg=Duel.SelectReleaseGroup(tp,c34365442.cfilter1,1,1,nil,tp)
	e:SetLabel(sg:GetFirst():GetBaseAttack())
	-- 将选中的怪兽进行解放。
	Duel.Release(sg,REASON_COST)
end
-- 选择目标怪兽，用于攻击力上升效果。
function c34365442.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34365442.tgfilter1(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的目标怪兽。
	Duel.SelectTarget(tp,c34365442.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将目标怪兽的攻击力提升等于解放怪兽的原本攻击力。
function c34365442.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建攻击力提升效果并注册到目标怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断连锁效果是否可以被无效。
function c34365442.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁效果是否可以被无效。
	if not Duel.IsChainDisablable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 排除连锁效果为永续魔法发动时的无效处理。
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取连锁效果的破坏信息。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 过滤可解放的怪兽，必须是「姬丝基勒」或「璃拉」卡组且表侧表示或控制者为玩家、未战斗破坏。
function c34365442.cfilter2(c,tp)
	return c:IsSetCard(0x152,0x153)
		and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 检查并选择满足条件的怪兽进行解放。
function c34365442.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c34365442.cfilter2,1,nil,tp) end
	-- 选择满足条件的怪兽进行解放。
	local sg=Duel.SelectReleaseGroup(tp,c34365442.cfilter2,1,1,nil,tp)
	-- 将选中的怪兽进行解放。
	Duel.Release(sg,REASON_COST)
end
-- 设置操作信息，用于无效效果。
function c34365442.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要无效一个效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 使连锁效果无效。
function c34365442.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前处理的连锁效果无效。
	Duel.NegateEffect(ev)
end
