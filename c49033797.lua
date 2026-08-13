--禁断のトラペゾヘドロン
-- 效果：
-- 「禁断的偏方面体」在1回合只能发动1张。
-- ①：自己场上的融合·同调·超量怪兽只有那之内2种类的场合，那个组合的以下效果适用。
-- ●融合·同调怪兽：从额外卡组把1只「外神」超量怪兽特殊召唤，把这张卡在下面重叠作为超量素材。
-- ●同调·超量怪兽：从额外卡组把1只「旧神」融合怪兽特殊召唤。
-- ●超量·融合怪兽：从额外卡组把1只「古神」同调怪兽特殊召唤。
function c49033797.initial_effect(c)
	-- 「禁断的偏方面体」在1回合只能发动1张。①：自己场上的融合·同调·超量怪兽只有那之内2种类的场合，那个组合的以下效果适用。●融合·同调怪兽：从额外卡组把1只「外神」超量怪兽特殊召唤，把这张卡在下面重叠作为超量素材。●同调·超量怪兽：从额外卡组把1只「旧神」融合怪兽特殊召唤。●超量·融合怪兽：从额外卡组把1只「古神」同调怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,49033797+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c49033797.target)
	e1:SetOperation(c49033797.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：用于判断怪兽是否为表侧表示且属于指定的种类（融合/同调/超量）。
function c49033797.cfilter(c,tpe)
	return c:IsFaceup() and c:IsType(tpe)
end
-- 定义额外卡组怪兽的筛选条件：属于指定系列、可被效果特殊召唤，且额外卡组怪兽有可用空格。
function c49033797.filter(c,e,tp,cat)
	-- 筛选条件核心：怪兽系列匹配、满足特殊召唤条件、存在可用的额外怪兽区空格。
	return c:IsSetCard(cat) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 发动时的合法性判定：根据自己场上表侧表示存在的融合·同调·超量怪兽的种类组合，确定可适用的分支并检查对应额外卡组怪兽是否存在；随后设置特殊召唤的操作信息。
function c49033797.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local flag=0
		-- 检查自己场上是否存在表侧表示融合怪兽，若存在则flag加上1（标记融合种类）。
		if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_FUSION) then flag=flag+1 end
		-- 检查自己场上是否存在表侧表示同调怪兽，若存在则flag加上2（标记同调种类）。
		if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO) then flag=flag+2 end
		-- 检查自己场上是否存在表侧表示超量怪兽，若存在则flag加上4（标记超量种类）。
		if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ) then flag=flag+4 end
		if flag==3 then
			-- 当组合为融合+同调时（flag==3），确认该卡为魔法卡发动、存在可特殊召唤的「外神」超量怪兽，且此卡可以作为超量素材。
			return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(c49033797.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,0xb6)
				and e:GetHandler():IsCanOverlay()
		elseif flag==6 then
			-- 当组合为同调+超量时（flag==6），确认存在可特殊召唤的「旧神」融合怪兽。
			return Duel.IsExistingMatchingCard(c49033797.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,0xb7)
		elseif flag==5 then
			-- 当组合为超量+融合时（flag==5），确认存在可特殊召唤的「古神」同调怪兽。
			return Duel.IsExistingMatchingCard(c49033797.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,0xb8)
		else return false end
	end
	-- 登记本次效果的操作信息：将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理时的执行逻辑：再次判定场上怪兽种类组合，按组合从额外卡组特殊召唤对应怪兽，并在融合+同调组合时将发动中的这张卡作为超量素材叠放。
function c49033797.activate(e,tp,eg,ep,ev,re,r,rp)
	local flag=0
	-- 效果处理时再次检查是否存在表侧表示融合怪兽，存在则flag加上1。
	if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_FUSION) then flag=flag+1 end
	-- 效果处理时再次检查是否存在表侧表示同调怪兽，存在则flag加上2。
	if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO) then flag=flag+2 end
	-- 效果处理时再次检查是否存在表侧表示超量怪兽，存在则flag加上4。
	if Duel.IsExistingMatchingCard(c49033797.cfilter,tp,LOCATION_MZONE,0,1,nil,TYPE_XYZ) then flag=flag+4 end
	if flag==3 then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只符合条件的「外神」超量怪兽。
		local g=Duel.SelectMatchingCard(tp,c49033797.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,0xb6)
		local sc=g:GetFirst()
		if sc then
			-- 将选择的「外神」超量怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			local c=e:GetHandler()
			if c:IsRelateToEffect(e) and c:IsCanOverlay() then
				c:CancelToGrave()
				-- 将发动中的这张「禁断的偏方面体」重叠到该超量怪兽下面作为超量素材。
				Duel.Overlay(sc,Group.FromCards(c))
			end
		end
	elseif flag==6 then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只符合条件的「旧神」融合怪兽。
		local g=Duel.SelectMatchingCard(tp,c49033797.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,0xb7)
		if g:GetCount()>0 then
			-- 将选择的「旧神」融合怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif flag==5 then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只符合条件的「古神」同调怪兽。
		local g=Duel.SelectMatchingCard(tp,c49033797.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,0xb8)
		if g:GetCount()>0 then
			-- 将选择的「古神」同调怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
