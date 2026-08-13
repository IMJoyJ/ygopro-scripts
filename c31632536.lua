--ラヴァル・ツインスレイヤー
-- 效果：
-- 调整＋调整以外的炎属性怪兽1只以上
-- 自己墓地存在的名字带有「熔岩」的怪兽数量让这张卡得到以下效果。
-- ●2只以上：这张卡向守备表示怪兽攻击的场合，只有1次可以继续攻击。
-- ●3只以上：这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c31632536.initial_effect(c)
	-- 为这张卡添加同调召唤手续：1只任意调整＋1只以上调整以外的炎属性怪兽，即满足『调整＋调整以外的炎属性怪兽1只以上』的召唤条件。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	-- ●2只以上：这张卡向守备表示怪兽攻击的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c31632536.caop1)
	c:RegisterEffect(e1)
	-- 只有1次可以继续攻击。
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
-- 在伤害计算后确认本次战斗的攻击怪兽是否为本卡、攻击对象是否存在且为守备表示，并将结果记录到e1的标签中，供后续连续攻击判定使用。
function c31632536.caop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得当前战斗的攻击对象（被攻击的怪兽）；直接攻击时该值为nil。
	local d=Duel.GetAttackTarget()
	if e:GetHandler()==a and d and d:IsDefensePos() then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 在伤害步骤结束时，若e1标记本卡攻击过守备表示怪兽、本卡仍与本次战斗关联且满足连续攻击条件，并且自己墓地名字带有「熔岩」的怪兽在2只以上，则执行连续攻击。
function c31632536.caop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==1 and c:IsRelateToBattle() and c:IsChainAttackable()
		-- 检查自己墓地中名字带有「熔岩」的怪兽数量是否不少于2只，作为●2只以上效果的发动条件。
		and Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39)>=2 then
		-- 让本卡进行连续攻击（仅限1次追加攻击）。
		Duel.ChainAttack()
	end
end
-- 若自己墓地中名字带有「熔岩」的怪兽数量不少于3只，则本卡获得贯穿伤害效果；攻击守备表示怪兽时，攻击力超过守备力的数值会对对方基本分造成战斗伤害。
function c31632536.pcon(e)
	-- 统计自己墓地中名字带有「熔岩」的怪兽数量，并判断是否达到3只以上。
	return Duel.GetMatchingGroupCount(Card.IsSetCard,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil,0x39)>=3
end
