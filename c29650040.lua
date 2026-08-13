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
-- 筛选额外卡组中表侧表示的「七音服」灵摆怪兽且能加入手卡的卡片。
function c29650040.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果发动时的目标判定：确认额外卡组存在符合条件的「七音服」灵摆怪兽，向对方提示所选效果，并设置“加入手卡”的操作信息。
function c29650040.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己的额外卡组中是否存在至少1张满足thfilter条件的表侧表示「七音服」灵摆怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29650040.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 向对方玩家提示自己发动的是“从额外卡组加入手卡”这个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置本连锁的效果信息：将1张卡从额外卡组加入手牌（具体卡在处理时选择），用于响应“加入手牌”相关效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从自己的额外卡组选择1只表侧表示「七音服」灵摆怪兽加入手牌，并让对方确认加入的卡。
function c29650040.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家选择要加入手牌的卡（显示选择框）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的额外卡组中选择1张满足thfilter条件的表侧表示「七音服」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c29650040.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选自己的灵摆区域中表侧表示的「七音服」卡（用于选择提升刻度的对象）。
function c29650040.scfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x162) and c:IsLevelAbove(0)
end
-- 效果发动时的目标判定：确认自己的灵摆区域存在表侧表示的「七音服」卡，并向对方提示所选效果。
function c29650040.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查自己的灵摆区域中是否存在至少1张满足scfilter条件的表侧表示「七音服」卡，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c29650040.scfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 向对方玩家提示自己发动的是“灵摆刻度上升”这个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果处理：选择自己灵摆区域的1张表侧表示「七音服」卡，令其左、右灵摆刻度上升该卡的等级数值，直到回合结束。
function c29650040.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家选择要提升灵摆刻度的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己的灵摆区域中选择1张表侧表示「七音服」卡作为效果对象。
	local g=Duel.SelectMatchingCard(tp,c29650040.scfilter,tp,LOCATION_PZONE,0,1,1,nil)
	local sc=g:GetFirst()
	if sc then
		-- 这个回合，那个灵摆刻度上升那张卡的等级数值。
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
-- 筛选自己场上表侧表示、原本类型为灵摆的「七音服」怪兽，并且其当前灵摆刻度的奇偶性等于指定值（odevity为1表示奇数，0为偶数）。
function c29650040.desfilter(c,odevity)
	return c:IsSetCard(0x162) and c:GetOriginalType()&TYPE_PENDULUM>0 and c:IsFaceup() and c:GetCurrentScale()%2==odevity
end
-- 效果发动条件：自己场上存在当前灵摆刻度为奇数的「七音服」灵摆怪兽3种类以上，或为偶数的「七音服」灵摆怪兽3种类以上。
function c29650040.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前灵摆刻度为奇数的表侧表示「七音服」灵摆怪兽群。
	local g1=Duel.GetMatchingGroup(c29650040.desfilter,tp,LOCATION_ONFIELD,0,nil,1)
	-- 获取自己场上当前灵摆刻度为偶数的表侧表示「七音服」灵摆怪兽群。
	local g2=Duel.GetMatchingGroup(c29650040.desfilter,tp,LOCATION_ONFIELD,0,nil,0)
	return g1:GetClassCount(Card.GetCurrentScale)>=3 or g2:GetClassCount(Card.GetCurrentScale)>=3
end
-- 效果发动时的目标判定：确认对方场上存在可破坏的卡，向对方提示所选效果，并设置“破坏对方场上1张卡”的操作信息。
function c29650040.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查对方场上是否存在至少1张卡，若没有则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向对方玩家提示自己发动的是“破坏对方场上1张卡”这个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取对方场上的全部卡，作为效果处理时可能破坏的对象集合。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：本次为破坏效果，可能破坏的对象为对方场上的全部卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：从对方场上选择1张卡破坏，并在破坏前显示选中动画。
function c29650040.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的全部卡。
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 提示当前玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g:Select(tp,1,1,nil)
		-- 显示被选择为破坏对象的卡的选中动画，并记录该卡被选为对象。
		Duel.HintSelection(dg)
		-- 以效果原因破坏所选择的卡。
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
