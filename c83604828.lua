--雲魔物－ゴースト・フォッグ
-- 效果：
-- 这张卡不能特殊召唤。这张卡的战斗发生的对双方玩家的战斗伤害变成0。这张卡被战斗破坏的场合，给场上表侧表示存在的怪兽放置让这张卡破坏的怪兽的等级数量的雾指示物。
function c83604828.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡的战斗发生的对双方玩家的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
	-- 这张卡的战斗发生的对双方玩家的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这张卡被战斗破坏的场合，给场上表侧表示存在的怪兽放置让这张卡破坏的怪兽的等级数量的雾指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(83604828,0))  --"放置指示物"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetOperation(c83604828.ctop)
	c:RegisterEffect(e4)
end
-- 被战斗破坏时，获取把这张卡破坏的怪兽的等级，并在场上可以放置指示物的怪兽上逐个放置对应数量的雾指示物
function c83604828.ctop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetHandler():GetBattleTarget():GetLevel()
	-- 获取双方场上可以放置至少1个雾指示物的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1019,1)
	if g:GetCount()==0 then return end
	for i=1,lv do
		-- 提示玩家选择要放置指示物的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		tc:AddCounter(0x1019,1)
	end
end
