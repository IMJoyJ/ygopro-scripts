--アザミナ・アーフェス
-- 效果：
-- 这个卡名在规则上也当作「白森林」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以最多有自己的场上·墓地的恶魔族·幻想魔族·魔法师族的融合·同调怪兽数量的场上的卡为对象才能发动。那些卡回到手卡。
-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果，①为发动效果，②为送去墓地时的诱发效果
function s.initial_effect(c)
	-- ①：以最多有自己的场上·墓地的恶魔族·幻想魔族·魔法师族的融合·同调怪兽数量的场上的卡为对象才能发动。那些卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于筛选场上或墓地的恶魔族·幻想魔族·魔法师族的融合·同调怪兽
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_FIEND+RACE_ILLUSION+RACE_SPELLCASTER)
		and c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- 效果处理函数，计算满足条件的怪兽数量并选择目标卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取满足条件的怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 判断是否满足发动条件，即有满足条件的怪兽且场上存在可返回手牌的卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,e:GetHandler())
	-- 设置操作信息，记录将要返回手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 处理①效果的发动，将目标卡返回手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡返回手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 判断②效果发动条件，即该卡因支付费用送去墓地且是怪兽效果发动
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- 设置②效果的发动目标，判断是否可以盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息，记录将要盖放的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 处理②效果的发动，将该卡盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否能盖放，排除王家长眠之谷影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then Duel.SSet(tp,c) end
end
