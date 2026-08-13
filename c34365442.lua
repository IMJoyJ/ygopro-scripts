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
	-- 这个卡名的①的效果1回合只能使用1次。●以自己场上1只「姬丝基勒」怪兽或者「璃拉」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34365442,1))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,34365442)
	-- 设置攻击力上升效果的发动条件为伤害步骤且尚未进行伤害计算（伤害计算后不能发动）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c34365442.cost1)
	e1:SetTarget(c34365442.target1)
	e1:SetOperation(c34365442.activate1)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。●要让场上的卡破坏的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
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
-- 定义攻击力上升效果的对象筛选条件：属于「姬丝基勒」或「璃拉」系列且表侧表示的怪兽。
function c34365442.tgfilter1(c)
	return c:IsSetCard(0x152,0x153)	and c:IsFaceup()
end
-- 定义解放素材筛选：属于「姬丝基勒/璃拉」系列、原本攻击力大于0、可解放的怪兽，并保证解放后场上存在可成为对象的表侧系列怪兽。
function c34365442.cfilter1(c,tp)
	return c:IsSetCard(0x152,0x153) and c:GetBaseAttack()>0
		and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 确认我方怪兽区存在除解放怪兽以外、满足条件的表侧「姬丝基勒/璃拉」怪兽，确保有对象可选取。
		and Duel.IsExistingTarget(c34365442.tgfilter1,tp,LOCATION_MZONE,0,1,c)
end
-- 『攻击力上升』效果的代价：从自己场上选择1只符合条件的「姬丝基勒/璃拉」怪兽解放，并将其原本攻击力数值存入效果标签。
function c34365442.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上存在至少1只满足解放条件的「姬丝基勒/璃拉」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c34365442.cfilter1,1,nil,tp) end
	-- 玩家选择1只满足条件的「姬丝基勒/璃拉」怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,c34365442.cfilter1,1,1,nil,tp)
	e:SetLabel(sg:GetFirst():GetBaseAttack())
	-- 将选择的怪兽解放（REASON_COST），完成代价支付。
	Duel.Release(sg,REASON_COST)
end
-- 『攻击力上升』效果的目标：从自己场上选择1只表侧表示的「姬丝基勒/璃拉」怪兽作为攻击力上升的对象。
function c34365442.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c34365442.tgfilter1(chkc) end
	if chk==0 then return true end
	-- 发送选择提示消息，提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只表侧表示的「姬丝基勒/璃拉」怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c34365442.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 『攻击力上升』效果处理：若对象仍表侧表示且与本效果关联，则使其攻击力直到回合结束时上升解放怪兽的原本攻击力数值。
function c34365442.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中登记的第1个对象怪兽（即攻击力上升目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升解放的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 『无效破坏效果』的发动条件：当前连锁的效果能够被无效，且该效果不是针对魔法·陷阱卡发动进行无效的无效效果（避免无限循环）。
function c34365442.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁上的效果是否能够被无效，若不能则不能发动。
	if not Duel.IsChainDisablable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 若该效果本身带有无效分类，且其前一个连锁是魔法·陷阱卡的发动，则不满足发动条件（防止无效循环）。
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁效果中关于破坏（CATEGORY_DESTROY）的操作信息，判断该效果是否涉及破坏场上的卡。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- 定义第二个效果的解放素材条件：属于「姬丝基勒/璃拉」系列且可以解放（非战斗破坏确定状态）。
function c34365442.cfilter2(c,tp)
	return c:IsSetCard(0x152,0x153)
		and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 『无效破坏效果』的代价：解放1只符合条件的「姬丝基勒/璃拉」怪兽。
function c34365442.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上存在至少1只满足解放条件的「姬丝基勒/璃拉」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c34365442.cfilter2,1,nil,tp) end
	-- 玩家选择1只符合条件的「姬丝基勒/璃拉」怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,c34365442.cfilter2,1,1,nil,tp)
	-- 将选择的怪兽解放（REASON_COST），完成代价支付。
	Duel.Release(sg,REASON_COST)
end
-- 『无效破坏效果』不需要取对象，发动时仅设置操作信息，指定要无效当前连锁的效果。
function c34365442.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将当前连锁的效果（eg）标记为将要被无效的处理对象。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 『无效破坏效果』处理：使当前连锁上的、会破坏场上卡片的效果无效。
function c34365442.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁编号 ev 的效果无效。
	Duel.NegateEffect(ev)
end
