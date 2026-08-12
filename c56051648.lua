--スパイダー・エッグ
-- 效果：
-- 对方宣言直接攻击时，自己墓地昆虫族怪兽有3只以上存在的场合才能发动。把那只怪兽的攻击无效，在自己场上把3只「蜘蛛衍生物」（昆虫族·地·1星·攻/守100）攻击表示特殊召唤。
function c56051648.initial_effect(c)
	-- 对方宣言直接攻击时，自己墓地昆虫族怪兽有3只以上存在的场合才能发动。把那只怪兽的攻击无效，在自己场上把3只「蜘蛛衍生物」（昆虫族·地·1星·攻/守100）攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c56051648.condition)
	e1:SetTarget(c56051648.target)
	e1:SetOperation(c56051648.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：对方直接攻击宣言时，且自己墓地有3只以上昆虫族怪兽存在
function c56051648.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方回合且对方怪兽宣言直接攻击
	return tp~=Duel.GetTurnPlayer() and Duel.GetAttackTarget()==nil
		-- 检查自己墓地是否存在3只以上的昆虫族怪兽
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,3,nil,RACE_INSECT)
end
-- 效果发动时的可行性检测，包括确认攻击怪兽在场、不受青眼精灵龙限制、怪兽区域空位足够以及能特招衍生物
function c56051648.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取宣言攻击的怪兽
	local tg=Duel.GetAttacker()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return tg:IsOnField() and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己的主要怪兽区域是否有3个及以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
		-- 检查玩家是否能特殊召唤「蜘蛛衍生物」（昆虫族·地·1星·攻/守100）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,56051649,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_INSECT,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) end
	-- 设置操作信息：产生3只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置操作信息：特殊召唤3只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果处理：无效攻击并在自己场上特殊召唤3只「蜘蛛衍生物」
function c56051648.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若成功无效攻击且自己场上主要怪兽区域空位大于2个
	if Duel.NegateAttack() and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 且玩家此时仍能特殊召唤该衍生物，则执行特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,56051649,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_INSECT,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then
		for i=1,3 do
			-- 创建「蜘蛛衍生物」卡片
			local token=Duel.CreateToken(tp,56051649)
			-- 将衍生物以表侧攻击表示特殊召唤（单步处理）
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
		-- 完成所有怪兽的特殊召唤
		Duel.SpecialSummonComplete()
	end
end
