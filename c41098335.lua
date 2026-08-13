--ファイターズ・エイプ
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，这张卡的攻击力上升300。这张卡在自己回合没有进行攻击的场合，这个效果上升的数值在那个回合的结束阶段时回到0。
function c41098335.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，这张卡的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41098335,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c41098335.atkcon)
	e1:SetOperation(c41098335.atkop)
	c:RegisterEffect(e1)
	-- 这张卡在自己回合没有进行攻击的场合，这个效果上升的数值在那个回合的结束阶段时回到0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TURN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(c41098335.retop)
	c:RegisterEffect(e2)
end
-- 攻击力上升效果的发动条件：这张卡表侧表示，并且与本次战斗相关联（即战斗破坏对方怪兽的这张卡仍在场上且参与了战斗）。
function c41098335.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsRelateToBattle()
end
-- 处理战斗破坏时：若这张卡仍与发动时的效果关联且表侧表示，则给它赋予一个攻击力上升300的效果。
function c41098335.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 回合结束时：若当前回合玩家为此卡控制者且此卡本回合没有攻击过，则将之前通过战斗破坏效果提升的攻击力数值重置为0。
function c41098335.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否为“自己回合且此卡没有进行攻击”：当前回合玩家等于此卡控制者，且此卡本回合攻击次数为0。
	if Duel.GetTurnPlayer()==tp and c:GetAttackedCount()==0 then
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
end
