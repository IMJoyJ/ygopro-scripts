--魔導書の神判
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。那之后，可以把持有这个效果加入手卡的卡数量以下的等级的1只魔法师族怪兽从卡组特殊召唤。
function c46448938.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,46448938+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c46448938.target)
	e1:SetOperation(c46448938.activate)
	c:RegisterEffect(e1)
end
-- 效果作用
function c46448938.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果作用
function c46448938.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c46448938.regcon)
	e1:SetOperation(c46448938.regop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册连锁时点效果，用于记录发动的魔法卡数量
	Duel.RegisterEffect(e1,tp)
	-- ①：这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。那之后，可以把持有这个效果加入手卡的卡数量以下的等级的1只魔法师族怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetCondition(c46448938.regcon)
	e2:SetOperation(c46448938.regop2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册连锁无效时点效果，用于减少发动的魔法卡数量
	Duel.RegisterEffect(e2,tp)
	-- ①：这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。那之后，可以把持有这个效果加入手卡的卡数量以下的等级的1只魔法师族怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c46448938.effcon)
	e3:SetOperation(c46448938.effop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册结束阶段时点效果，用于执行最终效果处理
	Duel.RegisterEffect(e3,tp)
	e1:SetLabelObject(e3)
	e2:SetLabelObject(e3)
end
-- 判断是否为魔法卡发动
function c46448938.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 记录发动的魔法卡数量加一
function c46448938.regop1(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(ct+1)
end
-- 记录发动的魔法卡数量减一（若为0则设为1）
function c46448938.regop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	if ct==0 then ct=1 end
	e:GetLabelObject():SetLabel(ct-1)
end
-- 判断是否有发动的魔法卡数量
function c46448938.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
-- 过滤满足条件的「魔导书」魔法卡
function c46448938.sfilter(c)
	return c:IsSetCard(0x106e) and not c:IsCode(46448938) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 过滤满足条件的魔法师族怪兽
function c46448938.spfilter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行效果处理：检索并加入手牌，询问是否特殊召唤
function c46448938.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了「魔导书的神判」
	Duel.Hint(HINT_CARD,0,46448938)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的魔法卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c46448938.sfilter,tp,LOCATION_DECK,0,1,e:GetLabel(),nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 判断场上是否有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查是否有满足等级要求的魔法师族怪兽
			and Duel.IsExistingMatchingCard(c46448938.spfilter,tp,LOCATION_DECK,0,1,nil,g:GetCount(),e,tp)
			-- 询问是否特殊召唤魔法师族怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(46448938,1)) then  --"是否要把1只魔法师族怪兽从卡组特殊召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择满足条件的魔法师族怪兽进行特殊召唤
			local sg=Duel.SelectMatchingCard(tp,c46448938.spfilter,tp,LOCATION_DECK,0,1,1,nil,g:GetCount(),e,tp)
			-- 将选中的魔法师族怪兽特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
