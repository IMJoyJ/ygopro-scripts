--アームド・ドラゴン LV10－ホワイト
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：等级合计直到10为止从自己的场上·墓地把「武装龙」怪兽除外才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「白之衣」加入手卡。
-- ②：这张卡的控制者受到的效果伤害变成0。
-- ③：这张卡攻击的伤害步骤开始时才能发动。选场上1张卡破坏。
function c84425220.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 这个卡名的①的效果1回合只能使用1次。①：等级合计直到10为止从自己的场上·墓地把「武装龙」怪兽除外才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「白之衣」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84425220,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,84425220)
	e1:SetCost(c84425220.spcost)
	e1:SetTarget(c84425220.sptg)
	e1:SetOperation(c84425220.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的控制者受到的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(c84425220.damval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e3)
	-- ③：这张卡攻击的伤害步骤开始时才能发动。选场上1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(84425220,1))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCondition(c84425220.descon)
	e4:SetTarget(c84425220.destg)
	e4:SetOperation(c84425220.desop)
	c:RegisterEffect(e4)
end
-- 过滤场上或墓地中等级大于等于1、可以作为cost除外的「武装龙」怪兽（场上的怪兽必须表侧表示）
function c84425220.rfilter(c)
	return c:IsLevelAbove(1) and c:IsSetCard(0x111) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsAbleToRemoveAsCost()
end
-- 检查选取的卡片组等级合计是否等于10，且玩家场上有足够的怪兽区域空位来容纳特殊召唤的怪兽
function c84425220.fselect(g,tp)
	-- 返回选取的卡片组等级合计是否等于10，且玩家场上有足够的怪兽区域空位
	return g:GetSum(Card.GetLevel)==10 and aux.mzctcheck(g,tp)
end
-- 限制选取的卡片组等级合计不超过10，用于辅助CheckSubGroup进行剪枝
function c84425220.gcheck(g)
	return g:GetSum(Card.GetLevel)<=10
end
-- ①号效果的发动代价：从自己的场上·墓地把等级合计直到10为止的「武装龙」怪兽除外
function c84425220.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上和墓地中满足除外条件的「武装龙」怪兽组
	local g=Duel.GetMatchingGroup(c84425220.rfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 设置子组选择的额外检查函数，限制等级合计不超过10以优化选择逻辑
	aux.GCheckAdditional=c84425220.gcheck
	if chk==0 then
		local res=g:CheckSubGroup(c84425220.fselect,1,g:GetCount(),tp)
		-- 清空额外检查函数，避免影响后续的选择逻辑
		aux.GCheckAdditional=nil
		return res
	end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:SelectSubGroup(tp,c84425220.fselect,false,1,g:GetCount(),tp)
	-- 清空额外检查函数，避免影响后续的选择逻辑
	aux.GCheckAdditional=nil
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- ①号效果的靶向处理：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c84425220.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置特殊召唤的操作信息，包含1张自身卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤卡组中名为「白之衣」且能加入手牌的卡片
function c84425220.thfilter(c)
	return c:IsCode(49306994) and c:IsAbleToHand()
end
-- ①号效果的效果处理：特殊召唤自身，之后可以从卡组把1张「白之衣」加入手卡
function c84425220.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其无视召唤条件表侧表示特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
		-- 检查卡组中是否存在「白之衣」，并询问玩家是否将其加入手卡
		if Duel.IsExistingMatchingCard(c84425220.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(84425220,2)) then  --"是否从卡组把「白之衣」加入手卡？"
			-- 中断当前效果，使后续的检索处理与特殊召唤不视为同时处理（造成错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从卡组中选择1张「白之衣」
			local g=Duel.SelectMatchingCard(tp,c84425220.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选中的卡片加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②号效果的伤害计算：如果是效果伤害则将其变为0，否则保持原伤害数值
function c84425220.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0 end
	return val
end
-- ③号效果的发动条件：此卡是攻击怪兽（攻击的伤害步骤开始时）
function c84425220.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前进行攻击的怪兽是否为自身
	return Duel.GetAttacker()==e:GetHandler()
end
-- ③号效果的靶向处理：检查场上是否存在卡片，并设置破坏的操作信息
function c84425220.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上的所有卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏的操作信息，包含场上的1张卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③号效果的效果处理：选择场上1张卡破坏
function c84425220.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上的1张卡片
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 显式地在场上框选并提示被选中的卡片
		Duel.HintSelection(g)
		-- 破坏选中的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
