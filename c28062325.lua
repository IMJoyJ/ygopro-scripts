--竹頭木屑
-- 效果：
-- 把自己场上存在的1只植物族怪兽解放发动。在对方场上把2只「植物衍生物」（植物族·地·1星·攻800/守500）守备表示特殊召唤。
function c28062325.initial_effect(c)
	-- 把自己场上存在的1只植物族怪兽解放发动。在对方场上把2只「植物衍生物」（植物族·地·1星·攻800/守500）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28062325.cost)
	e1:SetTarget(c28062325.target)
	e1:SetOperation(c28062325.activate)
	c:RegisterEffect(e1)
end
-- cost函数：发动代价处理。先检查自己场上是否存在1只可解放的植物族怪兽，然后选择并解放该怪兽作为COST。
function c28062325.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）：确认自己场上是否存在至少1只植物族怪兽可以解放（不取对象，仅确认可满足解放条件）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_PLANT) end
	-- 从自己场上选择1只植物族怪兽作为解放的代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_PLANT)
	-- 将选择的怪兽解放（REASON_COST），完成代价支付。
	Duel.Release(g,REASON_COST)
end
-- target函数：效果发动的合法性检查。确认没有“青眼精灵龙”的封锁、对方场上有足够空位，且当前玩家能在对方场上守备表示特殊召唤植物衍生物。
function c28062325.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认对方场上的主要怪兽区可用空格大于1（至少2个），以保证能特殊召唤2只衍生物。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>1
		-- 确认当前玩家能够以表侧守备表示将1星·地·植物族·攻800/守500的“植物衍生物”特殊召唤到对方场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28062326,0,TYPES_TOKEN_MONSTER,800,500,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置操作信息：本次效果将产生2只衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：本次效果将进行2只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- activate函数：效果处理时的实际执行。再次验证封锁/空位/召唤许可后，循环创建2只植物衍生物并逐一特殊召唤到对方场上，最后完成特殊召唤。
function c28062325.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认对方场上有至少2个可用怪兽区，不足则效果不处理。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<2 then return end
	-- 效果处理时再次确认当前玩家可以特殊召唤该植物衍生物，否则效果不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,28062326,0,TYPES_TOKEN_MONSTER,800,500,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) then return end
	for i=1,2 do
		-- 创建1只卡号为28062326的“植物衍生物”（token）。
		local token=Duel.CreateToken(tp,28062326)
		-- 将创建的衍生物以表侧守备表示特殊召唤到对方场上（这是分步特殊召唤的其中一步）。
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 分步特殊召唤结束，完成整个特殊召唤流程并触发相关时点。
	Duel.SpecialSummonComplete()
end
