--幻奏の音姫マイスタリン・シューベルト
-- 效果：
-- 「幻奏」怪兽×2
-- ①：只在这张卡在场上表侧表示存在才有1次，以双方墓地的卡合计最多3张为对象才能发动。那些卡除外。这张卡的攻击力上升这个效果除外的卡数量×200。这个效果在对方回合也能发动。
function c57594700.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要2只「幻奏」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x9b),2,true)
	-- ①：只在这张卡在场上表侧表示存在才有1次，以双方墓地的卡合计最多3张为对象才能发动。那些卡除外。这张卡的攻击力上升这个效果除外的卡数量×200。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1)
	-- 设置发动条件为不在伤害计算后（限制在伤害步骤的伤害计算前才能发动）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c57594700.target)
	e1:SetOperation(c57594700.operation)
	c:RegisterEffect(e1)
end
-- 效果①的发动准备（检查是否满足发动条件、选择对象并设置操作信息）
function c57594700.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查双方墓地是否存在至少1张可以除外的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择双方墓地合计最多3张可以除外的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	-- 设置效果处理信息为将选中的卡从墓地除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果①的效果处理（除外目标卡片并增加攻击力）
function c57594700.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些卡表侧表示除外，并获取实际除外的卡片数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升这个效果除外的卡数量×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(ct*200)
		c:RegisterEffect(e1)
	end
end
