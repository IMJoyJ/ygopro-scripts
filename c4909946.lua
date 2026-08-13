--ボスオンパレード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，从卡组把1只「巨大战舰」怪兽加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。自己的手卡·场上1只怪兽破坏，从卡组把1只攻击力1200而守备力1000以下的机械族·光属性怪兽在自己或对方的场上特殊召唤。
-- ③：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1张「头目连战」在自己场上表侧表示放置。
local s,id,o=GetID()
-- 注册「头目大游行」的三个效果：①发动时检索「巨大战舰」；②起动效果破坏手卡·场上怪兽并特召机械族光属性怪兽；③除外墓地的自身并放置「头目连战」。
function s.initial_effect(c)
	-- 将卡号66947414「头目连战」登记到卡片c的代码列表中，用于识别涉及该卡名的效果。
	aux.AddCodeList(c,66947414)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，从卡组把1只「巨大战舰」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。自己的手卡·场上1只怪兽破坏，从卡组把1只攻击力1200而守备力1000以下的机械族·光属性怪兽在自己或对方的场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1张「头目连战」在自己场上表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"放置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 设置效果3的发动代价：将墓地中的这张卡除外（aux.bfgcost实现除外自身作为cost）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 定义检索过滤函数：满足「巨大战舰」系列、是怪兽、且可以加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0x15) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果1发动时判定与操作信息：若卡组存在符合条件的「巨大战舰」怪兽则允许发动，并设置将1张卡从卡组加入手牌的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查中，确认卡组中存在至少1只符合条件的「巨大战舰」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将进行1张卡从卡组加入手牌的操作（用于给其他卡检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1处理：玩家从卡组选择1只「巨大战舰」怪兽加入手牌，并让对方确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出从卡组选择要加入手牌的卡的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足thfilter条件的「巨大战舰」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因加入持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义可成为效果2破坏对象的怪兽过滤条件：是怪兽，且卡组中存在1只可特殊召唤的符合条件的机械族·光属性怪兽（以确保破坏后能特召）。
function s.dfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER)
		-- 额外要求：卡组中存在1只满足spfilter条件（攻击力1200/守备力1000以下、机械族·光属性、可特召）的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 定义效果2可特殊召唤的怪兽过滤条件：攻击力1200、守备力1000以下、机械族·光属性，且在自己或对方场上有空位的情况下可以特殊召唤。
function s.spfilter(c,e,tp,ec)
	return c:IsAttack(1200) and c:IsDefenseBelow(1000) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		-- 在假设破坏对象ec离场后，自己场上仍有可用怪兽区，可供特殊召唤。
		and (Duel.GetMZoneCount(tp,ec)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 在假设破坏对象ec离场后，对方场上仍有可用怪兽区，可供特殊召唤到对方场上。
		or Duel.GetMZoneCount(1-tp,ec)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- 效果2发动时判定与操作信息：取得可选破坏对象集合（手牌·场上满足dfilter的怪兽），确认存在后设置破坏1只怪兽和从卡组特殊召唤1只怪兽的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手牌·场上所有满足dfilter条件的怪兽集合，作为可选的破坏对象。
	local g=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e,tp)
	if chk==0 then return #g>0 end
	-- 设置操作信息：本效果将破坏1只怪兽，候选为集合g。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本效果将从卡组特殊召唤1只怪兽（具体怪兽在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果2处理：选择1只怪兽破坏（优先选择满足dfilter的，否则任意怪兽）；破坏成功后从卡组选择1只符合条件的怪兽特殊召唤到自己或对方场上（两方均可时由玩家选择）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 检测是否存在满足dfilter条件的怪兽，用于决定使用哪种过滤条件选择破坏对象。
	if Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) then
		-- 从满足dfilter条件的怪兽中选择1只作为破坏对象。
		g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	else
		-- 若没有满足dfilter条件的怪兽，则从手牌·场上的怪兽中选择1只作为破坏对象。
		g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,TYPE_MONSTER)
	end
	if g:GetCount()>0 then
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
			-- 若破坏对象位于怪兽区，则为其显示被选为对象的动画提示。
			Duel.HintSelection(g)
		end
		-- 若成功破坏选择的怪兽，且卡组中存在可特殊召唤的怪兽，则继续执行特殊召唤操作。
		if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,nil) then
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组选择1只满足spfilter条件的怪兽作为特殊召唤对象。
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,nil)
			if #sg>0 then
				local tc=sg:GetFirst()
				-- 判断该怪兽能否特殊召唤到自己场上：自己场上有可用怪兽区且该怪兽满足特殊召唤条件。
				local ssp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 判断该怪兽能否特殊召唤到对方场上：对方场上有可用怪兽区且该怪兽满足特殊召唤到对方场的条件。
				local osp=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
				-- 若可特召到对方场上，并且（不能特召到自己场上或玩家选择‘是’），则特召到对方场上。
				if osp and (not ssp or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then  --"是否在对方场上特殊召唤？"
					-- 将选中的怪兽以表侧表示特殊召唤到对方场上（由tp玩家进行特殊召唤）。
					Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
				elseif ssp then
					-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 定义效果3可放置的卡的条件：卡名为「头目连战」、不是禁止卡、且不违反场上的同名卡限制。
function s.tffilter(c,tp)
	return c:IsCode(66947414)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果3发动时判定：自己魔陷区有空位，且卡组·墓地存在符合条件的「头目连战」。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔法与陷阱区域是否有空位，作为发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组或墓地是否存在符合条件的「头目连战」。
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
-- 效果3处理：确认魔陷区有空位后，从卡组·墓地选择1张「头目连战」表侧表示放置到自己魔陷区。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时若魔陷区已无空位，则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组·墓地选择1张符合条件的「头目连战」（排除因王家长眠之谷而不能从墓地移动的卡）。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tffilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选中的「头目连战」以表侧表示放置到自己的魔法与陷阱区域，并立即适用其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
