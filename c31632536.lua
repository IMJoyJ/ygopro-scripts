--ラヴァル・ツインスレイヤー
-- 效果：
-- 调整＋调整以外的炎属性怪兽1只以上
-- 自己墓地存在的名字带有「熔岩」的怪兽数量让这张卡得到以下效果。
-- ●2只以上：这张卡向守备表示怪兽攻击的场合，只有1次可以继续攻击。
-- ●3只以上：这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c31632536.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整且1只以上调整以外的炎属性怪兽参与同调
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	-- ●2只以上：这张卡向守备表示怪兽攻击的场合，只有1次可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c31632536.caop1)
	c:RegisterEffect(e1)
	-- ●3只以上：这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetOperation(c31632536.caop2)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ●3只以上：这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetCondition(c31632536.pcon)
	c:RegisterEffect(e3)
end
-- 记录攻击卡是否为自身且攻击目标为守备表示怪兽
function c31632536.caop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if e:GetHandler()==a and d and d:IsDefensePos() then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 在伤害步骤结束时判断是否满足连续攻击条件并执行连续攻击
function c31632536.caop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==1 and c:IsRelateToBattle() and c:IsChainAttackable()
		-- 判断自己墓地存在的名字带有「熔岩」的怪兽数量是否不少于2只
		and Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39)>=2 then
		-- 使攻击卡可以再进行1次攻击
		Duel.ChainAttack()
	end
end
-- 判断自己墓地存在的名字带有「熔岩」的怪兽数量是否不少于3只
function c31632536.pcon(e)
	-- 判断自己墓地存在的名字带有「熔岩」的怪兽数量是否不少于3只
	return Duel.GetMatchingGroupCount(Card.IsSetCard,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil,0x39)>=3
end
