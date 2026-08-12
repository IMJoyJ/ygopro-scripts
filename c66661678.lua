--氷結界のロイヤル・ナイト
-- 效果：
-- ①：这张卡上级召唤的场合发动。在对方场上把1只「冰棺衍生物」（水族·水·1星·攻1000/守0）攻击表示特殊召唤。这衍生物不能为上级召唤而解放。
function c66661678.initial_effect(c)
	-- ①：这张卡上级召唤的场合发动。在对方场上把1只「冰棺衍生物」（水族·水·1星·攻1000/守0）攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66661678,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c66661678.condition)
	e1:SetTarget(c66661678.target)
	e1:SetOperation(c66661678.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否是通过上级召唤成功登场
function c66661678.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果发动的目标，设置特殊召唤和衍生物产生的操作信息
function c66661678.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	-- 设置产生衍生物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- 效果处理，检查对方场上是否有空位以及是否能特殊召唤衍生物
function c66661678.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽区域是否有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<=0
		-- 检查是否能将特定属性、攻守、等级的衍生物特殊召唤到对方场上
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,66661679,0,TYPES_TOKEN_MONSTER,1000,0,1,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_ATTACK,1-tp) then return end
	-- 创建「冰棺衍生物」卡片
	local token=Duel.CreateToken(tp,66661679)
	-- 将衍生物以表侧攻击表示特殊召唤到对方场上
	Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	-- 这衍生物不能为上级召唤而解放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1,true)
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
