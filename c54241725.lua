--真源の帝王
-- 效果：
-- 「真源的帝王」的②的效果1回合只能使用1次。
-- ①：1回合1次，以自己墓地2张「帝王」魔法·陷阱卡为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽1张。
-- ②：这张卡在墓地存在的场合，把这张卡以外的自己墓地1张「帝王」魔法·陷阱卡除外才能发动。这张卡变成通常怪兽（天使族·光·5星·攻1000/守2400）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
function c54241725.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_ATTACK+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己墓地2张「帝王」魔法·陷阱卡为对象才能发动。那些卡加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54241725,0))  --"加入卡组洗切？"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetTarget(c54241725.drtg)
	e2:SetOperation(c54241725.drop)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，把这张卡以外的自己墓地1张「帝王」魔法·陷阱卡除外才能发动。这张卡变成通常怪兽（天使族·光·5星·攻1000/守2400）在怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54241725,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,54241725)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCost(c54241725.spcost)
	e3:SetTarget(c54241725.sptg)
	e3:SetOperation(c54241725.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己墓地的「帝王」魔法·陷阱卡且可以回到卡组
function c54241725.tdfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 效果①的发动准备与合法性检测
function c54241725.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c54241725.tdfilter(chkc) end
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己墓地是否存在至少2张满足条件的「帝王」魔法·陷阱卡作为对象
		and Duel.IsExistingTarget(c54241725.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地2张「帝王」魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c54241725.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置连锁处理信息：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置连锁处理信息：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的效果处理函数
function c54241725.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将对象卡片送回持有者卡组并洗卡
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local og=Duel.GetOperatedGroup()
	if not og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then return end
	-- 洗切玩家的卡组
	Duel.ShuffleDeck(tp)
	-- 中断当前效果处理，使后续的抽卡处理不与回卡组同时进行（错时点）
	Duel.BreakEffect()
	-- 玩家从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end
-- 过滤条件：自己墓地可以作为Cost除外的「帝王」魔法·陷阱卡
function c54241725.cfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价（Cost）处理函数
function c54241725.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在除这张卡以外的1张「帝王」魔法·陷阱卡可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(c54241725.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1张「帝王」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c54241725.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的卡片表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备与合法性检测
function c54241725.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以将此卡作为特定属性、种族、攻守和等级的通常怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,54241725,0,TYPES_NORMAL_TRAP_MONSTER,1000,2400,5,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 设置连锁处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理函数
function c54241725.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关，且玩家是否仍能将其作为特定怪兽特殊召唤
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,54241725,0,TYPES_NORMAL_TRAP_MONSTER,1000,2400,5,RACE_FAIRY,ATTRIBUTE_LIGHT) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将此卡在自己场上表侧守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
	end
end
