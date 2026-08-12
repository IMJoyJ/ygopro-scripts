--超熱血本塁打王
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升1000。
local s,id,o=GetID()
-- 注册触发效果，用于检测战斗破坏对方怪兽时的发动条件
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"上升攻击力"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件为：自身与对方怪兽战斗且被战斗破坏
	e1:SetCondition(aux.bdocon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
-- 效果发动时执行的处理函数，用于提升自身攻击力
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 创建一个使自身攻击力上升1000的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
