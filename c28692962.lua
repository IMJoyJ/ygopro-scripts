--紫宵の機界騎士
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：相同纵列有卡2张以上存在的场合，这张卡可以从手卡往那个纵列的自己场上特殊召唤。
-- ②：以自己场上1只「机界骑士」怪兽为对象才能发动。那只怪兽直到下次的自己回合的准备阶段除外，从卡组把「紫宵之机界骑士」以外的1只「机界骑士」怪兽加入手卡。这个效果在对方回合也能发动。
function c28692962.initial_effect(c)
	-- ①：相同纵列有卡2张以上存在的场合，这张卡可以从手卡往那个纵列的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,28692962+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c28692962.hspcon)
	e1:SetValue(c28692962.hspval)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「机界骑士」怪兽为对象才能发动。那只怪兽直到下次的自己回合的准备阶段除外，从卡组把「紫宵之机界骑士」以外的1只「机界骑士」怪兽加入手卡。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28692962,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,28692963)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetTarget(c28692962.thtg)
	e2:SetOperation(c28692962.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断一张卡是否在同一纵列有至少1张卡
function c28692962.cfilter(c)
	return c:GetColumnGroupCount()>0
end
-- 特殊召唤条件函数，检查是否有满足条件的纵列区域可用于特殊召唤
function c28692962.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有满足cfilter条件的卡
	local lg=Duel.GetMatchingGroup(c28692962.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历满足条件的卡组
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	-- 判断在指定区域是否有足够的空位用于特殊召唤
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 特殊召唤值函数，返回特殊召唤所需的区域
function c28692962.hspval(e,c)
	local tp=c:GetControler()
	local zone=0
	-- 获取场上所有满足cfilter条件的卡
	local lg=Duel.GetMatchingGroup(c28692962.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 遍历满足条件的卡组
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return 0,zone
end
-- 过滤函数，用于判断一张卡是否为表侧表示的机界骑士族怪兽且能除外
function c28692962.rmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10c) and c:IsAbleToRemove()
end
-- 过滤函数，用于判断一张卡是否为机界骑士族怪兽且能加入手牌
function c28692962.thfilter(c)
	return c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER) and not c:IsCode(28692962) and c:IsAbleToHand()
end
-- 效果的发动条件函数，检查是否能选择目标怪兽并检索满足条件的卡
function c28692962.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28692962.rmfilter(chkc) end
	-- 检查是否能选择目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c28692962.rmfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否能从卡组检索满足条件的卡
		and Duel.IsExistingMatchingCard(c28692962.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c28692962.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，指定要除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息，指定要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行除外和检索操作
function c28692962.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0
		and tc:IsLocation(LOCATION_REMOVED) then
		-- 创建一个在下次准备阶段将怪兽返回场上的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(28692962,1))  --"除外的怪兽回到场上"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c28692962.retcon)
		e1:SetOperation(c28692962.retop)
		-- 判断是否为当前玩家的回合且当前阶段为准备阶段
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()<=PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
			-- 记录当前回合数用于判断是否为同一回合
			e1:SetValue(Duel.GetTurnCount())
			tc:RegisterFlagEffect(28692962,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
			e1:SetValue(0)
			tc:RegisterFlagEffect(28692962,RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
		end
		-- 将效果注册到场上
		Duel.RegisterEffect(e1,tp)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择要加入手牌的卡
		local g=Duel.SelectMatchingCard(tp,c28692962.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判断是否为下次准备阶段返回怪兽的条件
function c28692962.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前玩家回合且不是同一回合
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	return e:GetLabelObject():GetFlagEffect(28692962)~=0
end
-- 将怪兽返回场上
function c28692962.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将怪兽返回场上
	Duel.ReturnToField(tc)
end
