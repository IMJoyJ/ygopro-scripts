--ヴェイドスの目覚め
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「灰灭之都 奥布西地暮」在自己或对方的场地区域表侧表示放置。那之后，对方的场地区域有卡存在的场合，可以从卡组把1只5星以上的炎族·暗属性怪兽加入手卡。这张卡的发动后，直到回合结束时自己不是炎族怪兽不能从卡组·额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化该卡的效果：登记本卡记载的「灰灭之都 奥布西地暮」；创建并注册本卡的魔法发动效果（类型为ACTIVATE，可在自由时点发动），设置其检索/放置场地、可选检索以及发动后的自肃，并限制同名卡1回合只能发动1次。
function s.initial_effect(c)
	-- 将卡号3055018（「灰灭之都 奥布西地暮」）登记为本卡记载的卡名，便于规则上识别这张卡与「灰灭之都 奥布西地暮」的关联。
	aux.AddCodeList(c,3055018)
	-- 「这个卡名的卡在1回合只能发动1张。①：从卡组把1张『灰灭之都 奥布西地暮』在自己或对方的场地区域表侧表示放置。那之后，对方的场地区域有卡存在的场合，可以从卡组把1只5星以上的炎族·暗属性怪兽加入手卡。这张卡的发动后，直到回合结束时自己不是炎族怪兽不能从卡组·额外卡组特殊召唤。」
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义放置场地用的筛选函数：选择卡组中卡名为「灰灭之都 奥布西地暮」且未被禁止的卡。
function s.setfilter(c)
	return c:IsCode(3055018) and not c:IsForbidden()
end
-- 发动时的目标判定：检查卡组是否存在1张符合条件的「灰灭之都 奥布西地暮」，存在则满足发动条件。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（发动合法性检查）时，确认卡组中存在可放置的「灰灭之都 奥布西地暮」，以此作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义检索手卡的筛选函数：选择5星以上、炎族、暗属性且能够加入手卡的怪兽。
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_PYRO) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- 效果处理：先从卡组选择1张「灰灭之都 奥布西地暮」，由玩家选择放入自己或对方的场地区域；若目标场地区域已有卡则旧卡按规则送入墓地。放置成功后，若对方场地区域有卡且卡组存在符合条件的怪兽，则询问玩家是否将其中1只加入手卡并让对方确认。最后给己方附加直到回合结束前不是炎族怪兽不能从卡组/额外卡组特殊召唤的自肃。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择卡片的提示信息，提示玩家正在选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张符合setfilter条件的「灰灭之都 奥布西地暮」，并取得第1张作为要放置的卡。
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	local p=tp
	-- 弹出选项让玩家选择放置到自己场地区域还是对方场地区域；若选择对方，则将放置目标玩家p改为对方。
	if Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==1 then  --"在自己场地区域放置/在对方场地区域放置"
		p=1-p
	end
	if tc then
		-- 获取目标玩家场地区域（LOCATION_SZONE的seq=5）中已有的卡，用于后续的场地替换处理。
		local fc=Duel.GetFieldCard(p,LOCATION_SZONE,5)
		if fc then
			-- 将原本存在于场地区域的卡以规则原因（REASON_RULE）送去墓地，这是场地魔法替换的基本规则。
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续效果视为不同时处理，避免因连续处理导致错过时点或产生不正确的连锁关系。
			Duel.BreakEffect()
		end
		-- 场地卡放置成功且对方场地区域有卡存在时，若卡组中存在符合条件的炎族暗属性怪兽，则询问玩家是否将其加入手卡；对应“那之后，对方的场地区域有卡存在的场合，可以从卡组把1只5星以上的炎族·暗属性怪兽加入手卡”。
		if Duel.MoveToField(tc,tp,p,LOCATION_FZONE,POS_FACEUP,true) and Duel.GetFieldGroupCount(tp,0,LOCATION_FZONE)>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否从卡组把怪兽加入手卡？"
			-- 再次中断效果处理，确保后续检索加入手卡的效果在独立时点处理。
			Duel.BreakEffect()
			-- 从卡组选择1只符合thfilter条件的怪兽，准备加入手卡。
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选择的怪兽以效果原因（REASON_EFFECT）加入持有者手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 让对方玩家确认加入手卡的卡，确认检索结果。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 「这张卡的发动后，直到回合结束时自己不是炎族怪兽不能从卡组·额外卡组特殊召唤。」
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，使其对发动玩家生效，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的判定函数：禁止自己不是炎族怪兽时，从卡组或额外卡组进行特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_PYRO) and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
