--キラー・ポテト
-- 效果：
-- ①：场上的这张卡被效果破坏送去墓地的场合才能发动。除「杀人马铃薯」外的1只攻击力1500以下的暗属性怪兽从卡组攻击表示特殊召唤。
local s,id,o=GetID()
-- 定义并注册效果①
function s.initial_effect(c)
	-- ①：场上的这张卡被效果破坏送去墓地的场合才能发动。除「杀人马铃薯」外的1只攻击力1500以下的暗属性怪兽从卡组攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：场上的这张卡被效果破坏送去墓地
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReason()&0x41==0x41 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中除「杀人马铃薯」以外、攻击力1500以下、可表侧攻击表示特召的暗属性怪兽
function s.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAttackBelow(1500) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动靶向：检查怪兽区域空位及卡组中是否存在可特召的怪兽，并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统宣告该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的怪兽以表侧攻击表示特殊召唤
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
