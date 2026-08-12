--リトマスの死儀式
-- 效果：
-- 「石蕊之死剑士」的降临必需。这个卡名的②的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把等级合计直到8以上的怪兽解放，从手卡把「石蕊之死剑士」仪式召唤。
-- ②：这张卡在墓地存在的场合，以自己墓地1只「石蕊之死剑士」为对象才能发动。墓地的这张卡和作为对象的怪兽合计2张加入卡组洗切。那之后，自己从卡组抽1张。
function c8955148.initial_effect(c)
	-- 注册仪式召唤效果，指定仪式召唤怪兽为「石蕊之死剑士」（等级合计可以超过原本等级）
	aux.AddRitualProcGreaterCode(c,72566043)
	-- ②：这张卡在墓地存在的场合，以自己墓地1只「石蕊之死剑士」为对象才能发动。墓地的这张卡和作为对象的怪兽合计2张加入卡组洗切。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,8955148)
	e1:SetTarget(c8955148.tdtg)
	e1:SetOperation(c8955148.tdop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中卡名为「石蕊之死剑士」且可以返回卡组的怪兽
function c8955148.tdfilter(c)
	return c:IsCode(72566043) and c:IsAbleToDeck()
end
-- 效果发动的合法性检测与对象判定（验证墓地中是否存在符合条件的「石蕊之死剑士」且自身能返回卡组）
function c8955148.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c8955148.tdfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsAbleToDeck()
		-- 检查自己墓地中是否存在除这张卡以外的、可以作为对象的「石蕊之死剑士」
		and Duel.IsExistingTarget(c8955148.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地中1只「石蕊之死剑士」作为效果的对象
	local g=Duel.SelectTarget(tp,c8955148.tdfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 设置效果处理信息：将包含自身和对象的2张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置效果处理信息：玩家从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：将自身和作为对象的怪兽返回卡组洗切，那之后抽1张卡
function c8955148.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽（即墓地中的「石蕊之死剑士」）
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		-- 将自身和对象怪兽送回卡组洗切，若没有卡成功返回则终止效果
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 中断当前效果，使后续的抽卡处理与返回卡组不视为同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
