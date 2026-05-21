--オルターガイスト・エミュレルフ
-- 效果：
-- ①：这张卡发动后变成效果怪兽（魔法师族·光·4星·攻1400/守1800）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
-- ②：只要这张卡的效果特殊召唤的这张卡在怪兽区域存在，这张卡以外的自己场上的「幻变骚灵」陷阱卡不会成为效果的对象，不会被效果破坏。
function c86885905.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（魔法师族·光·4星·攻1400/守1800）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c86885905.target)
	e1:SetOperation(c86885905.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡的效果特殊召唤的这张卡在怪兽区域存在，这张卡以外的自己场上的「幻变骚灵」陷阱卡不会成为效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCondition(c86885905.condition)
	e2:SetTarget(c86885905.etarget)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：只要这张卡的效果特殊召唤的这张卡在怪兽区域存在，这张卡以外的自己场上的「幻变骚灵」陷阱卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetCondition(c86885905.condition)
	e3:SetTarget(c86885905.etarget)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 卡片发动时的效果处理：检查是否满足发动条件（怪兽区域有空位且可以特殊召唤该陷阱怪兽）
function c86885905.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查我方场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以将该卡作为特定属性、种族、攻防和等级的效果怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,86885905,0x103,TYPES_EFFECT_TRAP_MONSTER,1400,1800,4,RACE_SPELLCASTER,ATTRIBUTE_LIGHT) end
	-- 设置连锁运营信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 卡片发动效果处理：将自身变为陷阱怪兽并特殊召唤到怪兽区域
function c86885905.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查是否仍能特殊召唤该陷阱怪兽，若不能则不处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,86885905,0x103,TYPES_EFFECT_TRAP_MONSTER,1400,1800,4,RACE_SPELLCASTER,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_TRAP+TYPE_EFFECT)
	-- 将自身以自身效果特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 限制条件：仅在这张卡是通过自身效果特殊召唤的场合下适用
function c86885905.condition(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤目标：自己场上除自身以外的「幻变骚灵」陷阱卡
function c86885905.etarget(e,c)
	return c:IsSetCard(0x103) and c:IsType(TYPE_TRAP) and c~=e:GetHandler()
end
