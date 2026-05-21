--Mischief of the Wolves
-- 效果：
-- 依序适用以下效果。
-- ●对方场上的怪兽的等级下降2。
-- ●自己场上的怪兽的等级上升2。
-- 这张卡被送去墓地的自己回合的主要阶段：可以以自己场上1张表侧表示卡为对象；那张卡破坏，这张卡加入手卡。「饿狼的恶作剧」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动效果、送墓时注册标记的效果、以及墓地回收效果。
function s.initial_effect(c)
	-- 依序适用以下效果。●对方场上的怪兽的等级下降2。●自己场上的怪兽的等级上升2。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡被送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- 的自己回合的主要阶段：可以以自己场上1张表侧表示卡为对象；那张卡破坏，这张卡加入手卡。「饿狼的恶作剧」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 卡片发动时的效果目标检查函数，确认双方场上是否存在可以改变等级的怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在等级在3以上（可下降2级）的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 或者自己场上是否存在等级在1以上（可上升2级）的表侧表示怪兽。
		or Duel.IsExistingMatchingCard(s.lvfilter2,tp,LOCATION_MZONE,0,1,nil) end
end
-- 过滤条件：对方场上表侧表示且等级在3以上的怪兽。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(3)
end
-- 过滤条件：自己场上表侧表示且等级在1以上的怪兽。
function s.lvfilter2(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 卡片发动时的效果处理函数，依序降低对方怪兽等级并提高自己怪兽等级。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有满足等级下降条件的表侧表示怪兽。
	local og=Duel.GetMatchingGroup(s.lvfilter,tp,0,LOCATION_MZONE,nil)
	-- 遍历这些对方怪兽。
	for tc in aux.Next(og) do
		-- 对方场上的怪兽的等级下降2。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 如果成功降低了对方怪兽的等级，则中断效果处理，使后续的等级上升处理视为不同时处理。
	if og:GetCount()>0 then Duel.BreakEffect() end
	-- 获取自己场上所有满足等级上升条件的表侧表示怪兽。
	local sg=Duel.GetMatchingGroup(s.lvfilter2,tp,LOCATION_MZONE,0,nil)
	-- 遍历这些自己怪兽。
	for tc in aux.Next(sg) do
		-- 自己场上的怪兽的等级上升2。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetValue(2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 送墓时的效果处理，给自身注册一个持续到回合结束的标记，用于记录“本回合被送去墓地”的状态。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 墓地回收效果的发动条件：自身带有本回合送墓的标记，且当前为自己回合的主要阶段。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 过滤条件：场上表侧表示的卡。
function s.tfilter(c)
	return c:IsFaceup()
end
-- 墓地回收效果的目标选择与检查函数。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return s.tfilter(chkc) and chkc:IsOnField() and chkc:IsControler(tp) end
	if chk==0 then return c:IsAbleToHand()
		-- 并且自己场上存在可以作为对象的表侧表示卡片。
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁信息：包含破坏选定卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息：包含将墓地的这张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 墓地回收效果的执行函数，处理破坏卡片并回收自身。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选作对象的卡。
	local tc=Duel.GetFirstTarget()
	-- 如果对象卡仍与连锁相关，则将其因效果破坏，且必须成功破坏。
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 并且墓地的这张卡仍与连锁相关，且不受王家长眠之谷影响。
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡加入手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
