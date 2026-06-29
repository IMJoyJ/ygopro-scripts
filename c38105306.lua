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
-- 对方结束阶段发动条件的判定
function c38105306.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是否为对方的回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 放置指示物效果的发动准备
function c38105306.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为在这张卡上放置1个指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x62)
end
-- 在这个回合的对方结束阶段，在此卡上放置1个指示物
function c38105306.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x62,1)
	end
end
-- 确认当前处于主要阶段或战斗阶段且此卡拥有至少1个指示物
function c38105306.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_MAIN1 and ph<=PHASE_MAIN2 and e:GetHandler():GetCounter(0x62)>0
end
-- 送去墓地迫使对方丢手卡效果的发动准备
function c38105306.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() end
	e:SetLabel(c:GetCounter(0x62))
	-- 设置操作信息为将这张卡自身送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 送去墓地迫使对方丢手卡效果的执行
function c38105306.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此卡依然正常在场且成功通过效果送入墓地，则继续处理
	if e:GetHandler():IsRelateToEffect(e) and Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)>0 then
		-- 在送去墓地后切断效果连锁以执行丢弃手卡动作
		Duel.BreakEffect()
		-- 对方玩家尽可能选择最多等于此卡被送墓前所持指示物数量的手牌丢弃到墓地
		Duel.DiscardHand(1-tp,nil,e:GetLabel(),e:GetLabel(),REASON_EFFECT+REASON_DISCARD)
	end
end
