--プランキッズの大作戦
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。用自己场上的「调皮宝贝」怪兽为素材把1只「调皮宝贝」连接怪兽连接召唤。
-- ②：对方怪兽的攻击宣言时把墓地的这张卡除外才能发动。选自己墓地的「调皮宝贝」卡任意数量回到卡组，那只攻击怪兽的攻击力直到回合结束时下降回去数量×100。
function c15447747.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段才能发动。用自己场上的「调皮宝贝」怪兽为素材把1只「调皮宝贝」连接怪兽连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,15447747)
	e2:SetCondition(c15447747.lkcon)
	e2:SetTarget(c15447747.lktg)
	e2:SetOperation(c15447747.lkop)
	c:RegisterEffect(e2)
	-- ②：对方怪兽的攻击宣言时把墓地的这张卡除外才能发动。选自己墓地的「调皮宝贝」卡任意数量回到卡组，那只攻击怪兽的攻击力直到回合结束时下降回去数量×100。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,15447748)
	e3:SetCondition(c15447747.atkcon)
	-- 将此卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c15447747.atktg)
	e3:SetOperation(c15447747.atkop)
	c:RegisterEffect(e3)
end
-- 效果适用的时点为自己的主要阶段1或主要阶段2
function c15447747.lkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果适用的时点为自己的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：场上表侧表示的「调皮宝贝」怪兽
function c15447747.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x120)
end
-- 过滤条件：「调皮宝贝」连接怪兽且可以使用mg为素材进行连接召唤
function c15447747.lkfilter(c,mg)
	return c:IsSetCard(0x120) and c:IsLinkSummonable(mg)
end
-- 判断是否满足条件：场上的「调皮宝贝」连接怪兽且可以使用mg为素材进行连接召唤
function c15447747.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检索满足条件的「调皮宝贝」怪兽作为素材
		local mg=Duel.GetMatchingGroup(c15447747.matfilter,tp,LOCATION_MZONE,0,nil)
		-- 判断是否存在满足条件的「调皮宝贝」连接怪兽
		return Duel.IsExistingMatchingCard(c15447747.lkfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
	end
	-- 设置连锁操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理连接召唤效果
function c15447747.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索满足条件的「调皮宝贝」怪兽作为素材
	local mg=Duel.GetMatchingGroup(c15447747.matfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「调皮宝贝」连接怪兽
	local tg=Duel.SelectMatchingCard(tp,c15447747.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
	local tc=tg:GetFirst()
	if tc then
		-- 进行连接召唤
		Duel.LinkSummon(tp,tc,mg)
	end
end
-- 攻击宣言时，对方控制的怪兽进行攻击
function c15447747.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击宣言时，对方控制的怪兽进行攻击
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤条件：墓地的「调皮宝贝」卡且可以送回卡组
function c15447747.tdfilter(c)
	return c:IsSetCard(0x120) and c:IsAbleToDeck()
end
-- 判断是否满足条件：墓地存在「调皮宝贝」卡且可以送回卡组
function c15447747.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的「调皮宝贝」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c15447747.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置连锁操作信息：送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- 处理攻击宣言时的效果
function c15447747.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local tc=Duel.GetAttacker()
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的「调皮宝贝」卡
	local g=Duel.SelectMatchingCard(tp,c15447747.tdfilter,tp,LOCATION_GRAVE,0,1,99,nil)
	local ct=#g
	if ct>0 then
		-- 显示被选为对象的动画效果
		Duel.HintSelection(g)
	end
	-- 将选中的卡送回卡组
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	if tc:IsFaceup() and tc:IsRelateToBattle() and ct>0 then
		-- 使攻击怪兽的攻击力下降
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*-100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
