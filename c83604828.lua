--雲魔物－ゴースト・フォッグ
-- 效果：
-- 这张卡不能特殊召唤。这张卡的战斗发生的对双方玩家的战斗伤害变成0。这张卡被战斗破坏的场合，给场上表侧表示存在的怪兽放置让这张卡破坏的怪兽的等级数量的雾指示物。
function c83604828.initial_effect(c)
	-- 无法特殊召唤：此卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 战斗伤害归零：这张卡的战斗发生的对双方玩家的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
	-- 战斗伤害免除：这张卡的战斗发生的对自己玩家的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 被战破放置指示物：这张卡被战斗破坏的场合发动。给场上表侧表示存在的怪兽放置让这张卡破坏的怪兽的等级数量的雾指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(83604828,0))  --"放置指示物"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetOperation(c83604828.ctop)
	c:RegisterEffect(e4)
end
c83604828.mentioned_counter={
	[0x1019]=true,
}
-- 战破效果处理：获取破坏此卡的怪兽等级，依次在场上可放置指示物的怪兽上放置对应数量的雾指示物
function c83604828.ctop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetHandler():GetBattleTarget():GetLevel()
	-- 收集双方场地所有可以放置雾指示物（0x1019）的表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1019,1)
	if g:GetCount()==0 then return end
	for i=1,lv do
		-- 提示玩家选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		tc:AddCounter(0x1019,1)
	end
end
