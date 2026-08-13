--電脳堺都－九竜
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「电脑堺门」卡在自己的魔法与陷阱区域表侧表示放置。那之后，自己场上的「电脑堺门」卡数量的以下效果各能适用。
-- ●2张以上：这个回合，自己场上的「电脑堺」怪兽的攻击力上升200。
-- ●3张以上：从自己卡组上面把3张卡送去墓地。
-- ●4张：从额外卡组把最多4只「电脑堺」怪兽特殊召唤（同名卡最多1张）。
function c14886190.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1张「电脑堺门」卡在自己的魔法与陷阱区域表侧表示放置。那之后，自己场上的「电脑堺门」卡数量的以下效果各能适用。●2张以上：这个回合，自己场上的「电脑堺」怪兽的攻击力上升200。●3张以上：从自己卡组上面把3张卡送去墓地。●4张：从额外卡组把最多4只「电脑堺」怪兽特殊召唤（同名卡最多1张）。
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
-- 过滤卡组中可作为放置对象的「电脑堺门」卡：必须属于「电脑堺门」字段，不能是场地魔法或怪兽，不能是禁止卡，且自己场上不存在同名卡。
function c14886190.tffilter(c,tp)
	return c:IsSetCard(0x114e) and not c:IsType(TYPE_FIELD+TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤用于计数的「电脑堺门」卡：必须是表侧表示且属于「电脑堺门」字段。
function c14886190.gtfilter(c)
	return c:IsSetCard(0x114e) and c:IsFaceup()
end
-- 过滤额外卡组中可被特殊召唤的「电脑堺」怪兽：属于「电脑堺」字段、能被当前效果特殊召唤，且额外卡组怪兽有可用区域。
function c14886190.spfilter(c,e,tp)
	-- 判断额外卡组的「电脑堺」怪兽是否满足特殊召唤条件：属于「电脑堺」字段、无特殊召唤限制，且额外卡组区域有空位。
	return c:IsSetCard(0x14e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 判定额外卡组中的里侧表示的XYZ、同调或融合怪兽，用于区分需要额外怪兽区域的种类。
function c14886190.exfilter1(c)
	return c:IsFacedown() and c:IsType(TYPE_XYZ+TYPE_SYNCHRO+TYPE_FUSION)
end
-- 判定额外卡组中的表侧灵摆怪兽或里侧连接怪兽，用于区分需要额外怪兽区域的特殊表示种类。注意优先级为（表侧且灵摆）或（里侧且连接）。
function c14886190.exfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) or c:IsFacedown() and c:IsType(TYPE_LINK)
end
-- 验证玩家选择特殊召唤的怪兽组是否可行：卡名互不相同、数量不超过可用怪兽区和额外召唤剩余数，且各类额外怪兽不超过对应类型的区域空格数。
function c14886190.fselect(g,ft1,ft2,ect,ft)
	-- 验证选择组的卡名互不相同，且数量不超过可用怪兽区空格数与额外召唤剩余次数。
	return aux.dncheck(g) and #g<=ft and #g<=ect
		and g:FilterCount(c14886190.exfilter1,nil)<=ft1
		and g:FilterCount(c14886190.exfilter2,nil)<=ft2
end
-- 发动时的合法性检查：确认自己魔陷区有可用空格（若从手牌发动需预留1格），且卡组中存在可放置的「电脑堺门」卡。
function c14886190.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己魔陷区的可用空格数。
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		-- 返回真条件：魔陷区有空格且卡组存在符合条件的「电脑堺门」卡。
		return ft>0 and Duel.IsExistingMatchingCard(c14886190.tffilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
end
-- 效果处理：从卡组选1张「电脑堺门」表侧放置到魔陷区，然后根据自己场上的「电脑堺门」数量依次适用对应分支效果。
function c14886190.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若魔陷区没有可用空格，则效果不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家显示“请选择要放置到场上的卡”的提示并进入选卡界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张符合条件的「电脑堺门」卡。
	local tc=Duel.SelectMatchingCard(tp,c14886190.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选择的「电脑堺门」卡以表侧表示移动到自己的魔法与陷阱区域，并立即适用其效果。
		if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			-- 计算自己场上表侧表示的「电脑堺门」卡的数量，用于决定后续适用的分支。
			local gc=Duel.GetMatchingGroupCount(c14886190.gtfilter,tp,LOCATION_ONFIELD,0,nil)
			-- 当「电脑堺门」数量在2张以上时，询问玩家是否让「电脑堺」怪兽攻击力上升。
			if gc>=2 and Duel.SelectYesNo(tp,aux.Stringid(14886190,1)) then  --"是否把怪兽的攻击力上升？"
				-- 中断当前效果链，使之后的处理视为另一起时点，避免错过时点。
				Duel.BreakEffect()
				-- 那之后，自己场上的「电脑堺门」卡数量的以下效果各能适用。●2张以上：这个回合，自己场上的「电脑堺」怪兽的攻击力上升200。●3张以上：从自己卡组上面把3张卡送去墓地。●4张：从额外卡组把最多4只「电脑堺」怪兽特殊召唤（同名卡最多1张）。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetTargetRange(LOCATION_MZONE,0)
				-- 将攻击力上升效果的对象限定为自己场上表侧表示且属于「电脑堺」字段的怪兽。
				e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x14e))
				e1:SetValue(200)
				e1:SetReset(RESET_PHASE+PHASE_END)
				-- 将攻击力上升200的永续效果注册给当前玩家，持续到回合结束。
				Duel.RegisterEffect(e1,tp)
			end
			-- 当「电脑堺门」数量在3张以上且卡组足够时，询问玩家是否适用从卡组顶把3张卡送去墓地的效果。
			if gc>=3 and Duel.IsPlayerCanDiscardDeck(tp,3) and Duel.SelectYesNo(tp,aux.Stringid(14886190,2)) then  --"是否从卡组把卡送去墓地？"
				-- 中断当前连锁，使堆墓效果的时点独立。
				Duel.BreakEffect()
				-- 从自己卡组最上方将3张卡送去墓地。
				Duel.DiscardDeck(tp,3,REASON_EFFECT)
			end
			-- 当「电脑堺门」数量恰好为4张且额外卡组存在可特殊召唤的「电脑堺」怪兽时，进入额外卡组特殊召唤分支。
			if gc==4 and Duel.IsExistingMatchingCard(c14886190.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) then
				-- 计算可用于从额外卡组特殊召唤XYZ、同调、融合怪兽的额外怪兽区域空格数。
				local ft1=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ+TYPE_SYNCHRO+TYPE_FUSION)
				-- 计算可用于从额外卡组特殊召唤灵摆、连接怪兽的额外怪兽区域空格数。
				local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
				-- 获取自己场上可用的怪兽区域数量。
				local ft=Duel.GetUsableMZoneCount(tp)
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				if Duel.IsPlayerAffectedByEffect(tp,59822133) then
					if ft1>0 then ft1=1 end
					if ft2>0 then ft2=1 end
					if ft>0 then ft=1 end
				end
				-- 若「召唤之门」的效果适用中，则用该效果剩余的额外召唤次数作为特招上限，否则使用可用怪兽区数量作为上限。
				local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
				-- 当存在可用区域且玩家选择是时，准备从额外卡组选择要特殊召唤的「电脑堺」怪兽。
				if ect>0 and (ft1>0 or ft2>0) and Duel.SelectYesNo(tp,aux.Stringid(14886190,3)) then  --"是否从额外卡组特殊召唤？"
					-- 中断当前连锁，使特殊召唤处理独立时点。
					Duel.BreakEffect()
					-- 收集额外卡组中所有符合条件的「电脑堺」怪兽作为候选。
					local sg=Duel.GetMatchingGroup(c14886190.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
					-- 提示玩家选择要特殊召唤的卡。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local rg=sg:SelectSubGroup(tp,c14886190.fselect,false,1,4,ft1,ft2,ect,ft)
					-- 将选中的「电脑堺」怪兽以表侧攻击表示特殊召唤到自己场上。
					Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
