--ロックストーン・ウォリアー
-- 效果：
-- 这张卡的战斗发生的对自己的战斗伤害变成0。这张卡的攻击让这张卡被战斗破坏送去墓地时，在自己场上把2只「岩石衍生物」（岩石族·地·1星·攻/守0）特殊召唤。这衍生物不能为上级召唤而解放。
function c51987571.initial_effect(c)
	-- 这张卡的攻击让这张卡被战斗破坏送去墓地时，在自己场上把2只「岩石衍生物」（岩石族·地·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51987571,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c51987571.condition)
	e1:SetTarget(c51987571.target)
	e1:SetOperation(c51987571.operation)
	c:RegisterEffect(e1)
	-- 这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 该条件函数用于判断是否满足诱发效果的发动条件：必须是这张卡作为攻击怪兽时被战斗破坏并送去墓地。
function c51987571.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此次战斗的攻击怪兽确实是这张卡，并且这张卡此时已在墓地。
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsLocation(LOCATION_GRAVE)
		and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 目标处理阶段：本效果不取对象，发动条件满足时直接通过，并设置将特殊召唤2只衍生物的操作信息。
function c51987571.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果处理包含生成2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息：本次效果处理包含特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：若青眼精灵龙的效果适用则不能同时特殊召唤2只以上怪兽，直接终止；若怪兽区空格不足或无法特殊召唤该衍生物也终止；否则生成并特殊召唤2只「岩石衍生物」，并为其附加不能为上级召唤而解放的效果。
function c51987571.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己主要怪兽区是否有至少2个可用空格，不足则无法特殊召唤2只衍生物。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 检查自己是否能够将1只「岩石衍生物」（岩石族·地·1星·攻/守0）特殊召唤。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,51987572,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	for i=1,2 do
		-- 在自己场上生成1只「岩石衍生物」。
		local token=Duel.CreateToken(tp,51987572)
		-- 将生成的衍生物以表侧攻击表示加入特殊召唤处理，作为连续特殊召唤的一步。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 这衍生物不能为上级召唤而解放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		token:RegisterEffect(e1,true)
	end
	-- 完成整个连续特殊召唤处理，使之前所有SpecialSummonStep统一生效。
	Duel.SpecialSummonComplete()
end
