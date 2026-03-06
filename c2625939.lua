--スプール・コード
-- 效果：
-- ①：自己墓地的电子界族怪兽是3只以上的场合，对方怪兽的直接攻击宣言时才能发动。那次攻击无效。那之后，可以在自己场上把最多3只「假脱机衍生物」（电子界族·光·1星·攻/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
function c2625939.initial_effect(c)
	-- 效果原文：①：自己墓地的电子界族怪兽是3只以上的场合，对方怪兽的直接攻击宣言时才能发动。那次攻击无效。那之后，可以在自己场上把最多3只「假脱机衍生物」（电子界族·光·1星·攻/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c2625939.condition)
	e1:SetOperation(c2625939.activate)
	c:RegisterEffect(e1)
end
-- 效果原文：自己墓地的电子界族怪兽是3只以上的场合，对方怪兽的直接攻击宣言时才能发动。
function c2625939.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：对方怪兽的直接攻击宣言时才能发动。
	return eg:GetFirst():IsControler(1-tp) and Duel.GetAttackTarget()==nil
		-- 效果原文：自己墓地的电子界族怪兽是3只以上的场合
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,3,nil,RACE_CYBERSE)
end
-- 效果原文：那之后，可以在自己场上把最多3只「假脱机衍生物」（电子界族·光·1星·攻/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
function c2625939.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算玩家场上最多可特殊召唤的衍生物数量，最多为3只
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
	-- 无效此次攻击并检查场上是否有空位可特殊召唤
	if Duel.NegateAttack() and ft>0
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,2625940,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE)
		-- 询问玩家是否发动特殊召唤衍生物的效果
		and Duel.SelectYesNo(tp,aux.Stringid(2625939,0)) then  --"是否特殊召唤衍生物？"
		-- 中断当前效果处理，使后续处理不同时进行
		Duel.BreakEffect()
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local ct=1
		if ft>1 then
			local num={}
			local i=1
			while i<=ft do
				num[i]=i
				i=i+1
			end
			-- 提示玩家选择要特殊召唤的衍生物数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(2625939,1))  --"请选择要特殊召唤的衍生物的数量"
			-- 玩家宣言要特殊召唤的衍生物数量
			ct=Duel.AnnounceNumber(tp,table.unpack(num))
		end
		repeat
			-- 创建一张指定编号的衍生物
			local token=Duel.CreateToken(tp,2625940)
			-- 将衍生物以守备表示特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 效果原文：这衍生物不能为上级召唤而解放。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			ct=ct-1
		until ct==0
		-- 完成所有特殊召唤操作
		Duel.SpecialSummonComplete()
	end
end
