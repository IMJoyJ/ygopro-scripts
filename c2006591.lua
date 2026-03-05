--目醒める罪宝
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有5星以上的幻想魔族怪兽存在，对方场上有怪兽3只以上存在的场合，以对方场上最多3张卡为对象才能发动。那些卡回到手卡。
-- ②：这张卡在墓地存在，自己场上有5星以上的幻想魔族怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册两个效果，分别为①效果（回到手卡）和②效果（盖放）
function s.initial_effect(c)
	-- ①：自己场上有5星以上的幻想魔族怪兽存在，对方场上有怪兽3只以上存在的场合，以对方场上最多3张卡为对象才能发动。那些卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有5星以上的幻想魔族怪兽存在的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 判断场上是否存在5星以上幻想魔族怪兽的过滤器
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsRace(RACE_ILLUSION)
end
-- ①效果的发动条件：自己场上有5星以上的幻想魔族怪兽存在，且对方场上有怪兽3只以上存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在5星以上的幻想魔族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少3只怪兽
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,3,nil)
end
-- ①效果的目标选择函数：选择对方场上的1~3张可送回手牌的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 判断是否满足①效果的目标选择条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的1~3张可送回手牌的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,3,nil)
	-- 设置①效果的处理信息为将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ①效果的处理函数：将目标卡送回手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将符合条件的目标卡送回手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡在墓地存在，且自己场上有5星以上的幻想魔族怪兽存在
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在5星以上的幻想魔族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的目标选择函数：判断此卡是否可以盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置②效果的处理信息为将此卡从墓地送至场上盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数：将此卡盖放并设置其离场时的去向
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否可以盖放并执行盖放操作
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 设置此卡离场时被移除的处理效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
