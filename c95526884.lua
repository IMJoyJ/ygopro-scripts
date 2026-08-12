--ハイパーサイコガンナー
-- 效果：
-- 调整＋调整以外的念动力族怪兽1只以上
-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。此外，这张卡向守备表示怪兽攻击的伤害步骤结束时，若攻击力超过那个守备力，自己基本分回复那个数值。
function c95526884.initial_effect(c)
	-- 设定同调召唤手续：调整＋调整以外的念动力族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_PSYCHO),1)
	c:EnableReviveLimit()
	-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- 此外，这张卡向守备表示怪兽攻击的伤害步骤结束时，若攻击力超过那个守备力，自己基本分回复那个数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95526884,0))  --"回复LP"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c95526884.reccon)
	e2:SetTarget(c95526884.rectg)
	e2:SetOperation(c95526884.recop)
	c:RegisterEffect(e2)
end
-- 伤害步骤结束时回复LP效果的发动条件判定：自身作为攻击者攻击守备表示怪兽，且攻击力超过其守备力
function c95526884.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	local m=a:GetAttack()-d:GetDefense()
	e:SetLabel(m)
	-- 判定是否满足：伤害步骤结束时自身仍在场或因战斗破坏、自身是攻击怪兽、被攻击怪兽存在守备力、攻击力差值大于0且被攻击怪兽为守备表示
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and c==a and d:GetDefense()>=0 and m>0 and bit.band(d:GetBattlePosition(),POS_DEFENSE)~=0
end
-- 伤害步骤结束时回复LP效果的发动准备（设置回复对象玩家、回复数值及操作信息）
function c95526884.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 将之前计算并保存在Label中的攻击力与守备力差值设为效果的目标参数
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁操作信息为：自己回复与差值相同数值的生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
-- 伤害步骤结束时回复LP效果的执行：获取目标玩家和参数，执行回复生命值操作
function c95526884.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数（回复数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 依效果使目标玩家回复对应的生命值
	Duel.Recover(p,d,REASON_EFFECT)
end
