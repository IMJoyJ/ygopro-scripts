--ツイン・フォトン・リザード
-- 效果：
-- 名字带有「光子」的怪兽×2
-- 把这张卡解放才能发动。解放的这张卡的融合召唤使用过的一组融合素材怪兽从自己墓地特殊召唤。
function c29455728.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用2个名字带有「光子」的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x55),2,true)
	-- 名字带有「光子」的怪兽×2
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29455728,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c29455728.cost)
	e1:SetTarget(c29455728.target)
	e1:SetOperation(c29455728.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否可以被解放作为发动代价
function c29455728.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从场上解放作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤满足条件的墓地怪兽，这些怪兽必须是通过融合召唤使用的素材，并且可以被特殊召唤
function c29455728.mgfilter(c,e,tp,fusc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fusc:CheckFusionMaterial(mg,c,PLAYER_NONE,true)
end
-- 检测是否满足特殊召唤条件，包括场上的空位、是否受到青眼精灵龙效果影响、是否为融合召唤 summoned 以及融合素材是否满足条件
function c29455728.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetMaterial()
	if chk==0 then
		local ct=g:GetCount()
		-- 获取玩家在主要怪兽区的可用空位数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ct>0 and ft>=ct and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
			and g:FilterCount(c29455728.mgfilter,nil,e,tp,e:GetHandler(),g)==ct
	end
	-- 设置连锁操作信息，表示将要特殊召唤指定数量的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 执行特殊召唤操作，如果满足条件则将符合条件的怪兽特殊召唤到场上
function c29455728.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local g=e:GetHandler():GetMaterial()
	local ct=g:GetCount()
	-- 检查场上是否有足够的空位来特殊召唤这些怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and g:FilterCount(c29455728.mgfilter,nil,e,tp,e:GetHandler(),g)==ct then
		-- 将满足条件的怪兽组特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
