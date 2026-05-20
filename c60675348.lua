--ダイナミスト・ハウリング
-- 效果：
-- ①：作为这张卡的发动时的效果处理，可以从卡组选最多2只「雾动机龙」灵摆怪兽在自己的灵摆区域放置。放置的场合，直到下个回合的结束时，自己不是「雾动机龙」怪兽不能灵摆召唤。
-- ②：这张卡已在魔法与陷阱区域表侧表示存在的场合，1回合1次，把自己场上1只「雾动机龙」怪兽解放，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
function c60675348.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组选最多2只「雾动机龙」灵摆怪兽在自己的灵摆区域放置。放置的场合，直到下个回合的结束时，自己不是「雾动机龙」怪兽不能灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetOperation(c60675348.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡已在魔法与陷阱区域表侧表示存在的场合，1回合1次，把自己场上1只「雾动机龙」怪兽解放，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60675348,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c60675348.thcost)
	e2:SetTarget(c60675348.thtg)
	e2:SetOperation(c60675348.thop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以放置到灵摆区域的「雾动机龙」灵摆怪兽
function c60675348.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xd8) and not c:IsForbidden()
end
-- 卡片发动时的效果处理，选择并放置「雾动机龙」灵摆怪兽，并适用灵摆召唤限制
function c60675348.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取卡组中所有满足过滤条件的「雾动机龙」灵摆怪兽
	local g=Duel.GetMatchingGroup(c60675348.filter,tp,LOCATION_DECK,0,nil)
	local ct=0
	-- 检查左侧灵摆区域是否空闲，若空闲则可用位置数量加1
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ct=ct+1 end
	-- 检查右侧灵摆区域是否空闲，若空闲则可用位置数量加1
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ct=ct+1 end
	-- 若有空闲灵摆位且卡组有可放置的怪兽，询问玩家是否选择放置
	if ct>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(60675348,0)) then  --"是否把「雾动机龙」灵摆怪兽放置？"
		-- 提示玩家选择要放置到场上的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		local sg=g:Select(tp,1,ct,nil)
		local sc=sg:GetFirst()
		while sc do
			-- 将选中的灵摆怪兽表侧表示移动到自己的灵摆区域
			Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			sc=sg:GetNext()
		end
		-- 直到下个回合的结束时，自己不是「雾动机龙」怪兽不能灵摆召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c60675348.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 在全局注册该灵摆召唤限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制非「雾动机龙」怪兽的灵摆召唤
function c60675348.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xd8) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 效果②的COST处理函数，检查并解放自己场上1只「雾动机龙」怪兽
function c60675348.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否存在可解放的「雾动机龙」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0xd8) end
	-- 让玩家选择自己场上1只「雾动机龙」怪兽解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0xd8)
	-- 解放选中的怪兽作为发动的代价
	Duel.Release(g,REASON_COST)
end
-- 效果②的目标选择与发动条件检查函数
function c60675348.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在可以返回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以返回手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理的操作信息，表示该效果会将1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理函数，将作为对象的卡送回持有者手牌
function c60675348.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的对象卡
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
