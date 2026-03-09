--ヌメロン・クリエイション
-- 效果：
-- 这个卡名在规则上也当作「银河眼」卡使用。这个卡名的效果1回合只能适用1次。
-- ①：原本攻击力是3000以上的龙族·光属性怪兽在场上有3只以上存在的场合才能发动。从额外卡组把1只龙族「No.」超量怪兽特殊召唤。那之后，把场上的这张卡在那只怪兽下面重叠作为超量素材。
function c46382143.initial_effect(c)
	-- 创建效果，设置为发动时点，条件为场上有3只以上光属性龙族且原本攻击力3000以上的怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c46382143.condition)
	e1:SetTarget(c46382143.target)
	e1:SetOperation(c46382143.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为光属性龙族且原本攻击力3000以上的正面表示怪兽
function c46382143.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON) and c:GetBaseAttack()>=3000 and c:IsFaceup()
end
-- 效果条件函数，检查场上是否存在3只以上满足cfilter条件的怪兽
function c46382143.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足cfilter条件的怪兽数量是否不少于3
	return Duel.GetMatchingGroupCount(c46382143.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)>=3
end
-- 过滤函数，用于筛选可以特殊召唤的龙族超量怪兽（No.系列）
function c46382143.spfilter(c,e,tp)
	return c:IsSetCard(0x48) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有足够的额外卡组召唤区域来特殊召唤该怪兽
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果目标函数，判断是否满足发动条件：未使用过此效果且额外卡组存在符合条件的怪兽
function c46382143.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断该玩家是否已使用过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,46382143)==0
		-- 检查额外卡组是否存在满足spfilter条件的怪兽
		and Duel.IsExistingMatchingCard(c46382143.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤，目标为额外卡组中的一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动函数，执行特殊召唤并将其叠放于召唤出的怪兽下方
function c46382143.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认该玩家是否已使用过此效果，若已使用则不继续处理
	if Duel.GetFlagEffect(tp,46382143)~=0 then return end
	-- 注册标识效果，使该效果在本回合内只能发动一次
	Duel.RegisterFlagEffect(tp,46382143,RESET_PHASE+PHASE_END,0,1)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择一只满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,c46382143.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	-- 将选中的怪兽特殊召唤到场上
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsLocation(LOCATION_MZONE)
		and c:IsLocation(LOCATION_ONFIELD) and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		-- 中断当前效果处理，使后续处理不与当前效果同时进行
		Duel.BreakEffect()
		c:CancelToGrave()
		-- 将此卡叠放于已特殊召唤出的怪兽下方作为超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
