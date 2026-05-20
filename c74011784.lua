--アルトメギア・バーニッシュ－改変－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的卡组·墓地把1张「神艺学都 神艺学园」在自己的场地区域表侧表示放置。自己场上有「神艺学都 神艺学园」存在的场合，作为代替从卡组把「神艺学的消失-改变-」以外的1张「神艺」卡加入手卡。
-- ②：自己的「神艺」怪兽被选择作为攻击对象时，把墓地的这张卡除外才能发动。那次攻击无效。那之后，可以从手卡把1只「无垢者 米底乌斯」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（发动）和②效果（墓地诱发）。
function s.initial_effect(c)
	-- 记录卡片效果中提及的「无垢者 米底乌斯」和「神艺学都 神艺学园」的卡片密码。
	aux.AddCodeList(c,97556336,74733322)
	-- ①：从自己的卡组·墓地把1张「神艺学都 神艺学园」在自己的场地区域表侧表示放置。自己场上有「神艺学都 神艺学园」存在的场合，作为代替从卡组把「神艺学的消失-改变-」以外的1张「神艺」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「神艺」怪兽被选择作为攻击对象时，把墓地的这张卡除外才能发动。那次攻击无效。那之后，可以从手卡把1只「无垢者 米底乌斯」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击无效"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	-- 把墓地的这张卡除外作为发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡名为「神艺学都 神艺学园」，且在场上唯一存在、未被禁止放置。
function s.stfilter(c,tp)
	return c:IsCode(74733322) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤条件：卡组中除「神艺学的消失-改变-」以外的「神艺」卡，且能加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1cd) and c:IsAbleToHand()
end
-- ①效果的发动准备与合法性检测：根据场上是否存在表侧表示的「神艺学都 神艺学园」，分别检测卡组·墓地是否有可放置的卡，或卡组是否有可检索的卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在表侧表示的「神艺学都 神艺学园」。
		if not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,74733322) then
			-- 检查自己的卡组或墓地是否存在可以放置的「神艺学都 神艺学园」。
			return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
		else
			-- 检查自己的卡组是否存在可以加入手卡的「神艺」卡。
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		end
	end
end
-- ①效果的处理：若场上没有「神艺学都 神艺学园」，则从卡组·墓地选择一张放置到场地区域（若已有场地则送墓替换）；若已有，则从卡组检索一张「神艺」卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，检查自己场上是否存在表侧表示的「神艺学都 神艺学园」。
	if not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,74733322) then
		-- 提示玩家选择要放置到场上的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组或墓地选择一张「神艺学都 神艺学园」（适用墓地相关效果无效化判定）。
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if tc then
			-- 获取自己场地区域（魔法与陷阱区域第5格）已存在的卡。
			local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc then
				-- 因规则将原本存在的场地魔法卡送去墓地。
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断效果，使后续的放置处理与送墓不视为同时进行。
				Duel.BreakEffect()
			end
			-- 将选择的「神艺学都 神艺学园」在自己的场地区域表侧表示放置。
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	else
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择一张「神艺学的消失-改变-」以外的「神艺」卡。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的发动条件：自己的「神艺」怪兽被选择作为攻击对象。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsFaceup() and tc:IsSetCard(0x1cd)
		and tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE)
end
-- 过滤条件：手卡中的「无垢者 米底乌斯」，且能被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCode(97556336) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的处理：无效那次攻击，之后可以从手卡把1只「无垢者 米底乌斯」特殊召唤。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效那次攻击，若成功则进行后续处理。
	if Duel.NegateAttack() then
		-- 获取手卡中满足特殊召唤条件的「无垢者 米底乌斯」。
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 检查手卡中是否存在可召唤的怪兽、怪兽区域是否有空位，并询问玩家是否进行特殊召唤。
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断效果，使后续的特殊召唤处理与攻击无效不视为同时进行。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的怪兽表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
