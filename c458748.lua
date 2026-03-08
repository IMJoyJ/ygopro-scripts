--法の聖典
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只「召唤兽」怪兽解放才能发动。原本属性和解放的怪兽不同的1只「召唤兽」怪兽当作融合召唤从额外卡组特殊召唤。
function c458748.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,458748+EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	e1:SetCost(c458748.cost)
	e1:SetTarget(c458748.target)
	e1:SetOperation(c458748.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：设置发动时的标签为100，表示已支付费用。
function c458748.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果作用：过滤场上满足条件的「召唤兽」怪兽，用于判断是否可以发动效果。
function c458748.filter1(c,e,tp)
	-- 效果作用：检查是否存在满足条件的额外卡组中的「召唤兽」怪兽作为融合召唤目标。
	return c:IsSetCard(0xf4) and Duel.IsExistingMatchingCard(c458748.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetOriginalAttribute(),c)
end
-- 效果作用：过滤额外卡组中满足条件的「召唤兽」怪兽，用于特殊召唤。
function c458748.filter2(c,e,tp,att,mc)
	return c:IsSetCard(0xf4) and c:GetOriginalAttribute()~=att and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		-- 效果作用：检查是否有足够的场地空间用于融合召唤。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果原文内容：①：把自己场上1只「召唤兽」怪兽解放才能发动。原本属性和解放的怪兽不同的1只「召唤兽」怪兽当作融合召唤从额外卡组特殊召唤。
function c458748.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 效果作用：检查是否满足融合召唤的素材要求并确认场上可解放的「召唤兽」怪兽。
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) and Duel.CheckReleaseGroup(tp,c458748.filter1,1,nil,e,tp)
	end
	-- 效果作用：选择场上1只满足条件的「召唤兽」怪兽进行解放。
	local rg=Duel.SelectReleaseGroup(tp,c458748.filter1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetOriginalAttribute())
	-- 效果作用：将选中的怪兽从场上解放作为发动代价。
	Duel.Release(rg,REASON_COST)
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤1只来自额外卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果作用：执行融合召唤的处理流程。
function c458748.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：再次检查是否满足融合召唤的素材要求。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	local att=e:GetLabel()
	-- 效果作用：提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从额外卡组中选择满足条件的「召唤兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c458748.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,att,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 效果作用：将选中的怪兽以融合召唤方式特殊召唤到场上。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
			tc:CompleteProcedure()
		end
	end
end
