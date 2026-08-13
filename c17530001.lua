--キューブン
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子。只要这只怪兽在场上表侧表示存在，双方不能把和出现的数目相同等级的怪兽召唤·特殊召唤。
function c17530001.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子。只要这只怪兽在场上表侧表示存在，双方不能把和出现的数目相同等级的怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17530001,0))
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c17530001.target)
	e1:SetOperation(c17530001.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判定：没有额外限制（chk==0时直接返回true），并登记本次操作属于骰子效果，供后续处理使用。
function c17530001.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁的操作信息设置为骰子效果，表示由当前玩家投1次骰子，使相关效果（如骰子类卡）能正确识别和响应。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理阶段：先确认发起效果的怪兽仍在场上且与效果保持关联，否则直接终止；然后掷1次骰子，并根据点数给自己赋予两个永续效果：双方不能召唤/特殊召唤该点数等级的怪兽，效果持续到这张卡离场等标准重置时机。
function c17530001.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 让当前玩家投掷1次骰子，得到点数dc（1-6），作为后续禁止召唤/特殊召唤的等级判定依据。
	local dc=Duel.TossDice(tp,1)
	-- 双方不能把和出现的数目相同等级的怪兽召唤（本段代码实现的是EFFECT_CANNOT_SUMMON召唤限制部分）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c17530001.tglimit)
	e1:SetLabel(dc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e2)
end
-- 限制效果的判定规则：若怪兽的等级与掷出的点数（保存在效果Label中）相同，则不能进行召唤或特殊召唤；该过滤函数同时用于召唤限制和特殊召唤限制。
function c17530001.tglimit(e,c)
	return c:IsLevel(e:GetLabel())
end
