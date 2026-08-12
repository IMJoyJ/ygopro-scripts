--ライク・ザ・ディアベル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：魔法·陷阱卡被效果送去墓地的场合才能发动。从自己的手卡·墓地把1张魔法·陷阱卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
-- ②：自己主要阶段，从自己墓地把包含这张卡的3张魔法·陷阱卡除外才能发动。从自己的手卡·墓地把1只「迪亚贝尔」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（魔陷送墓时盖放手卡/墓地魔陷）和②效果（主要阶段除外墓地3张魔陷特召手卡/墓地「迪亚贝尔」怪兽）
function s.initial_effect(c)
	-- ①：魔法·陷阱卡被效果送去墓地的场合才能发动。从自己的手卡·墓地把1张魔法·陷阱卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放效果"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段，从自己墓地把包含这张卡的3张魔法·陷阱卡除外才能发动。从自己的手卡·墓地把1只「迪亚贝尔」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：被效果送去墓地的魔法·陷阱卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsReason(REASON_EFFECT)
end
-- ①效果的发动条件：确认送去墓地的卡中存在满足过滤条件的魔法·陷阱卡
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 过滤条件：手卡·墓地中可以盖放的魔法·陷阱卡，且需要满足场上魔陷区的格子限制
function s.setfilter(c,tp,ex)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
		and (c:IsType(TYPE_FIELD)
			-- 或者当这张卡（作为手卡发动的魔法·陷阱卡）在魔陷区占用了格子时，场上至少有1个可用的魔陷区空格
			or ex and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 或者场上至少有2个可用的魔陷区空格
			or Duel.GetLocationCount(tp,LOCATION_SZONE)>1)
end
-- ①效果的发动准备（Target）：检查手卡·墓地是否存在可盖放的魔法·陷阱卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己手卡·墓地是否存在至少1张可以盖放的魔法·陷阱卡（排除自身，并传入自身是否在魔陷区的状态）
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,tp,c:IsLocation(LOCATION_SZONE)) end
end
-- ①效果的处理（Operation）：从手卡·墓地选择1张魔法·陷阱卡在场上盖放，并限制该卡在本回合不能发动
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从手卡·墓地选择1张满足条件的魔法·陷阱卡（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp,true)
	local tc=g:GetFirst()
	-- 如果成功选择卡片且成功在场上盖放
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在这个回合不能发动。②：自己主要阶段，从自己墓地把包含这张卡的3张魔法·陷阱卡除外才能发动。从自己的手卡·墓地把1只「迪亚贝尔」怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 过滤条件：墓地中可以作为cost除外的魔法·陷阱卡
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价（Cost）：检查并执行从墓地除外包含这张卡在内的3张魔法·陷阱卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 并且检查自己墓地是否存在另外2张可以除外的魔法·陷阱卡
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,2,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从墓地选择2张魔法·陷阱卡（排除自身）
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,2,2,c)
	g:AddCard(c)
	-- 将选中的卡和自身一同除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：手卡·墓地中可以特殊召唤的「迪亚贝尔」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x19b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备（Target）：检查怪兽区域是否有空位，以及手卡·墓地是否存在可特殊召唤的「迪亚贝尔」怪兽，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己手卡·墓地是否存在至少1只可以特殊召唤的「迪亚贝尔」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·墓地特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的处理（Operation）：在怪兽区域有空位的情况下，从手卡·墓地选择1只「迪亚贝尔」怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡·墓地选择1只满足条件的「迪亚贝尔」怪兽（受王家之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
