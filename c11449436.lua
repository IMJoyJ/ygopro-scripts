--氷河のアクア・マドール
-- 效果：
-- ①：自己的通常怪兽和对方怪兽进行战斗的伤害步骤开始时，把手卡的这张卡给对方观看才能发动。选自己1张手卡丢弃，那只自己怪兽不会被那次战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时，把手卡1只通常怪兽给对方观看才能发动。选自己1张手卡丢弃，那只对方怪兽破坏。
function c11449436.initial_effect(c)
	-- 效果原文内容：①：自己的通常怪兽和对方怪兽进行战斗的伤害步骤开始时，把手卡的这张卡给对方观看才能发动。选自己1张手卡丢弃，那只自己怪兽不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11449436,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c11449436.indescon)
	e1:SetCost(c11449436.indescost)
	e1:SetTarget(c11449436.indestg)
	e1:SetOperation(c11449436.indesop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡和对方怪兽进行战斗的伤害步骤开始时，把手卡1只通常怪兽给对方观看才能发动。选自己1张手卡丢弃，那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11449436,1))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCost(c11449436.descost)
	e2:SetTarget(c11449436.destg)
	e2:SetOperation(c11449436.desop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否满足效果①的发动条件，即是否处于战斗状态且自己的怪兽为通常怪兽。
function c11449436.indescon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前正在战斗中的自己怪兽和对方怪兽。
	local a,d=Duel.GetBattleMonster(tp)
	e:SetLabelObject(a)
	return a and d and a:IsFaceup() and a:IsType(TYPE_NORMAL)
end
-- 规则层面作用：判断是否满足效果①的发动成本，即确认手卡的这张卡是否已经公开。
function c11449436.indescost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 规则层面作用：设置效果①的发动目标，检查是否满足发动条件并设置操作信息。
function c11449436.indestg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否满足发动条件，即自己手卡是否存在至少一张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：设置操作信息，表示将要处理的丢弃手卡效果。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 规则层面作用：定义效果①的处理流程，包括丢弃手卡和为怪兽添加不被战斗破坏的效果。
function c11449436.indesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=e:GetLabelObject()
	-- 规则层面作用：执行丢弃手卡操作并判断是否满足后续处理条件。
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 and a
		and a:IsRelateToBattle() and a:IsControler(tp) then
		-- 效果原文内容：那只自己怪兽不会被那次战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
	end
end
-- 规则层面作用：定义过滤函数，用于筛选手卡中未公开的通常怪兽。
function c11449436.cfilter(c)
	return c:IsType(TYPE_NORMAL) and not c:IsPublic()
end
-- 规则层面作用：判断是否满足效果②的发动成本，即是否手卡存在未公开的通常怪兽。
function c11449436.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否满足发动条件，即自己手卡是否存在至少一张未公开的通常怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c11449436.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：向玩家发送提示信息，提示选择要确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	-- 规则层面作用：选择一张未公开的通常怪兽进行确认。
	local g=Duel.SelectMatchingCard(tp,c11449436.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 规则层面作用：向对方玩家确认所选的卡。
	Duel.ConfirmCards(1-tp,g)
	-- 规则层面作用：将自己的手卡进行洗牌处理。
	Duel.ShuffleHand(tp)
end
-- 规则层面作用：设置效果②的发动目标，检查是否满足发动条件并设置操作信息。
function c11449436.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(tc)
	-- 规则层面作用：检查是否满足发动条件，即对方怪兽存在且自己手卡存在至少一张卡。
	if chk==0 then return tc and tc:IsControler(1-tp) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 规则层面作用：设置操作信息，表示将要处理的丢弃手卡效果。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 规则层面作用：设置操作信息，表示将要处理的破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 规则层面作用：定义效果②的处理流程，包括丢弃手卡和破坏对方怪兽。
function c11449436.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：执行丢弃手卡操作并判断是否满足后续处理条件。
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
		local tc=e:GetLabelObject()
		if tc and tc:IsRelateToBattle() and tc:IsControler(1-tp) then
			-- 规则层面作用：破坏对方怪兽。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
