--竹頭木屑
-- 效果：
-- 把自己场上存在的1只植物族怪兽解放发动。在对方场上把2只「植物衍生物」（植物族·地·1星·攻800/守500）守备表示特殊召唤。
function c28062325.initial_effect(c)
	-- 效果原文内容：把自己场上存在的1只植物族怪兽解放发动。在对方场上把2只「植物衍生物」（植物族·地·1星·攻800/守500）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28062325.cost)
	e1:SetTarget(c28062325.target)
	e1:SetOperation(c28062325.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查并选择1只自己场上的植物族怪兽进行解放作为发动代价。
function c28062325.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检测是否满足解放1只植物族怪兽的条件。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_PLANT) end
	-- 效果作用：从自己场上选择1只植物族怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_PLANT)
	-- 效果作用：将选中的怪兽解放并支付发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果作用：判断是否可以发动此卡的效果，包括未受青眼精灵龙影响、对方场上有足够空间、可以特殊召唤衍生物。
function c28062325.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 效果作用：检测对方场上是否有至少2个可用怪兽区域。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>1
		-- 效果作用：检测自己是否可以特殊召唤指定的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,28062326,0,TYPES_TOKEN_MONSTER,800,500,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) end
	-- 效果作用：设置连锁操作信息，表示将特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 效果作用：设置连锁操作信息，表示将召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果作用：执行此卡的发动效果，包括检测是否受青眼精灵龙影响、对方场上是否有足够空间、是否可以特殊召唤衍生物，并进行2次特殊召唤。
function c28062325.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果作用：检测对方场上是否至少有2个可用怪兽区域。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<2 then return end
	-- 效果作用：检测自己是否可以特殊召唤指定的衍生物。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,28062326,0,TYPES_TOKEN_MONSTER,800,500,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) then return end
	for i=1,2 do
		-- 效果作用：创建一只指定编号的衍生物。
		local token=Duel.CreateToken(tp,28062326)
		-- 效果作用：将创建的衍生物以守备表示特殊召唤到对方场上。
		Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 效果作用：完成所有特殊召唤步骤。
	Duel.SpecialSummonComplete()
end
