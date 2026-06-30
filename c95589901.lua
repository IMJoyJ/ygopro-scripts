--Mischief of the Wolves
-- 效果：
-- 依序适用以下效果。
-- ●对方场上的怪兽的等级下降2。
-- ●自己场上的怪兽的等级上升2。
-- 这张卡被送去墓地的自己回合的主要阶段：可以以自己场上1张表侧表示卡为对象；那张卡破坏，这张卡加入手卡。「饿狼的恶作剧」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化效果注册，包含卡片发动效果、被送去墓地时注册标识效果以及墓地回收效果的注册
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
	-- 自己回合的主要阶段：可以以自己场上1张表侧表示卡为对象；那张卡破坏，这张卡加入手卡。
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
-- 卡片发动效果的发动准备与检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查对方场上是否存在等级在2以上且表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 或者检查自己场上是否存在等级在1以上且表侧表示的怪兽
		or Duel.IsExistingMatchingCard(s.lvfilter2,tp,LOCATION_MZONE,0,1,nil) end
end
-- 过滤条件：表侧表示且等级在2以上的怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end
-- 过滤条件：表侧表示且等级在1以上的怪兽
function s.lvfilter2(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 卡片发动时的效果处理：先让对方场上的怪兽等级下降2，然后让自己场上的怪兽等级上升2
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示且等级在2以上的怪兽
	local og=Duel.GetMatchingGroup(s.lvfilter,tp,0,LOCATION_MZONE,nil)
	-- 循环遍历这组对方怪兽
	for tc in aux.Next(og) do
		-- 对方场上的怪兽的等级下降2。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 若有对方怪兽等级下降，则中断效果，使后续的等级上升效果视为不同时处理
	if og:GetCount()>0 then Duel.BreakEffect() end
	-- 获取自己场上所有表侧表示且等级在1以上的怪兽
	local sg=Duel.GetMatchingGroup(s.lvfilter2,tp,LOCATION_MZONE,0,nil)
	-- 循环遍历这组自己怪兽
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
-- 被送去墓地时的处理：为这张卡注册一个重置时间为回合结束的 Flag 标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 墓地回收效果的发动条件：处于送去墓地的自己回合的主要阶段
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 过滤条件：表侧表示的卡
function s.tfilter(c)
	return c:IsFaceup()
end
-- 墓地回收效果的发动准备与目标选择
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return s.tfilter(chkc) and chkc:IsOnField() and chkc:IsControler(tp) end
	if chk==0 then return c:IsAbleToHand()
		-- 并检查自己场上是否存在至少1张可以成为效果对象的表侧表示卡
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家在自己场上选择1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果处理的分类为破坏，目标为所选的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理的分类为加入手牌，目标为墓地的自身
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 墓地回收效果的处理逻辑
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	-- 如果该卡与连锁关联且成功将其破坏
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 检查自身是否与连锁关联，且未受王家长眠之谷的影响
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身送回玩家手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
