--地獄詩人ヘルポエマー
-- 效果：
-- 这张卡不能作从墓地的特殊召唤。
-- ①：被战斗破坏的这张卡在墓地存在的场合，对方战斗阶段结束时发动。这张卡在墓地存在的场合，对方手卡随机选1张丢弃。
function c76052811.initial_effect(c)
	-- 这张卡不能作从墓地的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 被战斗破坏的这张卡在墓地存在的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetOperation(c76052811.regop)
	c:RegisterEffect(e2)
	-- 对方战斗阶段结束时发动。这张卡在墓地存在的场合，对方手卡随机选1张丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76052811,0))  --"丢弃手牌"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c76052811.hdcon)
	e3:SetTarget(c76052811.hdtg)
	e3:SetOperation(c76052811.hdop)
	c:RegisterEffect(e3)
end
-- 注册被战斗破坏事件的辅助效果，若在墓地且因战斗破坏则给自身添加Flag标记
function c76052811.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) then
		c:RegisterFlagEffect(76052811,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
-- 发动条件：对方回合的战斗阶段结束时，且自身带有被战斗破坏的Flag标记
function c76052811.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是对方，且自身具有被战斗破坏的Flag标记
	return Duel.GetTurnPlayer()~=tp and e:GetHandler():GetFlagEffect(76052811)~=0
end
-- 效果发动的目标：设置丢弃对方手牌的操作信息
function c76052811.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为对方丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 效果处理：若此卡仍在墓地，则随机选择对方1张手牌丢弃
function c76052811.hdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 获取对方的手牌卡片组
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if g:GetCount()==0 then return end
		local sg=g:RandomSelect(1-tp,1)
		-- 将随机选出的手牌以效果丢弃的方式送去墓地
		Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
	end
end
