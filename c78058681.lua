--キラーチューン・シンクロ
-- 效果：
-- 这个卡名的卡在1回合可以发动最多2张。
-- ①：从卡组把「杀手级调整曲同调」以外的1张「杀手级调整曲」卡加入手卡。那之后，可以进行1只同调怪兽调整的同调召唤。这张卡的发动后，直到回合结束时自己不是调整不能特殊召唤。
local s,id,o=GetID()
-- 定义卡片效果的初始化函数，注册魔法卡的发动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合可以发动最多2张。①：从卡组把「杀手级调整曲同调」以外的1张「杀手级调整曲」卡加入手卡。那之后，可以进行1只同调怪兽调整的同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(2,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DRAW_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中「杀手级调整曲同调」以外的「杀手级调整曲」卡片的条件
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1d5) and c:IsAbleToHand()
end
-- 效果发动的目标选择与检测函数，确认卡组中是否存在可检索的卡，并设置检索的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「杀手级调整曲」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果包含从卡组将1张卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤额外卡组中可以进行同调召唤的调整怪兽的条件
function s.spfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsSynchroSummonable(nil)
end
-- 效果处理的执行函数，处理检索「杀手级调整曲」卡片以及后续的同调召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「杀手级调整曲」卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 刷新场上卡片的状态信息，确保后续同调召唤的合法性检测正确
		Duel.AdjustAll()
		-- 检查额外卡组是否存在可以进行同调召唤的调整怪兽
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil)
			-- 询问玩家是否选择进行同调召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否同调召唤？"
			-- 中断当前效果处理，使后续的同调召唤与加入手牌不视为同时处理
			Duel.BreakEffect()
			-- 获取额外卡组中所有可以进行同调召唤的调整怪兽
			local exg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil)
			if exg:GetCount()>0 then
				-- 提示玩家选择要特殊召唤（同调召唤）的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg=exg:Select(tp,1,1,nil)
				-- 对选择的怪兽进行同调召唤
				Duel.SynchroSummon(tp,sg:GetFirst(),nil)
			end
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是调整不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该玩家的全局效果限制，使其在回合结束前受到特殊召唤限制
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制不能特殊召唤原本非调整的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetOriginalType()&TYPE_TUNER==0
end
