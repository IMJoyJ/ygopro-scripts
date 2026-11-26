--魔導書の神判
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。那之后，可以把持有这个效果加入手卡的卡数量以下的等级的1只魔法师族怪兽从卡组特殊召唤。
function c46448938.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。那之后，可以把持有这个效果加入手卡的卡数量以下的等级的1只魔法师族怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,46448938+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c46448938.target)
	e1:SetOperation(c46448938.activate)
	c:RegisterEffect(e1)
end
-- 发动校验函数：此卡发动本身无需预先指定对象或卡组存在目标，直接返回true
function c46448938.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果处理：注册三个持续至回合结束的后台效果——监听魔法卡发动以递增计数、监听魔法卡发动被无效以递减计数，并在结束阶段执行检索与特殊召唤结算
function c46448938.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的发动后自己或者对方发动的魔法卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c46448938.regcon)
	e1:SetOperation(c46448938.regop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册监听双方魔法卡发动并增加计数器的时点连续效果
	Duel.RegisterEffect(e1,tp)
	-- 这张卡的发动后自己或者对方发动的魔法卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetCondition(c46448938.regcon)
	e2:SetOperation(c46448938.regop2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册监听魔法卡发动被无效时扣减计数器的时点连续效果
	Duel.RegisterEffect(e2,tp)
	-- ①：这张卡发动的回合的结束阶段，把最多有这张卡的发动后自己或者对方发动的魔法卡数量的「魔导书的神判」以外的「魔导书」魔法卡从卡组加入手卡。那之后，可以把持有这个效果加入手卡的卡数量以下的等级的1只魔法师族怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c46448938.effcon)
	e3:SetOperation(c46448938.effop)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在当前回合结束阶段触发检索与特殊召唤的连续效果
	Duel.RegisterEffect(e3,tp)
	e1:SetLabelObject(e3)
	e2:SetLabelObject(e3)
end
-- 计数触发条件：判断该连锁是否为魔法卡的卡片发动
function c46448938.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL)
end
-- 递增计数：读取关联的结束阶段效果e3的Label数值并加1
function c46448938.regop1(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(ct+1)
end
-- 扣减计数：当魔法卡的发动被无效时，将关联的结束阶段效果e3的Label数值减1（下限保护为0）
function c46448938.regop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	if ct==0 then ct=1 end
	e:GetLabelObject():SetLabel(ct-1)
end
-- 结束阶段发动条件：确认此卡发动后成功统计到的魔法卡发动次数（Label）大于0
function c46448938.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
-- 过滤卡组中除「魔导书的神判」外、可加入手卡的「魔导书」魔法卡
function c46448938.sfilter(c)
	return c:IsSetCard(0x106e) and not c:IsCode(46448938) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 过滤卡组中等级在指定数值lv以下、可特殊召唤的魔法师族怪兽
function c46448938.spfilter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 结束阶段结算处理：提示卡片效果，从卡组选最多等于累计魔法发动数张数的其他「魔导书」魔法卡加入手卡，之后可从卡组特召1只等级不高于加入手卡张数的魔法师族怪兽
function c46448938.effop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方显示「魔导书的神判」效果适用的卡片提示动画
	Duel.Hint(HINT_CARD,0,46448938)
	-- 向己方发送从卡组选择要加入手卡的「魔导书」魔法卡的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方从卡组选择1至累计魔法发动次数（e:GetLabel()）张符合条件的「魔导书」魔法卡
	local g=Duel.SelectMatchingCard(tp,c46448938.sfilter,tp,LOCATION_DECK,0,1,e:GetLabel(),nil)
	if g:GetCount()>0 then
		-- 将选中的「魔导书」魔法卡以效果加入己方手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的「魔导书」魔法卡进行确认
		Duel.ConfirmCards(1-tp,g)
		-- 检查己方怪兽区是否至少有1个可用空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查己方卡组是否存在等级不高于本次加入手卡数量的可特召魔法师族怪兽
			and Duel.IsExistingMatchingCard(c46448938.spfilter,tp,LOCATION_DECK,0,1,nil,g:GetCount(),e,tp)
			-- 询问己方玩家是否从卡组特殊召唤1只魔法师族怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(46448938,1)) then  --"是否要把1只魔法师族怪兽从卡组特殊召唤？"
			-- 插入效果处理间断，使检索加入手卡与后续特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 向己方发送从卡组选择要特殊召唤的魔法师族怪兽的提示
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让己方从卡组选择1只等级不高于加入手卡张数的魔法师族怪兽
			local sg=Duel.SelectMatchingCard(tp,c46448938.spfilter,tp,LOCATION_DECK,0,1,1,nil,g:GetCount(),e,tp)
			-- 将选中的魔法师族怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
