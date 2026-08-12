--ブラッド・メフィスト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 对方的准备阶段时，可以给与对方基本分对方场上存在的卡每1张300分伤害。此外，对方把魔法·陷阱卡盖放时，给与对方基本分300分伤害。
function c30757396.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对方的准备阶段时，可以给与对方基本分对方场上存在的卡每1张300分伤害
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30757396,0))  --"给与对方伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c30757396.damcon)
	e1:SetTarget(c30757396.damtg)
	e1:SetOperation(c30757396.damop)
	c:RegisterEffect(e1)
	-- 对方把魔法·陷阱卡盖放时，给与对方基本分300分伤害
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30757396,0))  --"给与对方伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SSET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c30757396.damcon2)
	e2:SetTarget(c30757396.damtg2)
	e2:SetOperation(c30757396.damop2)
	c:RegisterEffect(e2)
end
-- 判断是否为对方的准备阶段
function c30757396.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确保当前回合玩家不是对方
	return tp~=Duel.GetTurnPlayer()
end
-- 计算对方场上存在的卡的数量并设置伤害值
function c30757396.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上存在的卡的数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if chk==0 then return ct>0 end
	-- 设置连锁的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的操作信息为对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 执行对对方造成伤害的操作
function c30757396.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取对方场上存在的卡的数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 对目标玩家造成伤害
	Duel.Damage(p,ct*300,REASON_EFFECT)
end
-- 判断是否有对方的魔法·陷阱卡被盖放
function c30757396.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 设置连锁的操作信息为对对方造成300点伤害
function c30757396.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的目标参数为300
	Duel.SetTargetParam(300)
	-- 设置连锁的操作信息为对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 执行对对方造成伤害的操作
function c30757396.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
