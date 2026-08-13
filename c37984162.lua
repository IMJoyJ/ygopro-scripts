--ゴルゴニック・ゴーレム
-- 效果：
-- 这张卡被战斗破坏送去墓地时，让把这张卡破坏的怪兽的攻击力变成0。此外，自己的主要阶段时，把墓地的这张卡从游戏中除外，选择对方场上盖放的1张魔法·陷阱卡才能发动。这个回合，选择的卡不能发动。对方不能对应这个效果的发动把选择的卡发动。
function c37984162.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，让把这张卡破坏的怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37984162,0))  --"攻击变成0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c37984162.condition)
	e1:SetOperation(c37984162.operation)
	c:RegisterEffect(e1)
	-- 此外，自己的主要阶段时，把墓地的这张卡从游戏中除外，选择对方场上盖放的1张魔法·陷阱卡才能发动。这个回合，选择的卡不能发动。对方不能对应这个效果的发动把选择的卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37984162,1))  --"发动限制"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果的发动代价：把墓地的这张卡从游戏中除外（aux.bfgcost为除外自身作为cost的通用函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c37984162.distg)
	e2:SetOperation(c37984162.disop)
	c:RegisterEffect(e2)
end
-- 效果1的发动条件：自身必须在墓地、因战斗被破坏，且破坏这张卡的怪兽仍与本次战斗相关联（保证后续能正确选取并把攻击力变0）。
function c37984162.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		and e:GetHandler():GetReasonCard():IsRelateToBattle()
end
-- 效果1的处理：取得破坏这张卡的怪兽，若其表侧表示且与本次战斗关联，则给它附加攻击力变成0的效果。
function c37984162.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsFaceup() and rc:IsRelateToBattle() then
		-- 让把这张卡破坏的怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
-- 效果2的目标选择与连锁限制：选择对方场上1张里侧表示的魔法·陷阱卡作为对象，并设置连锁限制使对方不能对应发动该选择的卡。
function c37984162.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	-- 在效果发动合法检查时，确认对方魔法·陷阱区存在至少1张里侧表示的卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
	-- 向操作玩家显示选择提示：请选择里侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 让玩家从对方魔法·陷阱区选择1张里侧表示的卡作为对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置本次效果的连锁限制，使被选中的那张卡（或其效果）不能被对方连锁发动。
	Duel.SetChainLimit(c37984162.limit(g:GetFirst()))
end
-- 返回一个连锁限制函数：若连锁上的效果持有者是被选择的卡（即该卡本身试图发动效果），则不允许其连锁。这是为了禁止对方对应本效果发动被选择的卡。
function c37984162.limit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
-- 效果2的处理：取得对象卡，若其仍为里侧表示且与效果相关联，则给它附加‘不能发动效果’的限制，直到回合结束，实现‘这个回合，选择的卡不能发动’。
function c37984162.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡，即之前选择的对方场上里侧表示的魔法·陷阱卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 这个回合，选择的卡不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
