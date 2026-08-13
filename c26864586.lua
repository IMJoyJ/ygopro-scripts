--共振装置
-- 效果：
-- 选择自己场上表侧表示存在的2只相同种族·属性的怪兽发动。选择的1只怪兽的等级直到结束阶段时变成和另1只怪兽的等级相同。
function c26864586.initial_effect(c)
	-- 选择自己场上表侧表示存在的2只相同种族·属性的怪兽发动。选择的1只怪兽的等级直到结束阶段时变成和另1只怪兽的等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26864586.target)
	e1:SetOperation(c26864586.activate)
	c:RegisterEffect(e1)
end
-- 定义效果对象候选怪兽的过滤条件：该怪兽必须表侧表示、等级在1以上，并且能够成为当前效果的对象。
function c26864586.tgfilter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsCanBeEffectTarget(e)
end
-- 定义检查组g是否满足发动条件：g中所有怪兽的等级互不相同（aux.dlvcheck），且属性全部相同、种族全部相同。
function c26864586.gcheck(g)
	-- 返回所选2只怪兽是否满足等级互不相同、属性相同、种族相同的判定结果。
	return aux.dlvcheck(g) and aux.SameValueCheck(g,Card.GetAttribute) and aux.SameValueCheck(g,Card.GetRace)
end
-- 效果发动时的目标选择处理：在满足条件的怪兽中确认存在2只可选的怪兽后，提示玩家选择2只，并将其设为效果对象。
function c26864586.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有满足tgfilter条件（表侧表示、等级1以上、可成为对象）的怪兽集合。
	local g=Duel.GetMatchingGroup(c26864586.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c26864586.gcheck,2,2) end
	-- 给玩家显示“请选择效果的对象”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c26864586.gcheck,false,2,2)
	-- 将玩家选择的2只怪兽设置为当前连锁的效果对象，建立对象关联。
	Duel.SetTargetCard(tg)
end
-- 效果处理阶段：取得仍相关的2只对象怪兽，若怪兽仍表侧表示且二者等级不同，则让玩家选择1只等级要变化的怪兽，将另1只的等级赋予它直到结束阶段。
function c26864586.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中与效果仍相关的对象卡组，即发动时选择的2只怪兽（若仍满足相关条件）。
	local g=Duel.GetTargetsRelateToChain()
	if g:FilterCount(Card.IsFaceup,nil)<2 then return end
	if g:GetFirst():GetLevel()==g:GetNext():GetLevel() then return end
	-- 给玩家显示“请选择等级要变化的怪兽”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26864586,0))  --"请选择等级要变化的怪兽"
	local tc2=g:Select(tp,1,1,nil):GetFirst()
	local tc1=(g-tc2):GetFirst()
	local lv=tc1:GetLevel()
	-- 选择的1只怪兽的等级直到结束阶段时变成和另1只怪兽的等级相同。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc2:RegisterEffect(e1)
end
