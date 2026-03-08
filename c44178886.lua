--ライトロード・モンク エイリン
-- 效果：
-- ①：这张卡向守备表示怪兽攻击的伤害计算前发动。那只怪兽回到持有者卡组。
-- ②：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
function c44178886.initial_effect(c)
	-- 效果原文：①：这张卡向守备表示怪兽攻击的伤害计算前发动。那只怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44178886,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetTarget(c44178886.targ)
	e1:SetOperation(c44178886.op)
	c:RegisterEffect(e1)
	-- 效果原文：②：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetDescription(aux.Stringid(44178886,1))  --"从卡组送3张卡去墓地"
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c44178886.discon)
	e2:SetTarget(c44178886.distg)
	e2:SetOperation(c44178886.disop)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果发动条件：攻击怪兽是自身且攻击目标存在且为守备表示且可以送入卡组
function c44178886.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前战斗中攻击方的防守怪兽
	local t=Duel.GetAttackTarget()
	-- 检查是否满足发动条件：攻击怪兽是自身且攻击目标存在且为守备表示且可以送入卡组
	if chk==0 then return Duel.GetAttacker()==e:GetHandler() and t~=nil and not t:IsAttackPos() and t:IsAbleToDeck() end
	-- 设置连锁操作信息：将目标怪兽送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,t,1,0,0)
end
-- 效果处理函数：将攻击目标怪兽送回卡组
function c44178886.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中攻击方的防守怪兽
	local t=Duel.GetAttackTarget()
	if t~=nil and t:IsRelateToBattle() and not t:IsAttackPos() then
		-- 将目标怪兽以效果原因送回卡组并洗牌
		Duel.SendtoDeck(t,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 结束阶段发动条件判断：当前回合玩家为自身
function c44178886.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自身
	return tp==Duel.GetTurnPlayer()
end
-- 设置结束阶段效果的处理信息：从卡组送3张卡去墓地
function c44178886.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：从卡组送3张卡去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 结束阶段效果处理函数：从卡组送3张卡去墓地
function c44178886.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身卡组最上面3张卡以效果原因送去墓地
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
