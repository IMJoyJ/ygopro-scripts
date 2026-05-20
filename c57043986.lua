--ブルーアイズ・ソリッド・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果无效。
-- ②：对方把魔法·陷阱·怪兽的效果发动时才能发动。场上的这张卡回到持有者卡组，从卡组把1只「青眼白龙」特殊召唤。
function c57043986.initial_effect(c)
	-- 记录该卡记载了「青眼白龙」的卡名
	aux.AddCodeList(c,89631139)
	-- ①：这张卡召唤·特殊召唤成功的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57043986,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,57043986)
	e1:SetTarget(c57043986.negtg)
	e1:SetOperation(c57043986.negop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方把魔法·陷阱·怪兽的效果发动时才能发动。场上的这张卡回到持有者卡组，从卡组把1只「青眼白龙」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57043986,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,57043987)
	e3:SetCondition(c57043986.spcon)
	e3:SetTarget(c57043986.sptg)
	e3:SetOperation(c57043986.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：对方场上表侧表示且未被无效的效果怪兽
function c57043986.negfilter(c)
	-- 检查卡片是否为怪兽卡，且符合可被无效的条件
	return c:IsType(TYPE_MONSTER) and aux.NegateMonsterFilter(c)
end
-- 效果①的对象选择与发动准备
function c57043986.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c57043986.negfilter(chkc) end
	-- 检查对方场上是否存在可被无效的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c57043986.negfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c57043986.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为无效该怪兽的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果①的效果处理（使目标怪兽效果无效）
function c57043986.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 无效化与该怪兽相关的连锁
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
end
-- 效果②的发动条件：对方发动魔法·陷阱·怪兽的效果时
function c57043986.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤条件：卡组中可以特殊召唤的「青眼白龙」
function c57043986.spfilter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与可行性检查
function c57043986.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身离开场后是否有可用怪兽区域，且自身是否能回到卡组
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToDeck()
		-- 检查卡组中是否存在可以特殊召唤的「青眼白龙」
		and Duel.IsExistingMatchingCard(c57043986.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（自身回卡组并特召「青眼白龙」）
function c57043986.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 自身回到持有者卡组并洗牌，成功时继续处理
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 检查是否有可用的怪兽区域，若无则无法特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只「青眼白龙」
		local g=Duel.SelectMatchingCard(tp,c57043986.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的「青眼白龙」表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
