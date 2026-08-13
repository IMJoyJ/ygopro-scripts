--モアイ迎撃砲
-- 效果：
-- 这张卡1个回合1次可以变成里侧守备表示。
function c45159319.initial_effect(c)
	-- 这张卡1个回合1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45159319,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c45159319.target)
	e1:SetOperation(c45159319.operation)
	c:RegisterEffect(e1)
end
-- 作为起动效果发动时，判定条件：此卡在主要怪兽区表侧表示且本回合尚未使用过该效果（通过专属标记45159319检查）；满足条件后注册一个本回合使用次数的标记，并设置操作信息为改变表示形式，以便后续处理及连锁响应。
function c45159319.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(45159319)==0 end
	c:RegisterFlagEffect(45159319,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 向系统登记本次连锁的操作信息：将进行变更表示形式的处理，对象为这张卡，数量为1，以此供其他效果（如星尘龙等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理时，若这张卡仍在场上且与发动时的效果保持关联，并且处于表侧表示，则将其变更为里侧守备表示；若已离场或已变成里侧则不处理。
function c45159319.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 实际执行表示形式变更，将这张怪兽从当前表示形式改为里侧守备表示，并触发相应的时点判定。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
