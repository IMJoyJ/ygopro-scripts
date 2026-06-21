--氷河のアクア・マドール
-- 效果：
-- ①：自己的通常怪兽和对方怪兽进行战斗的伤害步骤开始时，把手卡的这张卡给对方观看才能发动。选自己1张手卡丢弃，那只自己怪兽不会被那次战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时，把手卡1只通常怪兽给对方观看才能发动。选自己1张手卡丢弃，那只对方怪兽破坏。
function c11449436.initial_effect(c)
	-- ①：自己的通常怪兽和对方怪兽进行战斗的伤害步骤开始时，把手卡的这张卡给对方观看才能发动。选自己1张手卡丢弃，那只自己怪兽不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11449436,0))
	e1:SetCategory(CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c11449436.indescon)
	e1:SetCost(c11449436.indescost)
	e1:SetTarget(c11449436.indestg)
	e1:SetOperation(c11449436.indesop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时，把手卡1只通常怪兽给对方观看才能发动。选自己1张手卡丢弃，那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11449436,1))
	e2:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCost(c11449436.descost)
	e2:SetTarget(c11449436.destg)
	e2:SetOperation(c11449436.desop)
	c:RegisterEffect(e2)
end
-- 判断是否为自己的表侧表示通常怪兽与对方怪兽战斗，并保存自己怪兽的指针
function c11449436.indescon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取正在进行战斗的自己怪兽和对方怪兽
	local a,d=Duel.GetBattleMonster(tp)
	e:SetLabelObject(a)
	return a and d and a:IsFaceup() and a:IsType(TYPE_NORMAL)
end
-- 检查手牌中的这张卡是否处于非公开状态
function c11449436.indescost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检查自己手牌中是否存在可丢弃的卡，并设置丢弃自己手牌的操作信息
function c11449436.indestg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil) end
	-- 设置丢弃1张自己手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 丢弃1张自己手牌，并让参与战斗的己方怪兽在本次战斗中不会被战斗破坏
function c11449436.indesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=e:GetLabelObject()
	-- 若成功从自己手牌中丢弃1张卡，且存在战斗中的自己怪兽
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 and a
		and a:IsRelateToBattle() and a:IsControler(tp) then
		-- 那只自己怪兽不会被那次战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
	end
end
-- 筛选手牌中非公开的通常怪兽
function c11449436.cfilter(c)
	return c:IsType(TYPE_NORMAL) and not c:IsPublic()
end
-- 检查并选择手牌中1只通常怪兽给对方确认，然后洗牌
function c11449436.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在可供公开的通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11449436.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选择1张未公开的通常怪兽
	local g=Duel.SelectMatchingCard(tp,c11449436.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将所选择的卡展示给对手确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己手牌以重新打乱手牌顺序
	Duel.ShuffleHand(tp)
end
-- 确认战斗的对方怪兽及手牌数量，并设置丢弃自己手牌与破坏对方怪兽的操作信息
function c11449436.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(tc)
	-- 确认存在战斗的对方怪兽且自己手牌中至少有1张卡
	if chk==0 then return tc and tc:IsControler(1-tp) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 设置丢弃1张自己手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
	-- 设置破坏战斗中的对方怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 丢弃1张自己手牌，若战斗中的对方怪兽仍存在，则将其破坏
function c11449436.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功从自己手牌中丢弃1张卡
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
		local tc=e:GetLabelObject()
		if tc and tc:IsRelateToBattle() and tc:IsControler(1-tp) then
			-- 破坏该对方怪兽
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
