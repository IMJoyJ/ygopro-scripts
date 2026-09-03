--聖王女ローズパメラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方回合，把手卡的这张卡给对方观看才能发动。从卡组把1张「圣王的粉碎」卡加入手卡。那之后，选自己1张手卡丢弃。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「列王」陷阱卡或「圣王的粉碎」陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ③：自己的魔法与陷阱区域的里侧表示卡不会被效果破坏。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方回合，把手卡的这张卡给对方观看才能发动。从卡组把1张「圣王的粉碎」卡加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「列王」陷阱卡或「圣王的粉碎」陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放效果"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：自己的魔法与陷阱区域的里侧表示卡不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE,0)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetTarget(s.indtg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件：对方回合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- ①效果的消耗：把手卡的这张卡给对方观看
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤卡组中可以加入手卡的「圣王的粉碎」卡
function s.thfilter(c)
	return c:IsSetCard(0x31c6) and c:IsAbleToHand()
end
-- ①效果的目标：设置加入手卡和丢弃手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可以加入手卡的「圣王的粉碎」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置丢弃1张自身手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- ①效果的处理：从卡组将「圣王的粉碎」卡加入手卡并丢弃1张手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「圣王的粉碎」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 提示选择要丢弃的手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 从手卡选择1张可丢弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_DISCARD+REASON_EFFECT)
		if dg:GetCount()>0 then
			-- 中断当前效果，连接后续处理
			Duel.BreakEffect()
			-- 洗切自身手卡
			Duel.ShuffleHand(tp)
			-- 将选中的手卡丢弃去墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 过滤可以盖放的「列王」或「圣王的粉碎」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1ea,0x31c6) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的目标：检查卡组或墓地是否存在可盖放的陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在满足条件的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- ②效果的处理：从卡组或墓地盖放陷阱卡并允许在盖放的回合发动
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组或墓地选择1张满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡在自身场上盖放成功
	if #g>0 and Duel.SSet(tp,g)>0 then
		local tc=g:GetFirst()
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"适用「圣王女 罗丝帕梅拉」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的目标：自身魔法与陷阱区域的里侧表示卡
function s.indtg(e,c)
	return c:IsFacedown() and c:GetSequence()<5
end
