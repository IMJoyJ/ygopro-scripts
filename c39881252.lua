--プレイ・ザ・ディアベル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：魔法·陷阱卡为让卡的效果发动而被送去墓地的场合才能发动。从手卡·卡组·额外卡组把1只幻想魔族·魔法师族怪兽送去墓地。
-- ②：自己主要阶段，从自己墓地把包含这张卡的3张魔法·陷阱卡除外才能发动。从自己的手卡·墓地把1只「迪亚贝尔」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果的发动条件和处理
function s.initial_effect(c)
	-- ①：魔法·陷阱卡为让卡的效果发动而被送去墓地的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送墓效果"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段，从自己墓地把包含这张卡的3张魔法·陷阱卡除外才能发动。
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
-- 过滤函数，用于判断被送去墓地的卡是否为魔法或陷阱卡且其效果被发动
function s.cfilter(c,re)
	if c:GetOriginalType()&(TYPE_SPELL+TYPE_TRAP)==0 or not re then return false end
	local recode=re:GetCode()
	return re:IsActivated()
		or recode==EFFECT_TRAP_ACT_IN_HAND
		or recode==EFFECT_TRAP_ACT_IN_SET_TURN
		or recode==EFFECT_QP_ACT_IN_NTPHAND
		or recode==EFFECT_QP_ACT_IN_SET_TURN
end
-- 条件函数，判断是否满足①效果的发动条件
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_COST>0 and eg:IsExists(s.cfilter,1,nil,re)
end
-- 过滤函数，用于检索幻想魔族·魔法师族的怪兽
function s.tgfilter(c)
	return c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 目标函数，设置①效果的处理目标为从手卡·卡组·额外卡组选择1只幻想魔族·魔法师族怪兽送去墓地
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果的处理条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,nil) end
	-- 设置①效果的处理信息为将1只幻想魔族·魔法师族怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA)
end
-- 处理函数，执行①效果的处理，选择并送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的幻想魔族·魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于检索魔法·陷阱卡
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 处理函数，执行②效果的处理，支付除外费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c = e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查是否满足②效果的处理条件
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,2,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,2,2,c)
	g:AddCard(c)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于检索迪亚贝尔怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x19b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数，设置②效果的处理目标为从手卡·墓地选择1只迪亚贝尔怪兽特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果的处理条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足②效果的处理条件
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置②效果的处理信息为特殊召唤1只迪亚贝尔怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理函数，执行②效果的处理，选择并特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足②效果的处理条件
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的迪亚贝尔怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的迪亚贝尔怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
