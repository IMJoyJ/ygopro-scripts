--スプール・コード
-- 效果：
-- ①：自己墓地的电子界族怪兽是3只以上的场合，对方怪兽的直接攻击宣言时才能发动。那次攻击无效。那之后，可以在自己场上把最多3只「假脱机衍生物」（电子界族·光·1星·攻/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
function c2625939.initial_effect(c)
	-- ①：自己墓地的电子界族怪兽是3只以上的场合，对方怪兽的直接攻击宣言时才能发动。那次攻击无效。那之后，可以在自己场上把最多3只「假脱机衍生物」（电子界族·光·1星·攻/守0）守备表示特殊召唤。这衍生物不能为上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c2625939.condition)
	e1:SetOperation(c2625939.activate)
	c:RegisterEffect(e1)
end
-- 判定效果发动条件：攻击宣言的怪兽是否为对方怪兽、是否为直接攻击、自己墓地是否有3只以上电子界族怪兽，均满足时效果才可发动。
function c2625939.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认攻击方为对方怪兽且没有攻击对象（直接攻击）。
	return eg:GetFirst():IsControler(1-tp) and Duel.GetAttackTarget()==nil
		-- 确认自己墓地存在至少3只电子界族怪兽。
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,3,nil,RACE_CYBERSE)
end
-- 效果处理：无效那次攻击；若可行，由玩家选择数量，在可用区域守备表示特殊召唤最多3只「假脱机衍生物」，并给各衍生物附加不能为上级召唤解放的永续效果。
function c2625939.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可特殊召唤的衍生物数量上限：取自己场上可用主要怪兽区空格数与3的较小值。
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
	-- 先无效攻击，并确认存在可用怪兽区格子，才继续后续特殊召唤处理。
	if Duel.NegateAttack() and ft>0
		-- 确认当前玩家能够特殊召唤「假脱机衍生物」（光/电子界/1星/攻守0/表侧守备）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,2625940,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE)
		-- 询问玩家是否要特殊召唤衍生物，选择“是”才进入特殊召唤处理。
		and Duel.SelectYesNo(tp,aux.Stringid(2625939,0)) then  --"是否特殊召唤衍生物？"
		-- 断开效果处理链，使无效攻击与后续特殊召唤衍生物不视为同时处理，以正确对应时点。
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
			-- 向玩家显示提示信息，要求选择要特殊召唤的衍生物数量。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(2625939,1))  --"请选择要特殊召唤的衍生物的数量"
			-- 玩家宣言一个数字（1到ft），作为实际特殊召唤的衍生物数量ct。
			ct=Duel.AnnounceNumber(tp,table.unpack(num))
		end
		repeat
			-- 在场上生成1只「假脱机衍生物」（卡号2625940）。
			local token=Duel.CreateToken(tp,2625940)
			-- 将该衍生物以表侧守备表示加入到特殊召唤处理中（尚未完成）。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这衍生物不能为上级召唤而解放。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			ct=ct-1
		until ct==0
		-- 完成本次连锁中所有衍生物的特殊召唤处理，确认特殊召唤成功。
		Duel.SpecialSummonComplete()
	end
end
