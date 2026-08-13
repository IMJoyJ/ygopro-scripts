--ティーチャーマドルチェ・グラスフレ
-- 效果：
-- 4星「魔偶甜点」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡1个超量素材取除，以场上1只「魔偶甜点」怪兽为对象才能发动。这个回合，那只表侧表示怪兽不受自身以外的怪兽的效果影响。
-- ②：这张卡在怪兽区域存在的状态，「魔偶甜点」卡被送去自己墓地的场合才能发动。自己·对方的墓地的卡合计最多2张回到卡组。
function c20343502.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以2只等级4的「魔偶甜点」怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x71),4,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，把这张卡1个超量素材取除，以场上1只「魔偶甜点」怪兽为对象才能发动。这个回合，那只表侧表示怪兽不受自身以外的怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20343502,0))  --"效果抗性"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,20343502)
	e1:SetCost(c20343502.cost)
	e1:SetTarget(c20343502.target)
	e1:SetOperation(c20343502.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，「魔偶甜点」卡被送去自己墓地的场合才能发动。自己·对方的墓地的卡合计最多2张回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20343502,1))  --"墓地回收"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,20343503)
	e2:SetCondition(c20343502.tdcon)
	e2:SetTarget(c20343502.tdtg)
	e2:SetOperation(c20343502.tdop)
	c:RegisterEffect(e2)
end
-- 效果①发动时的代价处理：检查并取除这张卡的1个超量素材，取除作为发动代价。
function c20343502.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果①可选对象的过滤条件：场上表侧表示且属于「魔偶甜点」字段的怪兽。
function c20343502.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x71)
end
-- 效果①发动时的目标处理：从双方场上选择1只表侧表示「魔偶甜点」怪兽作为对象。
function c20343502.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c20343502.filter(chkc) end
	-- 发动时检查：场上是否存在1只满足条件的表侧表示「魔偶甜点」怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c20343502.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择效果的对象”的提示信息，用于选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从双方场上选择1只表侧表示「魔偶甜点」怪兽，并将该卡设为效果对象。
	Duel.SelectTarget(tp,c20343502.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果①处理时：为对象怪兽附加效果免疫效果，使其这个回合不受自身以外的怪兽的效果影响。
function c20343502.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理阶段的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只表侧表示怪兽不受自身以外的怪兽的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c20343502.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 定义免疫判定条件：仅免疫来自除该怪兽自身以外的其他怪兽发动的效果。
function c20343502.efilter(e,re)
	return e:GetHandler()~=re:GetOwner() and re:IsActiveType(TYPE_MONSTER)
end
-- 定义效果②触发条件的过滤：卡片是自己控制的「魔偶甜点」卡。
function c20343502.tgfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x71)
end
-- 效果②的发动条件：有自己控制的「魔偶甜点」卡被送去自己墓地。
function c20343502.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20343502.tgfilter,1,nil,tp)
end
-- 效果②的发动目标阶段：确认双方墓地存在可返回卡组的卡，并设置将双方墓地的卡返回卡组的操作信息。
function c20343502.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方墓地是否存在至少1张可以返回卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 设置效果的操作信息：宣告本效果将双方墓地的卡返回卡组（count=1表示最少1张，处理时实际可选1~2张）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果②处理时：从双方墓地选择合计1~2张卡返回持有者卡组，然后洗牌。
function c20343502.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要返回卡组的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从双方墓地中选择1~2张不受王家长眠之谷影响且能返回卡组的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,2,nil)
	if #g>0 then
		-- 显示所选卡片的选中动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 将选中的卡以效果原因返回持有者卡组，并触发洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
