--ダンディライオン
-- 效果：
-- ①：这张卡被送去墓地的场合发动。在自己场上把2只「绵毛衍生物」（植物族·风·1星·攻/守0）守备表示特殊召唤。这衍生物在特殊召唤的回合不能为上级召唤而解放。
function c15341821.initial_effect(c)
	-- 效果原文内容：①：这张卡被送去墓地的场合发动。在自己场上把2只「绵毛衍生物」（植物族·风·1星·攻/守0）守备表示特殊召唤。这衍生物在特殊召唤的回合不能为上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15341821,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c15341821.target)
	e1:SetOperation(c15341821.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：设置连锁操作信息，声明将特殊召唤2只衍生物
function c15341821.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置连锁操作信息，声明将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 效果作用：设置连锁操作信息，声明将特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果作用：检测是否满足特殊召唤条件，包括场地空间、是否受青眼精灵龙影响、是否可以特殊召唤衍生物
function c15341821.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果作用：检查玩家场上是否有足够的怪兽区域来特殊召唤2只衍生物
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果作用：检查玩家是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,15341822,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) then return end
	for i=1,2 do
		-- 效果作用：创建一张指定编号的衍生物卡片
		local token=Duel.CreateToken(tp,15341821+i)
		-- 效果作用：将衍生物以守备表示特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 效果原文内容：这衍生物在特殊召唤的回合不能为上级召唤而解放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		token:RegisterEffect(e1,true)
	end
	-- 效果作用：完成所有特殊召唤步骤，使衍生物正式登场
	Duel.SpecialSummonComplete()
end
