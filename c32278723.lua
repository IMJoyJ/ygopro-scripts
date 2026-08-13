--アクア・ジェット・サーフェス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1只4星以下的鱼族·海龙族·水族怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：对方场上有攻击表示怪兽存在的场合，把墓地的这张卡除外，以自己场上1只鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
local s,id,o=GetID()
-- 定义该卡的初始化函数：创建并注册①的魔法卡发动效果和②的墓地起动效果。
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只4星以下的鱼族·海龙族·水族怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有攻击表示怪兽存在的场合，把墓地的这张卡除外，以自己场上1只鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"上升攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.atkcon)
	-- 设置②效果的发动代价为把墓地中的这张卡除外（aux.bfgcost实现除外自身作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 定义①效果可特殊召唤的怪兽筛选条件：鱼族/海龙族/水族、等级4以下且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动合法性检查：自己主要怪兽区有空位，且手卡·墓地存在符合条件的可特召怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1只满足spfilter条件的怪兽（e和tp作为额外参数传递给过滤函数）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：登记本次效果为特殊召唤，可能从手卡·墓地选1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：确认怪兽区有空位后，提示玩家选择要特殊召唤的卡；从手卡·墓地中选出1只符合条件的怪兽（避开王家长眠之谷影响）表侧特殊召唤；若成功，给那只怪兽附加自肃效果：只要它表侧表示存在，自己不能从额外卡组特殊召唤非超量怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区仍有空位，否则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示，供玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足spfilter且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将所选择的怪兽表侧表示特殊召唤，则继续为它附加后续的自肃效果。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是超量怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetCondition(s.con)
		e1:SetLabel(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
end
-- 自肃效果的条件：该效果适用的怪兽的控制者与发动效果的玩家相同（即该怪兽在我方场上存在时适用）。
function s.con(e)
	return e:GetHandler():GetControler()==e:GetLabel()
end
-- 定义不能特殊召唤的限制：从额外卡组不能特殊召唤非超量怪兽。
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：对方场上有攻击表示怪兽存在。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只表侧攻击表示怪兽。
	return Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_ATTACK)
end
-- 定义②效果取对象的筛选条件：表侧表示且为鱼族·海龙族·水族怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT)
end
-- ②效果的目标处理：选择自己场上1只表侧表示且符合种族条件的怪兽作为对象，并在连锁处理时校验对象合法性。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	-- 发动时检查自己场上是否存在至少1只表侧表示且符合种族条件、可选为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只符合条件的表侧表示怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：获取对象怪兽，若仍与效果关联且为表侧表示怪兽，则给它附加攻击力上升1000的效果直到回合结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本连锁中登记的唯一对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 那只怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
