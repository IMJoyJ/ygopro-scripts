--ミイラの呼び声
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只不死族怪兽特殊召唤。这个效果在自己场上没有怪兽存在的场合才能发动和处理。
function c4861205.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只不死族怪兽特殊召唤。这个效果在自己场上没有怪兽存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4861205,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c4861205.condition)
	e1:SetTarget(c4861205.target)
	e1:SetOperation(c4861205.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己场上没有怪兽存在时才可发动和处理。
function c4861205.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己主要怪兽区（含额外怪兽区）怪兽数量是否为0，即自己场上没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 筛选可作为特殊召唤对象的不死族怪兽：必须是手卡的不死族怪兽，且满足苏生限制和特殊召唤条件。
function c4861205.filter(c,e,sp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动时检查：自己主要怪兽区有空位，且手卡存在满足条件的不死族怪兽；若满足则设置将进行特殊召唤的操作信息。
function c4861205.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查之一：自己主要怪兽区必须存在可用的空位（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查之二：手卡中必须存在1只以上满足条件的不死族怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c4861205.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：预定进行特殊召唤，对象为手卡中的1张卡，持有者为自己。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：先再次确认场上仍有空位且自己没有怪兽；然后从手卡选择1只不死族怪兽以表侧表示特殊召唤到自己的主要怪兽区。
function c4861205.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己主要怪兽区是否有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次检查自己场上没有怪兽，若已有怪兽则效果不处理（满足“这个效果在自己场上没有怪兽存在的场合才能发动和处理”）。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	-- 向操作玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只不死族怪兽，且该怪兽满足特殊召唤条件；选为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c4861205.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的不死族怪兽以表侧表示特殊召唤到自己场上；若成功则处理完成。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
