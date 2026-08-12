--ドレミコード・ハルモニア
-- 效果：
-- ①：可以从以下效果选择1个发动。「七音服的调和」的以下效果1回合各能选择1次。
-- ●从自己的额外卡组把1只表侧表示的「七音服」灵摆怪兽加入手卡。
-- ●选自己的灵摆区域1张「七音服」卡。这个回合，那个灵摆刻度上升那张卡的等级数值。
-- ●自己场上的「七音服」灵摆怪兽卡的灵摆刻度是奇数3种类以上或者偶数3种类以上的场合，选对方场上1张卡破坏。
function c29650040.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 从自己的额外卡组把1只表侧表示的「七音服」灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29650040,0))  --"额外卡组加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,29650040)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(c29650040.thtg)
	e2:SetOperation(c29650040.thop)
	c:RegisterEffect(e2)
	-- 选自己的灵摆区域1张「七音服」卡。这个回合，那个灵摆刻度上升那张卡的等级数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29650040,1))  --"灵摆刻度上升"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,29650041)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(c29650040.sctg)
	e3:SetOperation(c29650040.scop)
	c:RegisterEffect(e3)
	-- 自己场上的「七音服」灵摆怪兽卡的灵摆刻度是奇数3种类以上或者偶数3种类以上的场合，选对方场上1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29650040,2))  --"对方场上1张卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,29650042)
	e4:SetCondition(c29650040.descon)
	e4:SetTarget(c29650040.destg)
	e4:SetOperation(c29650040.desop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选满足条件的额外卡组中的灵摆怪兽
function c29650040.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果处理时的判断函数，检查是否满足发动条件
function c29650040.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的额外卡组中是否存在至少1张满足thfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c29650040.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要将1张卡从额外卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，选择并执行将灵摆怪兽加入手牌的操作
function c29650040.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c29650040.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于筛选满足条件的灵摆区域中的卡
function c29650040.scfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x162) and c:IsLevelAbove(0)
end
-- 效果处理时的判断函数，检查是否满足发动条件
function c29650040.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的灵摆区域中是否存在至少1张满足scfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c29650040.scfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理函数，选择并执行提升灵摆刻度的操作
function c29650040.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要提升刻度的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从灵摆区域中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c29650040.scfilter,tp,LOCATION_PZONE,0,1,1,nil)
	local sc=g:GetFirst()
	if sc then
		-- 创建一个改变左刻度的效果并注册到选中的卡上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LSCALE)
		e1:SetValue(sc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_RSCALE)
		sc:RegisterEffect(e2)
	end
end
-- 过滤函数，用于筛选满足条件的场上的灵摆怪兽
function c29650040.desfilter(c,odevity)
	return c:IsSetCard(0x162) and c:GetOriginalType()&TYPE_PENDULUM>0 and c:IsFaceup() and c:GetCurrentScale()%2==odevity
end
-- 效果发动条件判断函数，检查场上的灵摆怪兽是否满足奇数或偶数种类数量要求
function c29650040.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的所有奇数刻度灵摆怪兽
	local g1=Duel.GetMatchingGroup(c29650040.desfilter,tp,LOCATION_ONFIELD,0,nil,1)
	-- 获取场上的所有偶数刻度灵摆怪兽
	local g2=Duel.GetMatchingGroup(c29650040.desfilter,tp,LOCATION_ONFIELD,0,nil,0)
	return g1:GetClassCount(Card.GetCurrentScale)>=3 or g2:GetClassCount(Card.GetCurrentScale)>=3
end
-- 效果处理时的判断函数，检查是否满足发动条件
function c29650040.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息，表示将要破坏对方场上的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，选择并执行破坏对方场上卡的操作
function c29650040.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g:Select(tp,1,1,nil)
		-- 显示被选为对象的卡
		Duel.HintSelection(dg)
		-- 以效果原因破坏选中的卡
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
