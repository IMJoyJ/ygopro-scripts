--ヴァリアント・シャーク・ランサー
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只怪兽为对象才能发动。自己场上1个超量素材取除，作为对象的怪兽破坏。自己场上有其他的水属性超量怪兽存在的场合，这个效果在对方回合也能发动。
-- ②：这张卡已在怪兽区域存在的状态，自己场上的其他的水属性超量怪兽被战斗·效果破坏的场合才能发动。从卡组选1张魔法卡在卡组最上面放置。
function c23672629.initial_effect(c)
	-- 为卡片添加等级为5、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：以对方场上1只怪兽为对象才能发动。自己场上1个超量素材取除，作为对象的怪兽破坏。自己场上有其他的水属性超量怪兽存在的场合，这个效果在对方回合也能发动。
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
-- 效果①的发动条件：自己场上没有水属性超量怪兽
function c23672629.descon1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果①的发动条件：自己场上没有水属性超量怪兽
	return not Duel.IsExistingMatchingCard(c23672629.desfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果②的发动条件：自己场上存在水属性超量怪兽
function c23672629.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果②的发动条件：自己场上存在水属性超量怪兽
	return Duel.IsExistingMatchingCard(c23672629.desfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤函数：用于判断是否为水属性且为超量怪兽的怪兽
function c23672629.desfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
end
-- 效果①的发动时的取对象处理：选择对方场上一只怪兽作为对象
function c23672629.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 效果①的发动条件：对方场上存在怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		-- 效果①的发动条件：自己场上可以移除1个超量素材
		and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上一只怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理：移除1个超量素材并破坏对象怪兽
function c23672629.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 移除1个超量素材并确认对象怪兽有效
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT) and tc:IsRelateToEffect(e) then
		-- 破坏对象怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数：用于判断被破坏的怪兽是否为水属性超量怪兽
function c23672629.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WATER)~=0 and bit.band(c:GetPreviousTypeOnField(),TYPE_XYZ)~=0
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果②的发动条件：被破坏的怪兽为水属性超量怪兽且为己方怪兽
function c23672629.tpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23672629.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 效果②的发动时的处理准备：确认卡组中存在魔法卡
function c23672629.tptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果②的发动条件：卡组中存在魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_SPELL) end
end
-- 效果②的处理：从卡组选择一张魔法卡放置在卡组最上方
function c23672629.tpop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置在卡组最上方的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23672629,2))  --"请选择要在卡组最上面放置的卡"
	-- 从卡组中选择一张魔法卡
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	local tc=g:GetFirst()
	if tc then
		-- 将卡组洗切
		Duel.ShuffleDeck(tp)
		-- 将选中的魔法卡移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认卡组最上方的卡
		Duel.ConfirmDecktop(tp,1)
	end
end
