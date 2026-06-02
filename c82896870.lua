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
-- 过滤条件：墓地的「玩具罐」且能被在自己场上盖放
function c82896870.cfilter(c)
	return c:IsCode(70245411) and c:IsSSetable()
end
-- 过滤条件：卡组中的「锋利小鬼·剪刀」或者「毛绒动物」怪兽，且能送去墓地
function c82896870.tgfilter(c)
	return (c:IsCode(30068120) or c:IsSetCard(0xa9) and c:IsType(TYPE_MONSTER)) and c:IsAbleToGrave()
end
-- ①效果的发动准备：以自己墓地1张「玩具罐」为对象才能发动，并设置相关操作信息
function c82896870.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c82896870.cfilter(chkc) end
	-- 判断自己墓地是否存在可盖放的「玩具罐」
	if chk==0 then return Duel.IsExistingTarget(c82896870.cfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 且自己卡组中是否存在可以送去墓地的「锋利小鬼·剪刀」或者「毛绒动物」怪兽
		and Duel.IsExistingMatchingCard(c82896870.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 给玩家提示选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张「玩具罐」作为对象
	local g=Duel.SelectTarget(tp,c82896870.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：包含卡片离开墓地盖放的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的执行：将选择的「玩具罐」在自己场上盖放，并从卡组把1只「锋利小鬼·剪刀」或者1只「毛绒动物」怪兽送去墓地
function c82896870.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的墓地的「玩具罐」
	local tc=Duel.GetFirstTarget()
	-- 如果对象卡片有效且成功在场上盖放
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 给玩家提示选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1只符合条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c82896870.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：这张卡成为融合素材被送去墓地
function c82896870.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤条件：自己墓地或除外的「融合」魔法卡，且能返回卡组
function c82896870.filter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- ②效果的发动准备：确认符合条件的卡存在，并设置返回卡组的操作信息
function c82896870.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己墓地或除外卡中是否存在可返回卡组的「融合」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c82896870.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：包含将墓地或除外的卡片返回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果的执行：从自己墓地或除外卡中选1张符合条件的卡返回卡组
function c82896870.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家提示选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地或除外卡中选择1张不受王家长眠之谷影响的符合条件的「融合」魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c82896870.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 向双方玩家展示所选择的卡片
		Duel.HintSelection(g)
		-- 将所选择的卡片送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
