--ツイン・フォトン・リザード
-- 效果：
-- 名字带有「光子」的怪兽×2
-- 把这张卡解放才能发动。解放的这张卡的融合召唤使用过的一组融合素材怪兽从自己墓地特殊召唤。
function c29455728.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「光子」怪兽添加融合召唤手续：需要2只卡名含有『光子』字段的怪兽作为融合素材（setcode 0x55）。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x55),2,true)
	-- 把这张卡解放才能发动。解放的这张卡的融合召唤使用过的一组融合素材怪兽从自己墓地特殊召唤。
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
-- 效果发动代价的判定与支付：先确认此卡可解放；支付代价时解放此卡。
function c29455728.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将效果发动者（此卡）自身作为代价解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义融合素材回场的过滤条件：要求素材卡是自己墓地、曾作为此卡融合召唤的素材（reason含FUSION+MATERIAL）且导致其离场的卡为此卡、可被特殊召唤，并且与该融合素材组中的其他卡共同满足此卡的融合素材条件。
function c29455728.mgfilter(c,e,tp,fusc,mg)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and fusc:CheckFusionMaterial(mg,c,PLAYER_NONE,true)
end
-- 发动前的目标判定：获取此卡融合召唤使用的素材组；检查素材数量、主要怪兽区空格是否足够，且未处于禁止同时特殊召唤2只以上怪兽的效果影响下，并确认此卡确实以融合召唤方式出场、墓地素材均满足可特殊召唤条件；满足后设定特殊召唤的操作信息。
function c29455728.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetMaterial()
	if chk==0 then
		local ct=g:GetCount()
		-- 获取己方主要怪兽区剩余可用区域数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ct>0 and ft>=ct and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
			and g:FilterCount(c29455728.mgfilter,nil,e,tp,e:GetHandler(),g)==ct
	end
	-- 设置效果处理时的操作信息：将融合素材组g作为特殊召唤对象，数量为g的卡数，特殊召唤到己方场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理：若未受青眼精灵龙「不能同时特殊召唤2只以上怪兽」效果影响，且主要怪兽区空格充足、墓地素材全部满足条件，则将素材组特殊召唤。
function c29455728.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local g=e:GetHandler():GetMaterial()
	local ct=g:GetCount()
	-- 检查己方主要怪兽区空格数是否不少于需要特殊召唤的素材数量。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and g:FilterCount(c29455728.mgfilter,nil,e,tp,e:GetHandler(),g)==ct then
		-- 将融合素材组g以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
