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
-- 过滤函数，用于检查墓地是否存在名字带有「熔岩」且可除外的怪兽
function c14047624.cfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToRemoveAsCost()
end
-- 过滤函数，用于检查自己场上是否存在已攻击宣言过的「熔岩裁决王」
function c14047624.cfilter2(c)
	return c:IsCode(14047624) and c:GetAttackAnnouncedCount()>0
end
-- 效果的费用处理函数，用于判断是否满足发动条件并处理除外费用
function c14047624.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只名字带有「熔岩」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14047624.cfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查自己场上是否存在已攻击宣言过的「熔岩裁决王」
		and not Duel.IsExistingMatchingCard(c14047624.cfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1只满足条件的墓地怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,c14047624.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从游戏中除外作为效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 给与对方基本分1000分伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	-- 设置效果目标为「熔岩裁决王」自身
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,14047624))
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果的目标设定函数，用于设置伤害对象和伤害值
function c14047624.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁效果的操作信息为造成1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果的处理函数，用于执行伤害效果
function c14047624.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家和参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
