--落とし大穴
-- 效果：
-- 对方以表侧表示对2只以上的怪兽的特殊召唤成功时才能发动。那些怪兽全部送去墓地。并且再把和那些怪兽同名怪兽从对方的手卡·卡组送去墓地。
function c30127518.initial_effect(c)
	-- 效果原文：对方以表侧表示对2只以上的怪兽的特殊召唤成功时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c30127518.target)
	e1:SetOperation(c30127518.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的怪兽（表侧表示、对方特殊召唤、与效果相关）
function c30127518.cfilter(c,sp,e)
	return c:IsFaceup() and c:IsSummonPlayer(sp) and (not e or c:IsRelateToEffect(e))
end
-- 效果作用：判断是否满足发动条件，设置连锁对象为符合条件的怪兽组，设置操作信息为送去墓地
function c30127518.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c30127518.cfilter,2,nil,1-tp) end
	local g=eg:Filter(c30127518.cfilter,nil,1-tp)
	-- 效果作用：将目标怪兽设置为当前连锁的对象
	Duel.SetTargetCard(g)
	-- 效果作用：设置操作信息为将目标怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果原文：那些怪兽全部送去墓地。并且再把和那些怪兽同名怪兽从对方的手卡·卡组送去墓地。
function c30127518.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁对象中符合条件的怪兽（表侧表示、对方特殊召唤、与效果相关）
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c30127518.cfilter,nil,1-tp,e)
	-- 效果作用：将目标怪兽全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
	local exg=Group.CreateGroup()
	-- 效果作用：获取上一步实际操作的卡片组
	local g1=Duel.GetOperatedGroup()
	local tc=g1:GetFirst()
	while tc do
		if tc:IsLocation(LOCATION_GRAVE) then
			-- 效果作用：检索对方手卡和卡组中与目标怪兽同名的卡片
			local fg=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_DECK+LOCATION_HAND,nil,tc:GetCode())
			exg:Merge(fg)
		end
		tc=g1:GetNext()
	end
	-- 效果作用：中断当前效果处理，使后续效果视为不同时处理
	Duel.BreakEffect()
	-- 效果作用：将检索到的同名怪兽送去墓地
	Duel.SendtoGrave(exg,REASON_EFFECT)
end
