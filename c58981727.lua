--妖仙獣 侍郎風
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有其他的「妖仙兽」卡存在，这张卡召唤成功的场合才能发动。从卡组把1只「妖仙兽」灵摆怪兽加入手卡。
-- ②：以自己场上1张「妖仙兽」卡为对象才能发动。从卡组把1张「妖仙乡的眩晕风」或者「妖仙大旋风」在自己的魔法与陷阱区域表侧表示放置，作为对象的卡回到持有者卡组。
-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c58981727.initial_effect(c)
	-- ①：自己场上有其他的「妖仙兽」卡存在，这张卡召唤成功的场合才能发动。从卡组把1只「妖仙兽」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,58981727)
	e1:SetCondition(c58981727.thcon)
	e1:SetTarget(c58981727.thtg)
	e1:SetOperation(c58981727.thop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1张「妖仙兽」卡为对象才能发动。从卡组把1张「妖仙乡的眩晕风」或者「妖仙大旋风」在自己的魔法与陷阱区域表侧表示放置，作为对象的卡回到持有者卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,58981728)
	e2:SetTarget(c58981727.tftg)
	e2:SetOperation(c58981727.tfop)
	c:RegisterEffect(e2)
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c58981727.regop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「妖仙兽」卡
function c58981727.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- ①号效果的发动条件：自己场上有其他的「妖仙兽」卡存在
function c58981727.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除自身以外的表侧表示「妖仙兽」卡
	return Duel.IsExistingMatchingCard(c58981727.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 过滤条件：卡组中可加入手牌的「妖仙兽」灵摆怪兽
function c58981727.thfilter(c)
	return c:IsSetCard(0xb3) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- ①号效果的发动准备与效果分类设置
function c58981727.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「妖仙兽」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58981727.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的实际处理：从卡组检索1只「妖仙兽」灵摆怪兽
function c58981727.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足条件的「妖仙兽」灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c58981727.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示且能回到卡组的「妖仙兽」卡
function c58981727.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3) and c:IsAbleToDeck()
end
-- 过滤条件：卡组中未被禁止且卡名为「妖仙乡的眩晕风」或「妖仙大旋风」的卡
function c58981727.tffilter(c)
	return c:IsCode(62681049,79861914) and not c:IsForbidden()
end
-- ②号效果的发动准备与选择对象
function c58981727.tftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and c58981727.tdfilter(chkc) end
	-- 检查自己魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以作为对象的「妖仙兽」卡
		and Duel.IsExistingTarget(c58981727.tdfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查卡组中是否存在可以放置的「妖仙乡的眩晕风」或「妖仙大旋风」
		and Duel.IsExistingMatchingCard(c58981727.tffilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择自己场上1张「妖仙兽」卡作为效果的对象
	local g=Duel.SelectTarget(tp,c58981727.tdfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁处理信息：将选中的对象卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②号效果的实际处理：从卡组放置魔陷并将对象卡送回卡组
function c58981727.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1张「妖仙乡的眩晕风」或「妖仙大旋风」
	local sc=Duel.SelectMatchingCard(tp,c58981727.tffilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc then
		-- 将选择的卡在自己的魔法与陷阱区域表侧表示放置
		Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 获取作为效果对象的卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的卡因效果送回持有者卡组并洗牌
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 注册结束阶段使自身回到手牌的延迟触发效果
function c58981727.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c58981727.rettg)
	e1:SetOperation(c58981727.retop)
	e1:SetReset(RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- ③号效果的发动准备与效果分类设置
function c58981727.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息：将这张卡送回持有者手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③号效果的实际处理：将这张卡送回持有者手牌
function c58981727.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡因效果送回持有者手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
