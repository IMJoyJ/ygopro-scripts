--C・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 可以把自己墓地存在的名字带有「链」的怪兽全部从游戏中除外。这个效果每除外1只怪兽，这张卡的攻击力直到这个回合的结束阶段时上升200。每次这张卡给与对方基本分战斗伤害，从对方卡组上面把3张卡送去墓地。
function c19974580.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只任意调整（调整）＋调整以外的怪兽1只以上（任意非调整）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 可以把自己墓地存在的名字带有「链」的怪兽全部从游戏中除外。这个效果每除外1只怪兽，这张卡的攻击力直到这个回合的结束阶段时上升200。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(19974580,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c19974580.attg)
	e1:SetOperation(c19974580.atop)
	c:RegisterEffect(e1)
	-- 每次这张卡给与对方基本分战斗伤害，从对方卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19974580,1))  --"卡组上面3张卡送去墓地"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c19974580.ddcon)
	e2:SetTarget(c19974580.ddtg)
	e2:SetOperation(c19974580.ddop)
	c:RegisterEffect(e2)
end
-- 定义过滤器：筛选卡名带有「链」（0x25）且可以被除外的卡。
function c19974580.rfilter(c)
	return c:IsSetCard(0x25) and c:IsAbleToRemove()
end
-- 起动效果的目标设定：先检查自己墓地是否存在至少1张可除外的「链」怪兽；若存在，则取得所有满足条件的「链」怪兽，并将本次连锁的除外操作信息登记为全部这些卡。
function c19974580.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：自己墓地存在至少1张满足 rfilter（卡名带有「链」且可除外）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c19974580.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 取得自己墓地中所有满足 rfilter 条件的「链」怪兽集合。
	local g=Duel.GetMatchingGroup(c19974580.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 设置本次连锁的操作信息：将上述「链」怪兽集合作为除外对象，数量为其张数，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：先确认此卡仍与效果关联且不是里侧表示；然后重新获取自己墓地中所有可除外的「链」怪兽，将它们全部表侧除外；若除外数量大于0，则给此卡设置一个攻击力上升效果，上升值＝除外数量×200，持续到结束阶段。
function c19974580.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 效果处理时重新获取当前墓地中所有满足条件的「链」怪兽，以处理时实际存在的卡为准。
	local g=Duel.GetMatchingGroup(c19974580.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 以效果原因将 g 中的所有「链」怪兽以表侧表示除外，并返回实际被除外的数量。
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if ct>0 then
		-- 这个效果每除外1只怪兽，这张卡的攻击力直到这个回合的结束阶段时上升200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 触发条件：此卡给与对方基本分战斗伤害，即受到伤害的玩家 ep 不是己方 tp。
function c19974580.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 诱发效果的发动目标：无需额外条件直接通过；同时设置连锁操作信息，表明将把对方卡组最上方3张卡送去墓地（CATEGORY_DECKDES）。
function c19974580.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：从对方（1-tp）卡组最上方把3张卡送去墓地（CATEGORY_DECKDES），用于连锁检测和效果处理。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,3)
end
-- 效果处理：将对方卡组最上方3张卡以效果原因送去墓地。
function c19974580.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因把对方（1-tp）卡组最上方3张卡送去墓地。
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
end
