--禁断のトラペゾヘドロン
-- 效果：
-- 「禁断的偏方面体」在1回合只能发动1张。
-- ①：自己场上的融合·同调·超量怪兽只有那之内2种类的场合，那个组合的以下效果适用。
-- ●融合·同调怪兽：从额外卡组把1只「外神」超量怪兽特殊召唤，把这张卡在下面重叠作为超量素材。
-- ●同调·超量怪兽：从额外卡组把1只「旧神」融合怪兽特殊召唤。
-- ●超量·融合怪兽：从额外卡组把1只「古神」同调怪兽特殊召唤。
function c49033797.initial_effect(c)
	-- 创建效果并设置为发动时点，限制每回合只能发动一次，目标为特殊召唤，操作为activate函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,49033797+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c49033797.target)
	e1:SetOperation(c49033797.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查玩家场上是否有表侧表示的指定类型的怪兽
function c49033797.cfilter(c,tpe)
	return c:IsFaceup() and c:IsType(tpe)
end
-- 过滤函数，检查额外卡组中是否满足条件的卡（属于特定系列、可特殊召唤且有召唤空位）
function c49033797.filter(c,e,tp,cat)
	-- 检查卡是否属于特定系列、可特殊召唤且有召唤空位
	return c:IsSetCard(cat) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 判断是否满足发动条件：统计场上融合、同调、超量怪兽数量，根据组合决定可发动的效果类型
function c49033797.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local flag=0
		-- 检测玩家场上是否存在表侧表示的融合怪兽
		if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_FUSION) then flag=flag+1 end
		-- 检测玩家场上是否存在表侧表示的同调怪兽
		if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO) then flag=flag+2 end
		-- 检测玩家场上是否存在表侧表示的超量怪兽
		if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ) then flag=flag+4 end
		if flag==3 then
			-- 判断是否满足融合+同调组合效果的发动条件：额外卡组存在外神超量怪兽且此卡可叠放
			return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(c49033797.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,0xb6)
				and e:GetHandler():IsCanOverlay()
		elseif flag==6 then
			-- 判断是否满足同调+超量组合效果的发动条件：额外卡组存在旧神融合怪兽
			return Duel.IsExistingMatchingCard(c49033797.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,0xb7)
		elseif flag==5 then
			-- 判断是否满足超量+融合组合效果的发动条件：额外卡组存在古神同调怪兽
			return Duel.IsExistingMatchingCard(c49033797.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,0xb8)
		else return false end
	end
	-- 设置连锁操作信息为特殊召唤，目标为额外卡组中的一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动函数，根据场上怪兽类型组合决定执行哪种效果
function c49033797.activate(e,tp,eg,ep,ev,re,r,rp)
	local flag=0
	-- 检测玩家场上是否存在表侧表示的融合怪兽
	if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_FUSION) then flag=flag+1 end
	-- 检测玩家场上是否存在表侧表示的同调怪兽
	if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO) then flag=flag+2 end
	-- 检测玩家场上是否存在表侧表示的超量怪兽
	if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ) then flag=flag+4 end
	if flag==3 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组中选择一张满足条件的外神超量怪兽
		local g=Duel.SelectMatchingCard(tp,c49033797.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,0xb6)
		local sc=g:GetFirst()
		if sc then
			-- 将选中的外神超量怪兽特殊召唤到场上
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			local c=e:GetHandler()
			if c:IsRelateToEffect(e) and c:IsCanOverlay() then
				c:CancelToGrave()
				-- 将此卡叠放于已特殊召唤的怪兽下方作为超量素材
				Duel.Overlay(sc,Group.FromCards(c))
			end
		end
	elseif flag==6 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组中选择一张满足条件的旧神融合怪兽
		local g=Duel.SelectMatchingCard(tp,c49033797.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,0xb7)
		if g:GetCount()>0 then
			-- 将选中的旧神融合怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif flag==5 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组中选择一张满足条件的古神同调怪兽
		local g=Duel.SelectMatchingCard(tp,c49033797.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,0xb8)
		if g:GetCount()>0 then
			-- 将选中的古神同调怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
