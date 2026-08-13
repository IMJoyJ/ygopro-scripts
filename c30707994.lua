--マキシマム・シックス
-- 效果：
-- 这张卡祭品召唤成功时，丢1个骰子。只要这张卡在场上表侧表示存在，这张卡的攻击力上升丢出骰子数×200的攻击力。
function c30707994.initial_effect(c)
	-- 这张卡祭品召唤成功时，丢1个骰子。只要这张卡在场上表侧表示存在，这张卡的攻击力上升丢出骰子数×200的攻击力。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30707994,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c30707994.condition)
	e1:SetTarget(c30707994.target)
	e1:SetOperation(c30707994.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否为上级召唤（祭品召唤）成功。
function c30707994.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果发动时无需选择对象，直接允许发动，并设置进行掷骰子的操作信息。
function c30707994.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次效果包含掷骰子（CATEGORY_DICE）操作，由玩家tp掷1个骰子。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理时，若此卡仍与效果关联且表侧表示，则投掷1个骰子，并以点数×200赋予攻击力上升效果。
function c30707994.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 让玩家tp投掷1个六面骰子，返回的点数存入dice。
		local dice=Duel.TossDice(tp,1)
		-- 只要这张卡在场上表侧表示存在，这张卡的攻击力上升丢出骰子数×200的攻击力。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(dice*200)
		c:RegisterEffect(e1)
	end
end
