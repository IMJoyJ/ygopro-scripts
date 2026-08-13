--バーバリアン・キング
-- 效果：
-- ①：1回合1次，把这张卡以外的自己场上的战士族怪兽任意数量解放才能发动。这个回合，这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有为这个效果发动而解放的怪兽数量的攻击。
function c39389320.initial_effect(c)
	-- ①：1回合1次，把这张卡以外的自己场上的战士族怪兽任意数量解放才能发动。这个回合，这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有为这个效果发动而解放的怪兽数量的攻击。
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
-- 效果发动条件：当前回合玩家能够进入战斗阶段（Duel.IsAbleToEnterBP）。
function c39389320.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否能够进入战斗阶段，若不能则不能发动该效果。
	return Duel.IsAbleToEnterBP()
end
-- 发动代价：从自己场上选择这张卡以外的任意数量战士族怪兽解放，并记录解放数量。
function c39389320.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上存在至少1张这张卡以外的可解放的战士族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,e:GetHandler(),RACE_WARRIOR) end
	-- 选择自己场上这张卡以外的1~10只战士族怪兽（实际上为任意数量）作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,10,e:GetHandler(),RACE_WARRIOR)
	-- 解放所选怪兽，并将其数量记录到效果的Label中，用于决定追加攻击次数。
	local ct=Duel.Release(g,REASON_COST)
	e:SetLabel(ct)
end
-- 效果处理：给这张卡赋予追加攻击次数的效果，追加次数等于为发动解放的怪兽数量，持续到回合结束且不可被无效。
function c39389320.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有为这个效果发动而解放的怪兽数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
