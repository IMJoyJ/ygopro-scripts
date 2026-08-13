--ダンディライオン
-- 效果：
-- ①：这张卡被送去墓地的场合发动。在自己场上把2只「绵毛衍生物」（植物族·风·1星·攻/守0）守备表示特殊召唤。这衍生物在特殊召唤的回合不能为上级召唤而解放。
function c15341821.initial_effect(c)
	-- ①：这张卡被送去墓地的场合发动。在自己场上把2只「绵毛衍生物」（植物族·风·1星·攻/守0）守备表示特殊召唤。这衍生物在特殊召唤的回合不能为上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15341821,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c15341821.target)
	e1:SetOperation(c15341821.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的判定：作为必发诱发效果，在chk==0时直接判定满足发动条件；随后写入本次连锁将生成衍生物并进行特殊召唤的操作信息。
function c15341821.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 写入操作信息：本效果包含生成衍生物，预计生成2只衍生物（对象在发动时不确定，故传入nil，数量为2）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 写入操作信息：本效果包含特殊召唤，预计将2只怪兽特殊召唤（对象在发动时不确定，故传入nil，数量为2）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：先逐一检查「青眼精灵龙」是否适用、自己主要怪兽区是否足够2个空格、自己能否特殊召唤规定的衍生物；满足条件后循环生成2只衍生物，各自赋予本回合不能上级召唤解放的效果，最后一次性完成特殊召唤。
function c15341821.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上主要怪兽区的可用空格是否少于2个；若不足则效果处理直接中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查自己能否以植物族·风·1星·攻击力0/守备力0·表侧守备表示的形式特殊召唤编号15341822的衍生物；若不能则效果处理直接中止。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,15341822,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) then return end
	for i=1,2 do
		-- 生成第i只衍生物，其卡号为15341821+i（i=1时为15341822，即「绵毛衍生物」）。
		local token=Duel.CreateToken(tp,15341821+i)
		-- 将衍生物以表侧守备表示加入特殊召唤的分解步骤（不检查召唤条件、不检查苏生限制），等待最终统一完成特殊召唤。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这衍生物在特殊召唤的回合不能为上级召唤而解放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		token:RegisterEffect(e1,true)
	end
	-- 完成所有特殊召唤步骤，将之前通过SpecialSummonStep加入的衍生物实际特殊召唤到场上。
	Duel.SpecialSummonComplete()
end
