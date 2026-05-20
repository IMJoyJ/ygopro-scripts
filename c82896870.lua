--ファーニマル・ドルフィン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1张「玩具罐」为对象才能发动。那张卡在自己场上盖放，从卡组把1只「锋利小鬼·剪刀」或者1只「毛绒动物」怪兽送去墓地。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从自己墓地的卡以及除外的自己的卡之中选1张「融合」魔法卡回到卡组。
function c82896870.initial_effect(c)
	-- ①：以自己墓地1张「玩具罐」为对象才能发动。那张卡在自己场上盖放，从卡组把1只「锋利小鬼·剪刀」或者1只「毛绒动物」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82896870,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,82896870)
	e1:SetTarget(c82896870.tgtg)
	e1:SetOperation(c82896870.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从自己墓地的卡以及除外的自己的卡之中选1张「融合」魔法卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82896870,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,82896871)
	e2:SetCondition(c82896870.condition)
	e2:SetTarget(c82896870.target)
	e2:SetOperation(c82896870.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡名为「玩具罐」且可以在场上盖放的卡
function c82896870.cfilter(c)
	return c:IsCode(70245411) and c:IsSSetable()
end
-- 过滤条件：卡名为「锋利小鬼·剪刀」或「毛绒动物」怪兽，且能送去墓地
function c82896870.tgfilter(c)
	return (c:IsCode(30068120) or c:IsSetCard(0xa9) and c:IsType(TYPE_MONSTER)) and c:IsAbleToGrave()
end
-- 效果①的发动准备与目标选择
function c82896870.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c82896870.cfilter(chkc) end
	-- 检查自己墓地是否存在可以盖放的「玩具罐」
	if chk==0 then return Duel.IsExistingTarget(c82896870.cfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 并且检查卡组是否存在可以送去墓地的「锋利小鬼·剪刀」或「毛绒动物」怪兽
		and Duel.IsExistingMatchingCard(c82896870.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张「玩具罐」作为效果对象
	local g=Duel.SelectTarget(tp,c82896870.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：涉及卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（盖放「玩具罐」并从卡组将怪兽送去墓地）
function c82896870.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的「玩具罐」
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合条件，则将其在自己场上盖放，盖放成功时才继续处理
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只「锋利小鬼·剪刀」或「毛绒动物」怪兽
		local g=Duel.SelectMatchingCard(tp,c82896870.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 触发条件：这张卡作为融合召唤的素材送去墓地的场合
function c82896870.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_FUSION
end
-- 过滤条件：自己墓地或除外状态的「融合」魔法卡，且能回到卡组
function c82896870.filter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 效果②的发动准备与目标检查
function c82896870.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地或除外的卡中是否存在可以回到卡组的「融合」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82896870.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：从墓地或除外状态将1张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的效果处理（将「融合」魔法卡回到卡组）
function c82896870.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地或除外的卡中选择1张不受「王家长眠之谷」影响的「融合」魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c82896870.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 确认并向双方玩家展示选择的卡片
		Duel.HintSelection(g)
		-- 将选择的卡送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
