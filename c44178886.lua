--ライトロード・モンク エイリン
-- 效果：
-- ①：这张卡向守备表示怪兽攻击的伤害计算前发动。那只怪兽回到持有者卡组。
-- ②：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
function c44178886.initial_effect(c)
	-- ①：这张卡向守备表示怪兽攻击的伤害计算前发动。那只怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44178886,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_CONFIRM)
	e1:SetTarget(c44178886.targ)
	e1:SetOperation(c44178886.op)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段发动。从自己卡组上面把3张卡送去墓地。
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
-- 效果①的发动条件与对象判定函数：在伤害计算前，确认攻击者是此卡且攻击对象为守备表示并能回到卡组时允许发动，同时登记将该对象返回卡组的操作信息。
function c44178886.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取本次战斗的攻击对象（即这张卡所攻击的怪兽）。
	local t=Duel.GetAttackTarget()
	-- 发动条件判定：若在发动时点检查，要求当前攻击者是这张卡、攻击对象存在且不是攻击表示（即守备表示），并且该怪兽可以被返回卡组，全部满足才能发动。
	if chk==0 then return Duel.GetAttacker()==e:GetHandler() and t~=nil and not t:IsAttackPos() and t:IsAbleToDeck() end
	-- 设置操作信息：将确定要返回卡组的对象t登记为回卡组效果，数量为1，玩家与区域参数按对象实际归属处理。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,t,1,0,0)
end
-- 效果①处理函数：若攻击对象仍与本次战斗关联且仍为守备表示，则将其返回持有者卡组并洗牌。
function c44178886.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取伤害计算前确认的攻击对象（战斗时点保存的怪兽）。
	local t=Duel.GetAttackTarget()
	if t~=nil and t:IsRelateToBattle() and not t:IsAttackPos() then
		-- 将攻击对象返回持有者卡组，以弹回卡组并洗牌的方式处理，原因记为效果。
		Duel.SendtoDeck(t,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②的发动条件函数：判断当前是否为该效果控制者的结束阶段。
function c44178886.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 仅当当前回合玩家是效果控制者时条件成立，即自己结束阶段。
	return tp==Duel.GetTurnPlayer()
end
-- 效果②的发动目标判定函数：无额外发动条件限制，登记将从自己卡组上方把3张卡送去墓地的操作信息。
function c44178886.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理为卡组送墓效果，不指定具体卡片，数量为3，目标玩家为效果控制者，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果②的处理函数：从自己卡组上方把3张卡送去墓地。
function c44178886.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行从自己卡组上方丢弃3张卡送去墓地的动作，原因记为效果。
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
