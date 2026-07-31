--魔導アーマー エグゼ
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤的回合不能进行攻击。在自己与对方的每1个准备阶段，从自己场上除去1个魔力指示物，如果不除去魔力指示物，则这张卡被破坏。
function c7180418.initial_effect(c)
	-- 初始化卡片效果：注册召唤·反转召唤·特殊召唤回合不能攻击的限制效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c7180418.atklimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 注册准备阶段维持Cost：准备阶段除去1个魔力指示物，否则此卡破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(c7180418.ccost)
	c:RegisterEffect(e4)
end
c7180418.mentioned_counter={
	[0x1]=true,
}
-- 攻击限制处理：为此卡注册本回合不能攻击的效果
function c7180418.atklimit(e,tp,eg,ep,ev,re,r,rp)
	-- 给此卡注册单体效果：本回合不能进行攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 准备阶段维持Cost处理：选择除去1个魔力指示物，若不除去则破坏自身
function c7180418.ccost(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有魔力指示物可除去，并询问玩家是否支付Cost
	if Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_COST) and Duel.SelectYesNo(tp,aux.Stringid(7180418,0)) then  --"是否要除去一个魔力指示物？"
		-- 从自己场上除去1个魔力指示物
		Duel.RemoveCounter(tp,1,0,0x1,1,REASON_COST)
	else
		-- 因无法或未支付Cost而破坏此卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
