--ダーク・ダイブ・ボンバー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「暗黑俯冲轰炸机」的效果1回合只能使用1次。
-- ①：自己主要阶段1把自己场上1只怪兽解放才能发动。给与对方解放的怪兽的等级×200伤害。
function c32646477.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整（无条件限制）＋调整以外的怪兽1只以上，即通常同调召唤的素材要求。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 「暗黑俯冲轰炸机」的效果1回合只能使用1次。①：自己主要阶段1把自己场上1只怪兽解放才能发动。给与对方解放的怪兽的等级×200伤害。
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
-- 定义效果的发动条件函数：检测当前是否处于自己主要阶段1，只有在此阶段才能发动效果。
function c32646477.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1，作为效果发动条件的判定。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 定义效果的发动代价函数：从自己场上选择1只等级≥1的怪兽解放，并根据其等级计算伤害值（等级×200）暂存到效果标签中。
function c32646477.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）：检查自己场上是否存在至少1只等级≥1且可解放的怪兽，用于判定能否支付代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsLevelAbove,1,nil,1) end
	-- 让玩家从自己场上选择1只等级≥1且可解放的怪兽，作为解放的代价对象。
	local g=Duel.SelectReleaseGroup(tp,Card.IsLevelAbove,1,1,nil,1)
	e:SetLabel(g:GetFirst():GetLevel()*200)
	-- 将选择的怪兽解放（REASON_COST），完成代价支付。
	Duel.Release(g,REASON_COST)
end
-- 定义效果发动时的目标设定函数：以对方玩家为伤害对象，设置伤害数值，并登记效果处理时的伤害信息。
function c32646477.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设置为对方（1-tp），表示给与对方伤害。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的对象参数设置为之前暂存的伤害值（解放怪兽等级×200），供后续效果处理使用。
	Duel.SetTargetParam(e:GetLabel())
	-- 登记操作信息：效果将对对方玩家造成e:GetLabel()点伤害，伤害分类为CATEGORY_DAMAGE，以便其他卡响应。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
	e:SetLabel(0)
end
-- 定义效果处理函数：取得之前设定的对象玩家和伤害数值，并对该玩家造成伤害。
function c32646477.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和伤害参数，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）对玩家p造成d点伤害，即解放怪兽等级×200的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
