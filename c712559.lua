--アマゾネスの里
-- 效果：
-- ①：场上的「亚马逊」怪兽的攻击力上升200。
-- ②：1回合1次，「亚马逊」怪兽被战斗·效果破坏送去墓地时才能发动。自己把持有那只「亚马逊」怪兽的原本等级以下的等级的1只「亚马逊」怪兽从卡组特殊召唤。
function c712559.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「亚马逊」怪兽的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的对象为字段名含有「亚马逊」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	-- ②：1回合1次，「亚马逊」怪兽被战斗·效果破坏送去墓地时才能发动。自己把持有那只「亚马逊」怪兽的原本等级以下的等级的1只「亚马逊」怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(712559,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c712559.condition)
	e3:SetTarget(c712559.target)
	e3:SetOperation(c712559.operation)
	c:RegisterEffect(e3)
end
-- 检查送去墓地的卡中是否存在被破坏的「亚马逊」怪兽，并记录其中最高的原本等级
function c712559.condition(e,tp,eg,ep,ev,re,r,rp)
	local lv=0
	local tc=eg:GetFirst()
	while tc do
		if tc:IsReason(REASON_DESTROY) and tc:IsSetCard(0x4) and not tc:IsPreviousLocation(LOCATION_SZONE) then
			local tlv=tc:GetLevel()
			if tlv>lv then lv=tlv end
		end
		tc=eg:GetNext()
	end
	if lv>0 then e:SetLabel(lv) end
	return lv>0
end
-- 过滤卡组中等级在指定等级以下、属于「亚马逊」且可以特殊召唤的怪兽
function c712559.spfilter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsSetCard(0x4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查，确认自身不在连锁中、自己场上有空位且卡组有符合条件的怪兽
function c712559.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查自己场上是否有可以特殊召唤怪兽的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「亚马逊」怪兽
		and Duel.IsExistingMatchingCard(c712559.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetLabel()) end
	-- 设置连锁处理的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择1只符合条件的「亚马逊」怪兽特殊召唤
function c712559.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只等级在被破坏怪兽原本等级以下且满足条件的「亚马逊」怪兽
	local g=Duel.SelectMatchingCard(tp,c712559.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
