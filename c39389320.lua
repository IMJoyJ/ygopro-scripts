--バーバリアン・キング
-- 效果：
-- ①：1回合1次，把这张卡以外的自己场上的战士族怪兽任意数量解放才能发动。这个回合，这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有为这个效果发动而解放的怪兽数量的攻击。
function c39389320.initial_effect(c)
	-- 创建效果，设置为起动效果，发动条件为可以进入战斗阶段，消耗为解放战士族怪兽，效果为增加攻击次数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39389320,0))  --"多次攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c39389320.condition)
	e1:SetCost(c39389320.cost)
	e1:SetOperation(c39389320.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：回合玩家可以进入战斗阶段
function c39389320.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家是否可以进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 效果发动的消耗：选择1~10张自己场上的非此卡的战士族怪兽进行解放
function c39389320.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放至少1张战士族怪兽（不包括此卡）
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,e:GetHandler(),RACE_WARRIOR) end
	-- 选择1~10张自己场上的非此卡的战士族怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,10,e:GetHandler(),RACE_WARRIOR)
	-- 将选中的怪兽进行解放，返回实际解放的数量
	local ct=Duel.Release(g,REASON_COST)
	e:SetLabel(ct)
end
-- 效果的发动处理：若此卡仍在场上，则获得额外攻击次数
function c39389320.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 此卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有为这个效果发动而解放的怪兽数量的攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
