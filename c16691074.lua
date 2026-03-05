--オッドアイズ・アブソリュート・ドラゴン
-- 效果：
-- 7星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效。那之后，可以从自己的手卡·墓地把1只「异色眼」怪兽特殊召唤。
-- ②：超量召唤的这张卡被送去墓地的场合才能发动。从额外卡组把「异色眼绝零龙」以外的1只「异色眼」怪兽特殊召唤。
function c16691074.initial_effect(c)
	-- 为卡片添加等级为7、需要2只怪兽进行超量召唤的手续
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- 自己或对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。那次攻击无效。那之后，可以从自己的手卡·墓地把1只「异色眼」怪兽特殊召唤。
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
	-- 超量召唤的这张卡被送去墓地的场合才能发动。从额外卡组把「异色眼绝零龙」以外的1只「异色眼」怪兽特殊召唤。
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
-- 支付1个超量素材作为费用
function c16691074.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足「异色眼」卡组且可以特殊召唤的怪兽
function c16691074.spfilter1(c,e,tp)
	return c:IsSetCard(0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 无效攻击并检索满足条件的「异色眼」怪兽进行特殊召唤
function c16691074.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效此次攻击
	if Duel.NegateAttack() then
		-- 判断场上是否有怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 检索满足条件的「异色眼」怪兽
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(c16691074.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		-- 询问玩家是否发动特殊召唤
		if g1:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(16691074,2)) then  --"是否要特殊召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local g2=g1:Select(tp,1,1,nil)
			-- 将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 判断此卡是否为超量召唤且从场上送去墓地
function c16691074.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤满足「异色眼」卡组且不是此卡、可以特殊召唤的怪兽
function c16691074.spfilter2(c,e,tp)
	return c:IsSetCard(0x99) and not c:IsCode(16691074)
		-- 判断额外卡组是否有足够的特殊召唤区域
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置特殊召唤操作信息
function c16691074.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的额外卡组怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c16691074.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 从额外卡组选择1只「异色眼」怪兽特殊召唤
function c16691074.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c16691074.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
