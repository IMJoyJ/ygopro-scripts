--ヴァリアント・シャーク・ランサー
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方场上1只怪兽为对象才能发动。自己场上1个超量素材取除，作为对象的怪兽破坏。自己场上有其他的水属性超量怪兽存在的场合，这个效果在对方回合也能发动。
-- ②：这张卡已在怪兽区域存在的状态，自己场上的其他的水属性超量怪兽被战斗·效果破坏的场合才能发动。从卡组选1张魔法卡在卡组最上面放置。
function c23672629.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用2只等级5的怪兽叠放进行超量召唤（对应素材要求：5星怪兽×2）
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：以对方场上1只怪兽为对象才能发动。自己场上1个超量素材取除，作为对象的怪兽破坏。
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
-- ①效果在自己回合发动的条件的判断函数：自己场上没有这张卡以外的水属性超量怪兽时才能作为起动效果发动
function c23672629.descon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在这张卡以外的表侧表示水属性超量怪兽（不存在时①效果只能在自己回合作为起动效果发动）
	return not Duel.IsExistingMatchingCard(c23672629.desfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- ①效果作为诱发即时效果（在对方回合也能发动）的条件的判断函数：自己场上有这张卡以外的水属性超量怪兽存在时才能发动
function c23672629.descon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在这张卡以外的表侧表示水属性超量怪兽（存在时①效果在对方回合也能发动）
	return Duel.IsExistingMatchingCard(c23672629.desfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤函数：判断是否为表侧表示的水属性超量怪兽
function c23672629.desfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
end
-- ①效果的对象选择与发动条件检查：取对象检查目标是否在对方怪兽区域，可发动性检查对方场上是否存在可以成为对象的怪兽且自己能够移除超量素材
function c23672629.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 可发动性检查：对方怪兽区域是否存在至少1只可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		-- 并且检查自己能否以效果原因移除自己场上至少1个超量素材
		and Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
	-- 向玩家提示“请选择要破坏的卡”的选择提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方怪兽区域1只怪兽作为破坏效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息为破坏分类，确定要破坏的卡为作为对象的那1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的处理函数：取得作为对象的怪兽，成功取除自己场上1个超量素材且对象仍与效果关联时，将那只怪兽破坏
function c23672629.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	-- 从自己场上取除1个超量素材（效果原因），成功且作为对象的怪兽仍与这个效果保持关联时进入处理
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数：判断被破坏的卡是否为原本在自己场上表侧表示存在的水属性超量怪兽，且因战斗或效果被破坏
function c23672629.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_WATER)~=0 and bit.band(c:GetPreviousTypeOnField(),TYPE_XYZ)~=0
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ②效果的发动条件判断函数：被破坏的怪兽中存在满足条件的卡（自己场上原本的水属性超量怪兽被战斗·效果破坏），且其中不包含这张卡本身
function c23672629.tpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23672629.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果的可发动性检查函数：确认自己卡组中存在至少1张魔法卡
function c23672629.tptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 可发动性检查：自己卡组中是否存在至少1张魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_SPELL) end
end
-- ②效果的处理函数：从卡组选1张魔法卡，洗切卡组后将那张卡移动到卡组最上面，并确认卡组最上方的卡
function c23672629.tpop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示“请选择要在卡组最上面放置的卡”的选择提示信息
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23672629,2))  --"请选择要在卡组最上面放置的卡"
	-- 让玩家从自己卡组选择1张魔法卡
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL)
	local tc=g:GetFirst()
	if tc then
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		-- 将选择的魔法卡移动到卡组最上面
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认自己卡组最上方的1张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
