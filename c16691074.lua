--オッドアイズ・アブソリュート・ドラゴン
-- 效果：
-- 7星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效。那之后，可以从自己的手卡·墓地把1只「异色眼」怪兽特殊召唤。
-- ②：超量召唤的这张卡被送去墓地的场合才能发动。从额外卡组把「异色眼绝零龙」以外的1只「异色眼」怪兽特殊召唤。
function c16691074.initial_effect(c)
	-- 为异色眼绝零龙添加超量召唤手续：以2只7星怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己或对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效。那之后，可以从自己的手卡·墓地把1只「异色眼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16691074,0))  --"攻击无效"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,16691074)
	e1:SetCost(c16691074.atkcost)
	e1:SetOperation(c16691074.atkop)
	c:RegisterEffect(e1)
	-- ②：超量召唤的这张卡被送去墓地的场合才能发动。从额外卡组把「异色眼绝零龙」以外的1只「异色眼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16691074,1))  --"从额外卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,16691075)
	e2:SetCondition(c16691074.spcon)
	e2:SetTarget(c16691074.sptg)
	e2:SetOperation(c16691074.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：检查这张卡是否有1个超量素材可取除，若有则取除1个超量素材作为代价。
function c16691074.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：筛选手卡·墓地中满足「异色眼」字段且能够被特殊召唤的怪兽。
function c16691074.spfilter1(c,e,tp)
	return c:IsSetCard(0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果处理：无效攻击，然后在我方怪兽区有空位时，从手卡·墓地选择1只「异色眼」怪兽特殊召唤。
function c16691074.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.NegateAttack()无效当前攻击，返回true表示成功无效，才继续后续特殊召唤处理。
	if Duel.NegateAttack() then
		-- 检查我方怪兽区是否有空位；若无空位则直接结束，无法进行特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取我方手卡·墓地中满足spfilter1且不受王家长眠之谷影响的「异色眼」怪兽集合。
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c16691074.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		-- 若存在符合条件的怪兽且我方玩家选择“是”（确认特殊召唤），则继续后续处理。
		if g1:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(16691074,2)) then  --"是否要特殊召唤？"
			-- 中断当前效果处理，使后续特殊召唤作为独立时点，避免错失时点。
			Duel.BreakEffect()
			-- 显示选择提示，要求玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local g2=g1:Select(tp,1,1,nil)
			-- 将选中的怪兽以表侧表示特殊召唤到我方场上。
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的发动条件：这张卡从怪兽区送去墓地，且其召唤类型为超量召唤。
function c16691074.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤函数：筛选额外卡组中满足「异色眼」字段、不是「异色眼绝零龙」、能够被特殊召唤，且我方有额外卡组特殊召唤空位的怪兽。
function c16691074.spfilter2(c,e,tp)
	return c:IsSetCard(0x99) and not c:IsCode(16691074)
		-- 追加判定：该额外卡组怪兽能够被特殊召唤，并且我方有足够的区域允许从额外卡组特殊召唤该怪兽。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动目标处理：确认额外卡组存在可选目标，并设置本次操作信息为特殊召唤1只额外卡组怪兽。
function c16691074.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：我方额外卡组是否存在至少1只满足spfilter2的「异色眼」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c16691074.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：从额外卡组选择1只符合条件的「异色眼」怪兽特殊召唤到我方场上。
function c16691074.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择1只满足spfilter2的「异色眼」怪兽。
	local g=Duel.SelectMatchingCard(tp,c16691074.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
