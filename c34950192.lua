--凍てし心が映す神影
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是「影依」怪兽不能从额外卡组特殊召唤。
-- ①：作为这张卡的发动时的效果处理，从额外卡组把1只融合怪兽送去墓地。
-- ②：把自己场上1只融合怪兽解放才能发动。和那只怪兽属性不同的1只「影依」融合怪兽从额外卡组当作融合召唤作特殊召唤。这个效果特殊召唤的怪兽的攻击力变成0。
local s,id,o=GetID()
-- 注册卡的两个效果，①为发动时效果，②为场地区域发动效果
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从额外卡组把1只融合怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只融合怪兽解放才能发动。和那只怪兽属性不同的1只「影依」融合怪兽从额外卡组当作融合召唤作特殊召唤。这个效果特殊召唤的怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabel(0)
	e2:SetCost(s.cost)
	e2:SetTarget(s.fustg)
	e2:SetOperation(s.fusop)
	e2:SetCountLimit(1,id+o)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于限制每回合特殊召唤次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，判断是否为额外卡组召唤且非影依怪兽
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x9d) and c:IsFaceup()
end
-- 效果发动时检查是否已使用过效果，若未使用则设置不能特殊召唤非影依怪兽效果
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已使用过效果
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 注册不能特殊召唤非影依怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.splimit)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤非影依怪兽的限制条件
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9d) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数，筛选可送去墓地的融合怪兽
function s.tgfilter(c)
	return c:IsAbleToGrave() and c:IsType(TYPE_FUSION)
end
-- 设置效果处理时的行动信息，准备将一张融合怪兽送去墓地
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 发动效果时选择并送去墓地一张融合怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的融合怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 筛选可作为解放的融合怪兽
function s.fusfilter1(c,e,tp)
	-- 筛选可作为解放的融合怪兽，且额外卡组存在满足条件的影依融合怪兽
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.fusfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttribute(),c)
end
-- 筛选可特殊召唤的影依融合怪兽
function s.fusfilter2(c,e,tp,att,mc)
	return c:IsSetCard(0x9d) and not c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial()
		-- 检查是否有足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置融合召唤效果的处理条件，包括必须有融合素材、可解放融合怪兽、满足特殊召唤条件
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not e:IsCostChecked() then return false end
		-- 检查是否有融合素材、可解放融合怪兽、满足特殊召唤条件
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) and Duel.CheckReleaseGroup(tp,s.fusfilter1,1,nil,e,tp)
			and s.cost(e,tp,eg,ep,ev,re,r,rp,0)
	end
	e:SetLabel(0)
	-- 选择要解放的融合怪兽
	local rg=Duel.SelectReleaseGroup(tp,s.fusfilter1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetAttribute())
	-- 解放选中的融合怪兽
	Duel.Release(rg,REASON_COST)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动融合召唤效果，选择并特殊召唤影依融合怪兽
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足融合召唤的素材条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	local att=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的影依融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.fusfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,att,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 特殊召唤选中的影依融合怪兽
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP) then
			-- 将特殊召唤的怪兽攻击力设为0
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		tc:CompleteProcedure()
	end
end
