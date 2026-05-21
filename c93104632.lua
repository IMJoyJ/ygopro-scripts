--ワンタイム・パスコード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：在自己场上把1只「安全令牌衍生物」（电子界族·光·4星·攻/守2000）守备表示特殊召唤。
function c93104632.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：在自己场上把1只「安全令牌衍生物」（电子界族·光·4星·攻/守2000）守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,93104632+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c93104632.target)
	e1:SetOperation(c93104632.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自己场上有可用的怪兽区域，且可以特殊召唤指定的衍生物怪兽
function c93104632.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤「安全令牌衍生物」（电子界族·光·4星·攻/守2000、守备表示）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,93104633,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_CYBERSE,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：包含产生衍生物的效果
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：包含特殊召唤1只怪兽的效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理时，检查自己场上是否有可用怪兽区域，以及是否可以特殊召唤该衍生物
function c93104632.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上可用的怪兽区域是否不足
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查是否不能特殊召唤该衍生物，若不能则结束效果处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,93104633,0,TYPES_TOKEN_MONSTER,2000,2000,4,RACE_CYBERSE,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) then return end
	-- 创建「安全令牌衍生物」的卡片数据
	local token=Duel.CreateToken(tp,93104633)
	-- 将创建的衍生物以表侧守备表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
