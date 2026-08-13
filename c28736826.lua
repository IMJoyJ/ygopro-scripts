--超熱血本塁打王
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升1000。
local s,id,o=GetID()
-- 注册①效果：这张卡在战斗破坏对方怪兽时诱发可选发动，效果处理时其攻击力上升1000。
function s.initial_effect(c)
	-- 对应①效果整体：“这张卡战斗破坏对方怪兽时才能发动。这张卡的攻击力上升1000。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"上升攻击力"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件：本卡与对方怪兽进行战斗并将其战斗破坏。
	e1:SetCondition(aux.bdocon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
-- 效果处理：若本卡仍表侧表示且与所发动效果保持关联，则在本卡上永久（离场、被无效等情况下重置）附加攻击力上升1000的效果。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 对应效果原文后半句：“这张卡的攻击力上升1000。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
