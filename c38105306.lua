--削りゆく命
-- 效果：
-- ①：「逐渐削减的生命」在自己场上只能有1张表侧表示存在。
-- ②：对方结束阶段发动。给这张卡放置1个指示物。
-- ③：这张卡有指示物放置中的场合，自己·对方的主要阶段以及战斗阶段才能发动。这张卡送去墓地。那之后，对方尽可能选最多有这张卡放置的指示物数量的手卡丢弃。
function c38105306.initial_effect(c)
	c:SetUniqueOnField(1,0,38105306)
	c:EnableCounterPermit(0x62)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：对方结束阶段发动。给这张卡放置1个指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c38105306.ctcon)
	e2:SetTarget(c38105306.cttg)
	e2:SetOperation(c38105306.ctop)
	c:RegisterEffect(e2)
	-- ③：这张卡有指示物放置中的场合，自己·对方的主要阶段以及战斗阶段才能发动。这张卡送去墓地。那之后，对方尽可能选最多有这张卡放置的指示物数量的手卡丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_END)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(c38105306.hdcon)
	e3:SetTarget(c38105306.hdtg)
	e3:SetOperation(c38105306.hdop)
	c:RegisterEffect(e3)
end
-- 效果发动条件：当前回合玩家为对方
function c38105306.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果处理目标：设置指示物放置操作信息
function c38105306.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置指示物放置操作信息，放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x62)
end
-- 效果处理操作：为卡片添加1个指示物
function c38105306.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x62,1)
	end
end
-- 效果发动条件：当前阶段为主要阶段1或主要阶段2，且卡片有指示物
function c38105306.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_MAIN1 and ph<=PHASE_MAIN2 and e:GetHandler():GetCounter(0x62)>0
end
-- 效果处理目标：设置送去墓地和丢弃手牌操作信息
function c38105306.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() end
	e:SetLabel(c:GetCounter(0x62))
	-- 设置送去墓地操作信息，将卡片送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理操作：将卡片送去墓地并丢弃对方手牌
function c38105306.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断卡片是否在场且能发动效果，然后将卡片送去墓地
	if e:GetHandler():IsRelateToEffect(e) and Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT) then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 对方丢弃手牌，数量等于卡片上指示物数量
		Duel.DiscardHand(1-tp,nil,e:GetLabel(),e:GetLabel(),REASON_EFFECT+REASON_DISCARD)
	end
end
