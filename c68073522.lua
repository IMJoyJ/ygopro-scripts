--魂吸収
-- 效果：
-- 将卡从游戏中除外时，每除外1张，这张卡的控制者自己回复500基本分。
function c68073522.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 将卡从游戏中除外时，每除外1张，这张卡的控制者自己回复500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68073522,0))  --"恢复LP"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c68073522.target)
	e2:SetOperation(c68073522.operation)
	c:RegisterEffect(e2)
end
-- 效果发动的目标确认与设置。计算被除外的卡片数量，并设置回复基本分的效果参数。
function c68073522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=#eg
	-- 设置回复基本分的对象玩家为当前效果的控制者（这张卡的控制者）。
	Duel.SetTargetPlayer(tp)
	-- 设置回复基本分的数值为除外卡片数量乘以500。
	Duel.SetTargetParam(ct*500)
	-- 设置当前连锁的操作信息为：玩家回复除外卡片数量乘以500的基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,0,0,tp,ct*500)
end
-- 效果处理。在“魂吸收”仍在场上时，获取目标玩家和回复数值，并执行回复基本分的操作。
function c68073522.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 获取当前连锁中设置的目标玩家和回复数值参数。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 使目标玩家回复对应的基本分。
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
