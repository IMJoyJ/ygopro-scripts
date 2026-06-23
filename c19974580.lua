--C・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 可以把自己墓地存在的名字带有「链」的怪兽全部从游戏中除外。这个效果每除外1只怪兽，这张卡的攻击力直到这个回合的结束阶段时上升200。每次这张卡给与对方基本分战斗伤害，从对方卡组上面把3张卡送去墓地。
function c19974580.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 可以把把自己墓地存在的名字带有「链」的怪兽全部从游戏中除外。这个效果每除外1只怪兽，这张卡的攻击力直到这个回合的结束阶段时上升200。
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
-- 过滤函数，用于筛选墓地里名字带有「链」且可以除外的怪兽
function c19974580.rfilter(c)
	return c:IsSetCard(0x25) and c:IsAbleToRemove()
end
-- 效果处理时检查是否满足条件，若满足则检索满足条件的卡片组并设置操作信息
function c19974580.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以自己来看的墓地是否存在至少1张名字带有「链」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c19974580.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取以自己来看的墓地满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c19974580.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 设置操作信息，表示将要除外这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理函数，将满足条件的怪兽从墓地除外，并根据除外数量提升攻击力
function c19974580.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取以自己来看的墓地满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c19974580.rfilter,tp,LOCATION_GRAVE,0,nil)
	-- 将满足条件的怪兽从游戏中除外，返回实际除外的数量
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	if ct>0 then
		-- 创建一个攻击力提升效果，提升值为除外怪兽数量乘以200，并在结束阶段重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 战斗伤害发动时的触发条件，确保是对方造成的伤害
function c19974580.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果处理时设置操作信息，表示将要从对方卡组上面送去墓地3张卡
function c19974580.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要从对方卡组上面送去墓地3张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,3)
end
-- 效果处理函数，将对方卡组最上面3张卡送去墓地
function c19974580.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组最上面3张卡送去墓地
	Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
end
