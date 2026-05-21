--シェイプシスター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡发动后变成通常怪兽（恶魔族·调整·地·2星·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
function c92099232.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡发动后变成通常怪兽（恶魔族·调整·地·2星·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,92099232+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c92099232.target)
	e1:SetOperation(c92099232.activate)
	c:RegisterEffect(e1)
end
-- 发动时的效果目标判定：检查怪兽区域是否有空位，以及是否能将此卡作为特定怪兽特殊召唤
function c92099232.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自身的主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能将此卡作为通常怪兽（恶魔族·调整·地·2星·攻/守0）特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,92099232,0,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,2,RACE_FIEND,ATTRIBUTE_EARTH) end
	-- 设置连锁的操作信息为：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：为这张卡添加怪兽属性，并特殊召唤到怪兽区域
function c92099232.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时，再次检查是否能将此卡作为特定怪兽特殊召唤，若不能则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,92099232,0,TYPES_NORMAL_TRAP_MONSTER+TYPE_TUNER,0,0,2,RACE_FIEND,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER+TYPE_TRAP)
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
