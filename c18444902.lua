--タタカワナイト
-- 效果：
-- 对方的卡的效果让自己的魔法·陷阱卡的发动无效的场合，把这张卡从手卡送去墓地才能发动。给与对方基本分1500分伤害。
function c18444902.initial_effect(c)
	-- 创建效果，描述为LP伤害，分类为伤害效果，类型为场地区域诱发选发效果，属性为延迟效果和玩家目标效果，触发事件为连锁被无效，生效位置为手卡，条件为damcon，代价为damcost，目标为damtg，效果处理为damop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18444902,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_CHAIN_NEGATED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c18444902.damcon)
	e1:SetCost(c18444902.damcost)
	e1:SetTarget(c18444902.damtg)
	e1:SetOperation(c18444902.damop)
	c:RegisterEffect(e1)
end
-- 对方的卡的效果让自己的魔法·陷阱卡的发动无效的场合
function c18444902.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的效果和玩家
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	return de and dp~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp
end
-- 检查卡牌是否与效果相关且可以作为墓地代价
function c18444902.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		and e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置目标玩家为对方，目标参数为1500，操作信息为对对方造成1500伤害
function c18444902.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的目标参数为1500
	Duel.SetTargetParam(1500)
	-- 设置操作信息为对对方造成1500伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 获取目标玩家和参数并造成对应伤害
function c18444902.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
