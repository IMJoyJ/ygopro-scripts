--7つの武器を持つハンター
-- 效果：
-- 这张卡召唤成功时，宣言1个种族发动。这张卡和宣言的种族的怪兽进行战斗的场合，这张卡的攻击力只在伤害计算时上升1000。
function c1525329.initial_effect(c)
	-- 这张卡召唤成功时，宣言1个种族发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1525329,0))  --"宣言种族"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c1525329.armtg)
	e1:SetOperation(c1525329.armop)
	c:RegisterEffect(e1)
end
-- 此为召唤成功时的诱发必发效果的Target函数：chk==0时直接允许发动；chk==1时提示玩家宣言1个种族，并将宣言结果存入Label，供后续效果处理使用。
function c1525329.armtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 发送“请选择要宣言的种族”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让当前玩家从全种族中宣言1个种族，返回值为所宣言的种族。
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
end
-- 召唤成功效果的发动处理：若这张卡仍与效果相关且表侧表示，则取其宣言种族并设置种族提示，然后为这张卡注册一个在伤害计算时触发的攻击力上升效果。
function c1525329.armop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local rc=e:GetLabel()
		e:GetHandler():SetHint(CHINT_RACE,rc)
		-- 这张卡和宣言的种族的怪兽进行战斗的场合，这张卡的攻击力只在伤害计算时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(1525329,1))  --"攻击上升"
		e1:SetCategory(CATEGORY_ATKCHANGE)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
		e1:SetCondition(c1525329.upcon)
		e1:SetOperation(c1525329.upop)
		e1:SetLabel(rc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 判定条件：这张卡正在与怪兽战斗，且该怪兽的种族与宣言的种族一致。
function c1525329.upcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsRace(e:GetLabel())
end
-- 伤害计算时的效果处理：若这张卡仍与效果相关且表侧表示，则给自己临时赋予攻击力上升1000的效果，该效果仅在本次伤害计算阶段内有效。
function c1525329.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力只在伤害计算时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(1000)
		c:RegisterEffect(e1)
	end
end
