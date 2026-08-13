--法の聖典
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只「召唤兽」怪兽解放才能发动。原本属性和解放的怪兽不同的1只「召唤兽」怪兽当作融合召唤从额外卡组特殊召唤。
function c458748.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只「召唤兽」怪兽解放才能发动。原本属性和解放的怪兽不同的1只「召唤兽」怪兽当作融合召唤从额外卡组特殊召唤。
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
-- 代价处理：将效果标签设为100作为标记，实际代价的检查与选择在target阶段进行，此处直接返回true让效果进入目标选择。
function c458748.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 解放素材过滤函数：筛选要解放的召唤兽怪兽，要求它存在一只原本属性不同且可进行融合召唤的召唤兽怪兽作为特殊召唤对象。
function c458748.filter1(c,e,tp)
	-- 返回true的条件：c是召唤兽怪兽，且从额外卡组能选到原本属性与c不同、可融合召唤且满足融合素材的召唤兽怪兽。
	return c:IsSetCard(0xf4) and Duel.IsExistingMatchingCard(c458748.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetOriginalAttribute(),c)
end
-- 特殊召唤对象过滤函数：从额外卡组筛选原本属性与解放怪兽不同、能够用融合召唤方式特殊召唤、具备融合素材且有足够额外怪兽区域空位的召唤兽怪兽。
function c458748.filter2(c,e,tp,att,mc)
	return c:IsSetCard(0xf4) and c:GetOriginalAttribute()~=att and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
		-- 额外检查：在解放素材后，额外卡组怪兽可用的特殊召唤区域仍有空位，即能正常特殊召唤目标怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 目标处理：先确认存在可解放的召唤兽怪兽且能特殊召唤另一只符合条件的召唤兽；然后选择1只要解放的召唤兽，记录其原本属性，将其解放，并把本次操作登记为从额外卡组特殊召唤1只怪兽。
function c458748.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 发动合法性检查：确认没有必须作为融合素材的效果影响，且存在至少1只可解放的召唤兽怪兽（由filter1筛选）来满足效果条件。
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) and Duel.CheckReleaseGroup(tp,c458748.filter1,1,nil,e,tp)
	end
	-- 选择玩家场上1只满足filter1条件的召唤兽怪兽作为解放代价。
	local rg=Duel.SelectReleaseGroup(tp,c458748.filter1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetOriginalAttribute())
	-- 将选择的召唤兽怪兽解放，作为发动效果的代价。
	Duel.Release(rg,REASON_COST)
	-- 登记操作信息：本次效果需要从额外卡组特殊召唤1只怪兽，供连锁处理时相关检测（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：确认没有必须融合素材的干扰后，从额外卡组选择1只原本属性与解放怪兽不同的召唤兽怪兽，以融合召唤方式特殊召唤；成功后调用CompleteProcedure使其完成正规出场手续。
function c458748.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认不存在必须作为融合素材的效果，若存在则本次特殊召唤不处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	local att=e:GetLabel()
	-- 显示特殊召唤卡牌的选择提示消息，让玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组筛选并选择1只满足filter2条件的召唤兽怪兽，att是解放怪兽的原本属性，用于保证目标属性不同。
	local g=Duel.SelectMatchingCard(tp,c458748.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,att,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 若融合召唤特殊召唤成功（返回值不为0），则执行CompleteProcedure完成正规召唤手续。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
			tc:CompleteProcedure()
		end
	end
end
