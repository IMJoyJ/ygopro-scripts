--破滅の儀式
-- 效果：
-- 「破灭之魔王 加兰道夫」的降临必需。必须从手卡·自己场上把等级合计直到7以上的怪兽解放。可以把自己墓地存在的这张卡从游戏中除外，这个回合自己场上表侧表示存在的仪式怪兽战斗破坏的怪兽不送去墓地回到卡组最上面。
function c52913738.initial_effect(c)
	-- 为卡片添加等级合计超过仪式怪兽原本等级的仪式召唤效果，仪式怪兽为破灭之魔王加兰道夫
	aux.AddRitualProcGreaterCode(c,30646525)
	-- 设置效果为起动效果，只能在墓地发动，条件为回合主要阶段1，费用为将自己场上一张卡除外，效果为使自己场上的仪式怪兽战斗破坏的怪兽不送去墓地而是回到卡组最上面
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52913738,0))  --"仪式怪兽战斗破坏的怪兽返回卡组"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c52913738.regcon)
	-- 设置效果的发动费用为将此卡从游戏中除外
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c52913738.regop)
	c:RegisterEffect(e1)
end
-- 判断当前是否处于主要阶段1
function c52913738.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前阶段是主要阶段1则效果可以发动
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 创建一个影响全场的永续效果，使仪式怪兽战斗破坏的怪兽不送去墓地而是回到卡组最上面
function c52913738.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置该效果为影响全场（EFFECT_TYPE_FIELD）的效果，当怪兽战斗破坏时重新指定去向（EFFECT_BATTLE_DESTROY_REDIRECT），目标为我方场上所有仪式怪兽，返回位置为卡组最上面
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果的目标为类型为仪式的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_RITUAL))
	e1:SetValue(LOCATION_DECK)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
