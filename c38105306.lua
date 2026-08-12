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
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES_OPPO)
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
-- ②效果发动条件判断函数：当前是否为对方的结束阶段
function c38105306.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方（1-tp），即只在对方结束阶段才能发动
	return Duel.GetTurnPlayer()==1-tp
end
-- ②效果的目标处理函数：设置本次连锁将放置1个指示物的操作信息
function c38105306.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向引擎登记操作信息：本次连锁将放置1个指示物（0x62），用于星尘龙等效果的连锁检测
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x62)
end
-- ②效果的处理函数：确认这张卡仍与效果相关联后，给这张卡放置1个指示物
function c38105306.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x62,1)
	end
end
-- ③效果发动条件判断函数：当前处于主要阶段或战斗阶段，且这张卡放置有指示物
function c38105306.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前所处的阶段，用于判断是否在主要阶段或战斗阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_MAIN1 and ph<=PHASE_MAIN2 and e:GetHandler():GetCounter(0x62)>0
end
-- ③效果的目标处理函数：确认这张卡可以送去墓地，记录指示物数量并登记送去墓地的操作信息
function c38105306.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() end
	e:SetLabel(c:GetCounter(0x62))
	-- 向引擎登记操作信息：本次连锁将把这张卡（1张）送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- ③效果的处理函数：把这张卡送去墓地，然后让对方尽可能选最多有指示物数量的手卡丢弃
function c38105306.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认这张卡仍与效果相关联，并将其以效果原因送去墓地，成功送墓才继续处理后续丢弃
	if e:GetHandler():IsRelateToEffect(e) and Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)>0 then
		-- 中断当前效果处理，使之后的丢弃手卡处理视为不同时处理（错时点）
		Duel.BreakEffect()
		-- 让对方尽可能选最多有记录的指示物数量的手卡，以效果原因丢弃
		Duel.DiscardHand(1-tp,nil,e:GetLabel(),e:GetLabel(),REASON_EFFECT+REASON_DISCARD)
	end
end
