--ダーク・ダイブ・ボンバー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「暗黑俯冲轰炸机」的效果1回合只能使用1次。
-- ①：自己主要阶段1把自己场上1只怪兽解放才能发动。给与对方解放的怪兽的等级×200伤害。
function c32646477.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调召唤
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：自己主要阶段1把自己场上1只怪兽解放才能发动。给与对方解放的怪兽的等级×200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32646477,0))  --"伤害"
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,32646477)
	e1:SetCondition(c32646477.condition)
	e1:SetCost(c32646477.cost)
	e1:SetTarget(c32646477.target)
	e1:SetOperation(c32646477.operation)
	c:RegisterEffect(e1)
end
-- 判断是否处于主要阶段1
function c32646477.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 支付效果代价，检查并选择1只可解放的怪兽
function c32646477.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张满足条件的可解放的卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsLevelAbove,1,nil,1) end
	-- 从场上选择1张满足条件的可解放的卡
	local g=Duel.SelectReleaseGroup(tp,Card.IsLevelAbove,1,1,nil,1)
	e:SetLabel(g:GetFirst():GetLevel()*200)
	-- 以代价原因解放所选的怪兽
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标玩家和伤害值
function c32646477.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为伤害值
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁效果的操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
	e:SetLabel(0)
end
-- 执行效果的处理，对目标玩家造成指定伤害
function c32646477.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
