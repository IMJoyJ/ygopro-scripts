--EMドラマチックシアター
-- 效果：
-- ①：自己场上的怪兽的攻击力上升自己场上的怪兽的种族种类×200。
-- ②：1回合1次，自己场上的「娱乐伙伴」怪兽的种族是4种类的场合才能发动。从自己的手卡·卡组·墓地选1只「异色眼」怪兽特殊召唤。
function c55553602.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽的攻击力上升自己场上的怪兽的种族种类×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(c55553602.atkvalue)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己场上的「娱乐伙伴」怪兽的种族是4种类的场合才能发动。从自己的手卡·卡组·墓地选1只「异色眼」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c55553602.condition)
	e3:SetTarget(c55553602.target)
	e3:SetOperation(c55553602.operation)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示且种族不为0的怪兽
function c55553602.atkfilter(c)
	return c:IsFaceup() and c:GetRace()~=0
end
-- 计算自己场上怪兽的种族种类数量并乘以200，作为攻击力上升的数值
function c55553602.atkvalue(e,c)
	-- 获取自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(c55553602.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetRace)
	return ct*200
end
-- 过滤自己场上表侧表示且种族不为0的「娱乐伙伴」怪兽
function c55553602.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:GetRace()~=0
end
-- 检查自己场上的「娱乐伙伴」怪兽的种族是否刚好是4种类
function c55553602.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「娱乐伙伴」怪兽
	local g=Duel.GetMatchingGroup(c55553602.confilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetRace)
	return ct==4
end
-- 过滤手卡、卡组、墓地中可以特殊召唤的「异色眼」怪兽
function c55553602.spfilter(c,e,sp)
	return c:IsSetCard(0x99) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动的检测，确认自己场上有空位且手卡、卡组、墓地存在可特殊召唤的「异色眼」怪兽
function c55553602.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡、卡组、墓地是否存在至少1只满足特殊召唤条件的「异色眼」怪兽
		and Duel.IsExistingMatchingCard(c55553602.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁的操作信息为从手卡、卡组、墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理，从手卡、卡组、墓地选择1只「异色眼」怪兽特殊召唤
function c55553602.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地选择1只「异色眼」怪兽（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c55553602.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
