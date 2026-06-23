--イグナイト・アヴェンジャー
-- 效果：
-- ①：以自己场上3张「点火骑士」卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。
-- ②：1回合1次，以这张卡以外的自己场上1只「点火骑士」怪兽为对象才能发动。那张卡回到持有者手卡，选对方场上1张魔法·陷阱卡回到持有者卡组最下面。
function c23296404.initial_effect(c)
	-- ①：以自己场上3张「点火骑士」卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c23296404.sptg)
	e1:SetOperation(c23296404.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以这张卡以外的自己场上1只「点火骑士」怪兽为对象才能发动。那张卡回到持有者手卡，选对方场上1张魔法·陷阱卡回到持有者卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c23296404.tdtg)
	e2:SetOperation(c23296404.tdop)
	c:RegisterEffect(e2)
end
-- 过滤函数，返回场上正面表示的「点火骑士」卡
function c23296404.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc8)
end
-- 过滤函数，返回满足条件的「点火骑士」卡且能成为效果的对象
function c23296404.desfilter2(c,e)
	return c23296404.desfilter(c) and c:IsCanBeEffectTarget(e)
end
-- 效果处理时的条件判断，检查是否满足发动条件
function c23296404.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c23296404.desfilter(chkc) end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chk==0 then return ct<=3 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否存在至少3张「点火骑士」卡
		and Duel.IsExistingTarget(c23296404.desfilter,tp,LOCATION_ONFIELD,0,3,nil)
		-- 检查是否满足额外的「点火骑士」卡选择条件
		and (ct<=0 or Duel.IsExistingTarget(c23296404.desfilter,tp,LOCATION_MZONE,0,ct,nil)) end
	local g=nil
	if ct>0 then
		-- 获取满足条件的「点火骑士」卡组
		local tg=Duel.GetMatchingGroup(c23296404.desfilter2,tp,LOCATION_ONFIELD,0,nil,e)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		g=tg:FilterSelect(tp,Card.IsLocation,ct,ct,nil,LOCATION_MZONE)
		if ct<3 then
			tg:Sub(g)
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local g2=tg:Select(tp,3-ct,3-ct,nil)
			g:Merge(g2)
		end
		-- 设置当前连锁的效果对象为g
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择3张「点火骑士」卡作为效果对象
		g=Duel.SelectTarget(tp,c23296404.desfilter,tp,LOCATION_ONFIELD,0,3,3,nil)
	end
	-- 设置操作信息，指定要破坏的卡数量为3
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,3,0,0)
	-- 设置操作信息，指定要特殊召唤的卡为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行破坏和特殊召唤操作
function c23296404.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡组破坏
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，返回场上正面表示的「点火骑士」怪兽且能回手
function c23296404.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc8) and c:IsAbleToHand()
end
-- 过滤函数，返回魔法·陷阱卡且能回卡组
function c23296404.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 效果处理时的条件判断，检查是否满足发动条件
function c23296404.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23296404.thfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查场上是否存在至少1只「点火骑士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c23296404.thfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查对方场上是否存在至少1张魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c23296404.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要回手的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只「点火骑士」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c23296404.thfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息，指定要回手的卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息，指定要回卡组的卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
end
-- 效果处理函数，执行回手和回卡组操作
function c23296404.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否有效且成功回手
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择1张魔法·陷阱卡作为效果对象
		local g=Duel.SelectMatchingCard(tp,c23296404.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 将对象卡送回卡组最下面
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
