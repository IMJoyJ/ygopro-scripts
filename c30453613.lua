--ヴェイドスの目覚め
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「灰灭之都 奥布西地暮」在自己或对方的场地区域表侧表示放置。那之后，对方的场地区域有卡存在的场合，可以从卡组把1只5星以上的炎族·暗属性怪兽加入手卡。这张卡的发动后，直到回合结束时自己不是炎族怪兽不能从卡组·额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果，设置发动条件和处理函数
function s.initial_effect(c)
	-- 记录该卡与「灰灭之都 奥布西地暮」的关联
	aux.AddCodeList(c,3055018)
	-- ①：从卡组把1张「灰灭之都 奥布西地暮」在自己或对方的场地区域表侧表示放置。那之后，对方的场地区域有卡存在的场合，可以从卡组把1只5星以上的炎族·暗属性怪兽加入手卡。这张卡的发动后，直到回合结束时自己不是炎族怪兽不能从卡组·额外卡组特殊召唤。
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
-- 设置过滤函数，用于检索卡组中「灰灭之都 奥布西地暮」
function s.setfilter(c)
	return c:IsCode(3055018) and not c:IsForbidden()
end
-- 设置效果的发动条件，检查卡组中是否存在「灰灭之都 奥布西地暮」
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「灰灭之都 奥布西地暮」
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 设置过滤函数，用于检索卡组中满足条件的炎族·暗属性5星以上怪兽
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_PYRO) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，执行放置卡片、选择是否加入手卡等操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择一张「灰灭之都 奥布西地暮」
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	local p=tp
	-- 让玩家选择放置到自己或对方场地区域
	if Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==1 then  --"在自己场地区域放置/在对方场地区域放置"
		p=1-p
	end
	if tc then
		-- 获取目标玩家场地区域的卡片
		local fc=Duel.GetFieldCard(p,LOCATION_SZONE,5)
		if fc then
			-- 将目标区域的卡片送入墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理
			Duel.BreakEffect()
		end
		-- 判断是否满足条件并提示玩家是否加入手卡
		if Duel.MoveToField(tc,tp,p,LOCATION_FZONE,POS_FACEUP,true) and Duel.GetFieldGroupCount(tp,0,LOCATION_FZONE)>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否从卡组把怪兽加入手卡？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 从卡组中选择一只符合条件的怪兽
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- ①：从卡组把1张「灰灭之都 奥布西地暮」在自己或对方的场地区域表侧表示放置。那之后，对方的场地区域有卡存在的场合，可以从卡组把1只5星以上的炎族·暗属性怪兽加入手卡。这张卡的发动后，直到回合结束时自己不是炎族怪兽不能从卡组·额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使自己不能从卡组或额外卡组特殊召唤非炎族怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 设置限制特殊召唤的效果过滤函数，禁止非炎族怪兽从卡组或额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_PYRO) and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
end
