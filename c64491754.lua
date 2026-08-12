--エルフェンノーツ～廻郷のパラレリズム～
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的中央的主要怪兽区域的怪兽不会被效果破坏。
-- ②：从自己的手卡·场上把1只怪兽送去墓地才能发动。原本属性和那只怪兽不同的1只「耀圣」怪兽从卡组守备表示特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（中央怪兽区抗破坏）与②效果（送墓特召卡组「耀圣」怪兽）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己的中央的主要怪兽区域的怪兽不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：从自己的手卡·场上把1只怪兽送去墓地才能发动。原本属性和那只怪兽不同的1只「耀圣」怪兽从卡组守备表示特殊召唤。这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤处于中央主要怪兽区域（格子编号为2）的怪兽
function s.indtg(e,c)
	return c:GetSequence()==2
end
-- 过滤作为发动代价送去墓地的怪兽：必须是怪兽卡、能送去墓地、送墓后能腾出怪兽区域，且卡组中存在原本属性不同的「耀圣」怪兽
function s.cfilter(c,e,tp)
	return c:IsAbleToGraveAsCost() and c:IsType(TYPE_MONSTER)
		-- 检查将该怪兽送去墓地后，自己场上是否有可用于特殊召唤的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查卡组中是否存在至少1只原本属性与该怪兽不同的、可特殊召唤的「耀圣」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- ②效果的发动代价处理：检查并选择手卡或场上的1只怪兽送去墓地，并将该怪兽记录在效果对象中
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查手卡或场上是否存在满足送墓代价且能成功特召后续怪兽的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或场上选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 过滤卡组中可特殊召唤的「耀圣」怪兽：原本属性与作为代价送墓的怪兽不同，且可以守备表示特殊召唤
function s.spfilter(c,e,tp,ec)
	return c:IsSetCard(0x1d8) and c:GetOriginalAttribute()~=ec:GetOriginalAttribute()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动准备：检查代价是否已支付，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置当前处理的连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理：从卡组将1只原本属性不同的「耀圣」怪兽守备表示特殊召唤，并适用“本回合自己不是同调怪兽不能从额外卡组特殊召唤”的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只原本属性与送墓怪兽不同的「耀圣」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabelObject())
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 这个回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该玩家本回合不能从额外卡组特殊召唤同调怪兽以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数：若怪兽在额外卡组且不是同调怪兽，则不能特殊召唤
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
