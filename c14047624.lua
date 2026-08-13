--ラヴァルロード・ジャッジメント
-- 效果：
-- 1回合1次，把自己墓地存在的1只名字带有「熔岩」的怪兽从游戏中除外才能发动。给与对方基本分1000分伤害。这个效果发动的回合，「熔岩裁决王」不能攻击宣言。
function c14047624.initial_effect(c)
	-- 1回合1次，把自己墓地存在的1只名字带有「熔岩」的怪兽从游戏中除外才能发动。给与对方基本分1000分伤害。这个效果发动的回合，「熔岩裁决王」不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14047624,0))  --"给与对方1000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c14047624.damcost)
	e1:SetTarget(c14047624.damtg)
	e1:SetOperation(c14047624.damop)
	c:RegisterEffect(e1)
end
-- 过滤出墓地中满足名字带有「熔岩」且可以作为代价除外的怪兽。
function c14047624.cfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToRemoveAsCost()
end
-- 过滤出场上存在的卡号14047624且本回合已经进行过攻击宣言的「熔岩裁决王」。
function c14047624.cfilter2(c)
	return c:IsCode(14047624) and c:GetAttackAnnouncedCount()>0
end
-- 代价函数：在发动前确认墓地存在1只可除外的「熔岩」怪兽，且自己场上的「熔岩裁决王」本回合尚未攻击宣言。
function c14047624.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在至少1只满足条件的「熔岩」怪兽可以作为发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c14047624.cfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查自己场上不存在本回合已经进行过攻击宣言的「熔岩裁决王」，即本卡本回合未攻击过才能发动。
		and not Duel.IsExistingMatchingCard(c14047624.cfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示选择要除外的卡片的提示，提示类型为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只满足条件的「熔岩」怪兽。
	local g=Duel.SelectMatchingCard(tp,c14047624.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的「熔岩」怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 给与对方基本分1000分伤害。这个效果发动的回合，「熔岩裁决王」不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	-- 设置不能攻击宣言的效果只适用于卡号14047624的「熔岩裁决王」。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,14047624))
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能攻击宣言”的誓约效果注册到全场，在本回合结束前生效。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害效果的目标函数：该效果无需选择对象，记录对方玩家和伤害数值。
function c14047624.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为1000，即伤害数值。
	Duel.SetTargetParam(1000)
	-- 设置操作信息，标明本连锁将造成1000点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害效果的处理函数：实际执行给对方造成伤害。
function c14047624.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中读取记录的对象玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的方式给予对方玩家1000点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
