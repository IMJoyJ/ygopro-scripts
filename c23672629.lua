--ヴァリアント・シャーク・ランサー
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只怪兽为对象才能发动。自己场上1个超量素材取除，作为对象的怪兽破坏。自己场上有其他的水属性超量怪兽存在的场合，这个效果在对方回合也能发动。
-- ②：这张卡已在怪兽区域存在的状态，自己场上的其他的水属性超量怪兽被战斗·效果破坏的场合才能发动。从卡组选1张魔法卡在卡组最上面放置。
function c23672629.initial_effect(c)
	-- 为卡片注册超量召唤的素材要求规程
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：以对方场上1只怪兽为对象才能发动。自己场上1个超量素材去除，作为对象的怪兽破坏。自己场上有其他的水属性超量怪兽存在的场合，这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23672629,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,23672629)
	e1:SetCondition(c23672629.descon1)
	e1:SetTarget(c23672629.destg)
	e1:SetOperation(c23672629.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c23672629.descon2)
	c:RegisterEffect(e2)
	-- ②：这张卡已在怪兽区域存在的状态，自己场上的其他的水属性超量怪兽被战斗·效果破坏的场合才能发动。从卡组选1张魔法卡在卡组最上面放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23672629,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,23672630)
	e3:SetCondition(c23672629.tpcon)
	e3:SetTarget(c23672629.tptg)
	e3:SetOperation(c23672629.tpop)
	c:RegisterEffect(e3)
end
-- 自己场上不存在其他水属性超量怪兽时，只能在自己回合发动
function c23672629.descon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上除了此卡外是否没有其他的水属性超量怪兽
	return not Duel.IsExistingMatchingCard(c23672629.desfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 自己场上存在其他水属性超量怪兽时，可以在对方回合发动（诱发即时）
function c23672629.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上除了此卡外是否存在至少1只其他的水属性超量怪兽
	return Duel.IsExistingMatchingCard(c23672629.desfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 水属性超量怪兽 of target filters
function c23672629.desfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
end
-- 破坏效果的发动准备与对象选择
function c23672629.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在可去除的超量素材
		and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
	-- 向玩家发送提示，请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行
function c23672629.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择破坏的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若成功去除自己场上1个超量素材且目标怪兽依然与连锁关联
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
		-- 破坏选中的对方怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 被战斗或效果破坏的水属性超量怪兽的原本场上状态过滤条件
function c23672629.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WATER)~=0 and bit.band(c:GetPreviousTypeOnField(),TYPE_XYZ)~=0
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 水属性超量怪兽被破坏效果的发动条件判断
function c23672629.tpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23672629.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 魔法卡放置效果的发动准备
function c23672629.tptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_SPELL) end
end
-- 魔法卡放置效果的执行
function c23672629.tpop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，请选择要在卡组最上面放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23672629,2))  --"请选择要在卡组最上面放置的卡"
	-- 从卡组选择1张魔法卡
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	local tc=g:GetFirst()
	if tc then
		-- 将自己卡组重新洗牌
		Duel.ShuffleDeck(tp)
		-- 将选中的魔法卡移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认卡组最上方的1张卡并向玩家展示
		Duel.ConfirmDecktop(tp,1)
	end
end
