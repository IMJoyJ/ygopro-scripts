--破滅の儀式
-- 效果：
-- 「破灭之魔王 加兰道夫」的降临必需。必须从手卡·自己场上把等级合计直到7以上的怪兽解放。可以把自己墓地存在的这张卡从游戏中除外，这个回合自己场上表侧表示存在的仪式怪兽战斗破坏的怪兽不送去墓地回到卡组最上面。
function c52913738.initial_effect(c)
	-- 为这张卡添加仪式召唤效果，用于仪式召唤「破灭之魔王 加兰道夫」（30646525），要求解放的怪兽等级合计直到7以上，且允许超过仪式怪兽原本等级。
	aux.AddRitualProcGreaterCode(c,30646525)
	-- 可以把自己墓地存在的这张卡从游戏中除外，这个回合自己场上表侧表示存在的仪式怪兽战斗破坏的怪兽不送去墓地回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52913738,0))  --"仪式怪兽战斗破坏的怪兽返回卡组"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c52913738.regcon)
	-- 设置效果的发动代价为把墓地中的这张卡从游戏中除外（COST）。
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c52913738.regop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：该效果只能在主要阶段1发动。
function c52913738.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段1。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 效果处理：生成本回合内持续适用的效果，使自己场上表侧表示的仪式怪兽战斗破坏的怪兽不送去墓地而回到卡组最上面。
function c52913738.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合自己场上表侧表示存在的仪式怪兽战斗破坏的怪兽不送去墓地回到卡组最上面。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果只对自己场上表侧表示的仪式怪兽生效。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_RITUAL))
	e1:SetValue(LOCATION_DECK)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将战斗破坏转移效果注册到当前玩家场上，使其在回合内生效。
	Duel.RegisterEffect(e1,tp)
end
