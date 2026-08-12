--竜咬蟲
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的昆虫族怪兽特殊召唤。
-- ②：从自己的手卡·墓地以及自己场上的表侧表示怪兽之中把1只4星以下的昆虫族怪兽除外，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升除外的怪兽的等级数值。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星以下的昆虫族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	-- ②：从自己的手卡·墓地以及自己场上的表侧表示怪兽之中把1只4星以下的昆虫族怪兽除外，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升除外的怪兽的等级数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中等级4以下且可以特殊召唤的昆虫族怪兽
function s.filter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动检测与处理
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测手卡中是否存在满足条件的昆虫族怪兽
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的处理：从手卡特殊召唤1只4星以下的昆虫族怪兽
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有空余的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：场上表侧表示且有等级的怪兽
function s.targetfilter2(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 过滤条件：手卡·墓地·场上等级4以下、可除外且除外后场上仍有其他可选对象的昆虫族怪兽
function s.filter2(c,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and (not c:IsOnField() or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
		-- 检测场上是否存在除该卡以外的、可作为等级上升对象的表侧表示怪兽
		and Duel.IsExistingTarget(s.targetfilter2,tp,LOCATION_MZONE,0,1,c)
end
-- 效果②的代价处理：除外1只4星以下的昆虫族怪兽并记录其等级
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测手卡·场上·墓地是否存在可作为代价除外的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手卡·场上·墓地选择1只满足条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- 效果②的对象选择与检测
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.targetfilter2(chkc) end
	-- 检测自己场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.targetfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示怪兽作为对象
	Duel.SelectTarget(tp,s.targetfilter2,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的处理：使目标怪兽的等级上升除外怪兽的等级数值
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	local lv=e:GetLabel()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and lv then
		-- 那只怪兽的等级直到回合结束时上升除外的怪兽的等级数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
