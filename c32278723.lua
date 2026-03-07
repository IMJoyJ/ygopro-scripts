--アクア・ジェット・サーフェス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1只4星以下的鱼族·海龙族·水族怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：对方场上有攻击表示怪兽存在的场合，把墓地的这张卡除外，以自己场上1只鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
local s,id,o=GetID()
-- 创建两个效果，分别对应卡牌效果①和②
function s.initial_effect(c)
	-- 效果①：从自己的手卡·墓地把1只4星以下的鱼族·海龙族·水族怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果②：对方场上有攻击表示怪兽存在的场合，把墓地的这张卡除外，以自己场上1只鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"上升攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.atkcon)
	-- 将墓地的这张卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 特殊召唤的过滤条件：鱼族·海龙族·水族且等级4以下且能特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否能发动效果①，检查是否有满足条件的怪兽且场上是否有空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果①的处理信息，确定要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理效果①，选择并特殊召唤符合条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 特殊召唤选中的怪兽
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 为特殊召唤的怪兽添加效果，限制自己不能从额外卡组特殊召唤非超量怪兽
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
-- 判断效果是否生效，确保是该玩家的怪兽
function s.con(e)
	return e:GetHandler():GetControler()==e:GetLabel()
end
-- 限制不能特殊召唤非超量怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断是否能发动效果②，检查对方场上是否有攻击表示的怪兽
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否有攻击表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_ATTACK)
end
-- 攻击力上升效果的过滤条件：表侧表示且鱼族·海龙族·水族
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT)
end
-- 判断是否能发动效果②，检查是否有满足条件的怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	-- 检查场上是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果②，为选中的怪兽增加攻击力
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 为选中的怪兽增加1000攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
