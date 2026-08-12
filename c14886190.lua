--電脳堺都－九竜
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「电脑堺门」卡在自己的魔法与陷阱区域表侧表示放置。那之后，自己场上的「电脑堺门」卡数量的以下效果各能适用。
-- ●2张以上：这个回合，自己场上的「电脑堺」怪兽的攻击力上升200。
-- ●3张以上：从自己卡组上面把3张卡送去墓地。
-- ●4张：从额外卡组把最多4只「电脑堺」怪兽特殊召唤（同名卡最多1张）。
function c14886190.initial_effect(c)
	-- ①：从卡组把1张「电脑堺门」卡在自己的魔法与陷阱区域表侧表示放置。那之后，自己场上的「电脑堺门」卡数量的以下效果各能适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14886190,0))  --"从卡组放置"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14886190+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14886190.target)
	e1:SetOperation(c14886190.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡组中是否满足条件的「电脑堺门」卡
function c14886190.tffilter(c,tp)
	return c:IsSetCard(0x114e) and not c:IsType(TYPE_FIELD+TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤函数，用于统计场上「电脑堺门」卡的数量
function c14886190.gtfilter(c)
	return c:IsSetCard(0x114e) and c:IsFaceup()
end
-- 过滤函数，用于判断额外卡组中是否满足条件的「电脑堺」怪兽
function c14886190.spfilter(c,e,tp)
	-- 判断怪兽是否为「电脑堺」卡族且可以特殊召唤，并检查是否有足够的额外召唤区域
	return c:IsSetCard(0x14e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 过滤函数，用于判断是否为XYZ、同调或融合怪兽
function c14886190.exfilter1(c)
	return c:IsFacedown() and c:IsType(TYPE_XYZ+TYPE_SYNCHRO+TYPE_FUSION)
end
-- 过滤函数，用于判断是否为pendulum或link怪兽
function c14886190.exfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) or c:IsFacedown() and c:IsType(TYPE_LINK)
end
-- 筛选函数，用于选择满足条件的怪兽进行特殊召唤
function c14886190.fselect(g,ft1,ft2,ect,ft)
	-- 检查所选怪兽组是否满足卡名各不相同的要求
	return aux.dncheck(g) and #g<=ft and #g<=ect
		and g:FilterCount(c14886190.exfilter1,nil)<=ft1
		and g:FilterCount(c14886190.exfilter2,nil)<=ft2
end
-- 效果的发动条件判断函数
function c14886190.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家场上魔法与陷阱区域的可用空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		-- 判断是否满足发动条件：场上魔法与陷阱区域有空格且卡组中有「电脑堺门」卡
		return ft>0 and Duel.IsExistingMatchingCard(c14886190.tffilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
end
-- 效果的发动处理函数
function c14886190.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上魔法与陷阱区域是否有空格
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置的「电脑堺门」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	-- 从卡组中选择一张「电脑堺门」卡
	local tc=Duel.SelectMatchingCard(tp,c14886190.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选中的卡放置到场上
		if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			-- 统计场上「电脑堺门」卡的数量
			local gc=Duel.GetMatchingGroupCount(c14886190.gtfilter,tp,LOCATION_ONFIELD,0,nil)
			-- 若场上「电脑堺门」卡数量大于等于2，询问是否发动攻击力上升效果
			if gc>=2 and Duel.SelectYesNo(tp,aux.Stringid(14886190,1)) then  --"是否把怪兽的攻击力上升？"
				-- 中断当前效果，使之后的效果处理视为不同时处理
				Duel.BreakEffect()
				-- ●2张以上：这个回合，自己场上的「电脑堺」怪兽的攻击力上升200。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetTargetRange(LOCATION_MZONE,0)
				-- 设置效果的目标为「电脑堺」怪兽
				e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x14e))
				e1:SetValue(200)
				e1:SetReset(RESET_PHASE+PHASE_END)
				-- 将攻击力上升效果注册到场上
				Duel.RegisterEffect(e1,tp)
			end
			-- 若场上「电脑堺门」卡数量大于等于3，询问是否发动从卡组送3张卡到墓地的效果
			if gc>=3 and Duel.IsPlayerCanDiscardDeck(tp,3) and Duel.SelectYesNo(tp,aux.Stringid(14886190,2)) then  --"是否从卡组把卡送去墓地？"
				-- 中断当前效果，使之后的效果处理视为不同时处理
				Duel.BreakEffect()
				-- 从卡组上方送3张卡到墓地
				Duel.DiscardDeck(tp,3,REASON_EFFECT)
			end
			-- 若场上「电脑堺门」卡数量等于4，询问是否发动从额外卡组特殊召唤的效果
			if gc==4 and Duel.IsExistingMatchingCard(c14886190.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then
				-- 获取额外卡组中可以特殊召唤的XYZ、同调或融合怪兽的可用空格数
				local ft1=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ+TYPE_SYNCHRO+TYPE_FUSION)
				-- 获取额外卡组中可以特殊召唤的pendulum或link怪兽的可用空格数
				local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
				-- 获取玩家场上可用的怪兽区域数量
				local ft=Duel.GetUsableMZoneCount(tp)
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中：禁止该玩家同时特殊召唤2只以上怪兽
				if Duel.IsPlayerAffectedByEffect(tp,59822133) then
					if ft1>0 then ft1=1 end
					if ft2>0 then ft2=1 end
					if ft>0 then ft=1 end
				end
				-- 计算实际可用的特殊召唤数量
				local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
				-- 若满足条件，询问是否发动从额外卡组特殊召唤的效果
				if ect>0 and (ft1>0 or ft2>0) and Duel.SelectYesNo(tp,aux.Stringid(14886190,3)) then  --"是否从额外卡组特殊召唤？"
					-- 中断当前效果，使之后的效果处理视为不同时处理
					Duel.BreakEffect()
					-- 获取额外卡组中所有满足条件的「电脑堺」怪兽
					local sg=Duel.GetMatchingGroup(c14886190.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
					-- 提示玩家选择要特殊召唤的怪兽
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local rg=sg:SelectSubGroup(tp,c14886190.fselect,false,1,4,ft1,ft2,ect,ft)
					-- 将选中的怪兽特殊召唤到场上
					Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
