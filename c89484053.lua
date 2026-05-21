--転生炎獣モル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己对连接怪兽的连接召唤成功的回合的自己主要阶段才能发动。手卡的这张卡在作为连接怪兽所连接区的自己场上特殊召唤。
-- ②：自己场上没有怪兽存在的场合，把墓地的这张卡除外，以自己墓地5张「转生炎兽」卡为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽2张。
function c89484053.initial_effect(c)
	-- ①：自己对连接怪兽的连接召唤成功的回合的自己主要阶段才能发动。手卡的这张卡在作为连接怪兽所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89484053,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,89484053)
	e1:SetCondition(c89484053.spcon)
	e1:SetTarget(c89484053.sptg)
	e1:SetOperation(c89484053.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上没有怪兽存在的场合，把墓地的这张卡除外，以自己墓地5张「转生炎兽」卡为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89484053,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,89484054)
	e2:SetCondition(c89484053.drcon)
	-- 把墓地的这张卡除外作为发动效果的成本（Cost）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c89484053.drtg)
	e2:SetOperation(c89484053.drop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器，用于记录玩家进行连接召唤的次数
	Duel.AddCustomActivityCounter(89484053,ACTIVITY_SPSUMMON,c89484053.lkfilter)
end
-- 过滤函数：判定卡片是否为进行过连接召唤的连接怪兽（返回false时计数器增加）
function c89484053.lkfilter(c)
	return not (c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK))
end
-- 效果①的发动条件判定函数
function c89484053.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合玩家是否成功进行过连接召唤（计数器大于0）
	return Duel.GetCustomActivityCount(89484053,tp,ACTIVITY_SPSUMMON)>0
end
-- 效果①的发动准备（Target）函数
function c89484053.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家场上所有连接怪兽指向的自己怪兽区域（前锋5格的掩码）
	local zone=Duel.GetLinkedZone(tp)&0x1f
	-- 在发动准备阶段，检查是否存在可用的连接端区域且自己场上有空位
	if chk==0 then return zone~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) end
	-- 设置连锁处理中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理（Operation）函数
function c89484053.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 重新获取当前玩家场上连接怪兽指向的自己怪兽区域
	local zone=Duel.GetLinkedZone(tp)&0x1f
	if zone~=0 and c:IsRelateToEffect(e) then
		-- 将这张卡特殊召唤到指定的连接端区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 效果②的发动条件判定函数
function c89484053.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在怪兽（数量为0）
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件：自己墓地的「转生炎兽」卡且能返回卡组
function c89484053.drfilter(c)
	return c:IsSetCard(0x119) and c:IsAbleToDeck()
end
-- 效果②的发动准备（Target）函数
function c89484053.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c89484053.drfilter(chkc) end
	-- 在发动准备阶段，检查玩家当前是否能够进行抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查自己墓地是否存在5张满足条件的「转生炎兽」卡（排除自身）
		and Duel.IsExistingTarget(c89484053.drfilter,tp,LOCATION_GRAVE,0,5,c) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择墓地5张「转生炎兽」卡作为效果对象
	local g=Duel.SelectTarget(tp,c89484053.drfilter,tp,LOCATION_GRAVE,0,5,5,nil)
	-- 设置连锁处理中的操作信息：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置连锁处理中的操作信息：玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果②的效果处理（Operation）函数
function c89484053.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将对象卡片送回持有者卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果操作的卡片中存在被送回主卡组的卡，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断效果处理，使前后的「返回卡组」与「抽卡」不视为同时进行
		Duel.BreakEffect()
		-- 让玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
