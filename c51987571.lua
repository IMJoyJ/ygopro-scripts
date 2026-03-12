--ロックストーン・ウォリアー
-- 效果：
-- 这张卡的战斗发生的对自己的战斗伤害变成0。这张卡的攻击让这张卡被战斗破坏送去墓地时，在自己场上把2只「岩石衍生物」（岩石族·地·1星·攻/守0）特殊召唤。这衍生物不能为上级召唤而解放。
function c51987571.initial_effect(c)
	-- 诱发必发效果，当此卡被战斗破坏送去墓地时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51987571,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c51987571.condition)
	e1:SetTarget(c51987571.target)
	e1:SetOperation(c51987571.operation)
	c:RegisterEffect(e1)
	-- 这张卡的战斗发生的对自己的战斗伤害变成0
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 效果发动条件：此卡为攻击状态且因战斗破坏
function c51987571.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 此卡为攻击状态且在墓地
	return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():IsLocation(LOCATION_GRAVE)
		and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置连锁操作信息，准备特殊召唤2只衍生物
function c51987571.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息为特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理函数：检测是否受青眼精灵龙影响并检查召唤条件后特殊召唤衍生物
function c51987571.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断场上是否有足够的怪兽区域召唤2只衍生物
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 判断是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,51987572,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	for i=1,2 do
		-- 创建一只指定编号的衍生物
		local token=Duel.CreateToken(tp,51987572)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		-- 衍生物不能为上级召唤而解放
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		token:RegisterEffect(e1,true)
	end
	-- 完成一次特殊召唤流程
	Duel.SpecialSummonComplete()
end
