--魔導書の神判
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。那之后，可以把持有这个效果加入手卡的卡数量以下的等级的1只魔法师族怪兽从卡组特殊召唤。
function c46448938.initial_effect(c)
	-- ①：这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。那之后，可以把持有这个效果加入手卡的卡数量以下的等级的1只魔法师族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,46448938+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c46448938.target)
	e1:SetOperation(c46448938.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标确认（直接返回true，无对象效果）
function c46448938.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 注册用于在结束阶段处理效果以及记录魔法卡发动次数的延迟触发效果
function c46448938.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c46448938.regcon)
	e1:SetOperation(c46448938.regop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册用于监听魔法卡发动并增加计数器的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetCondition(c46448938.regcon)
	e2:SetOperation(c46448938.regop2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册用于监听魔法卡发动被无效时减少计数器的全局效果
	Duel.RegisterEffect(e2,tp)
	-- ①：这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。那之后，可以把持有这个效果加入手卡的卡数量以下的等级的1只魔法师族怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c46448938.effcon)
	e3:SetOperation(c46448938.effop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在结束阶段触发的检索并特殊召唤的全局效果
	Duel.RegisterEffect(e3,tp)
	e1:SetLabelObject(e3)
	e2:SetLabelObject(e3)
end
-- 检查发动的卡是否为魔法卡的发动
function c46448938.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 魔法卡发动成功时，将结束阶段效果的计数器加1
function c46448938.regop1(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(ct+1)
end
-- 魔法卡的发动被无效时，将结束阶段效果的计数器减1
function c46448938.regop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	if ct==0 then ct=1 end
	e:GetLabelObject():SetLabel(ct-1)
end
-- 检查本回合是否有魔法卡发动成功（计数器大于0）
function c46448938.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
-- 过滤卡组中「魔导书的神判」以外的「魔导书」魔法卡
function c46448938.sfilter(c)
	return c:IsSetCard(0x106e) and not c:IsCode(46448938) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 过滤卡组中等级在指定数值以下、可以特殊召唤的魔法师族怪兽
function c46448938.spfilter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 结束阶段效果的实际处理：检索「魔导书」魔法卡，并可选特殊召唤魔法师族怪兽
function c46448938.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 在结束阶段展示「魔导书的神判」的卡片发动提示
	Duel.Hint(HINT_CARD,0,46448938)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择最多等同于已发动魔法卡数量的「魔导书」魔法卡
	local g=Duel.SelectMatchingCard(tp,c46448938.sfilter,tp,LOCATION_DECK,0,1,e:GetLabel(),nil)
	if g:GetCount()>0 then
		-- 将选择的「魔导书」魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 检查自己场上是否有空余的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查卡组中是否存在等级在加入手牌数量以下的魔法师族怪兽
			and Duel.IsExistingMatchingCard(c46448938.spfilter,tp,LOCATION_DECK,0,1,nil,g:GetCount(),e,tp)
			-- 询问玩家是否进行特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(46448938,1)) then  --"是否要把1只魔法师族怪兽从卡组特殊召唤？"
			-- 中断当前效果，使后续的特殊召唤处理与加入手牌不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组选择1只满足等级条件的魔法师族怪兽
			local sg=Duel.SelectMatchingCard(tp,c46448938.spfilter,tp,LOCATION_DECK,0,1,1,nil,g:GetCount(),e,tp)
			-- 将选择的魔法师族怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
