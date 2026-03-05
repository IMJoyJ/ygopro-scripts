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
-- 选择宣言种族
function c1525329.armtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家提示选择种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	-- 让玩家宣言一个种族
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
end
-- 将宣言的种族记录到效果标签中
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
-- 战斗的怪兽种族与宣言种族一致时发动
function c1525329.upcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsRace(e:GetLabel())
end
-- 使自身攻击力上升1000
function c1525329.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 攻击上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(1000)
		c:RegisterEffect(e1)
	end
end
