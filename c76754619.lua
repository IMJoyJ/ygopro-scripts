--ピラミッドパワー
-- 效果：
-- 选择下面的1个效果发动。
-- ●自己的场上全部表侧表示存在的怪兽直到回合结束前攻击力上升200。
-- ●自己的场上全部表侧表示存在的怪兽直到回合结束前守备力上升500。
function c76754619.initial_effect(c)
	-- 选择下面的1个效果发动。●自己的场上全部表侧表示存在的怪兽直到回合结束前攻击力上升200。●自己的场上全部表侧表示存在的怪兽直到回合结束前守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤中伤害计算前（利用aux.dscon辅助函数）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c76754619.target)
	e1:SetOperation(c76754619.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的靶向与分支选择处理，确认场上有表侧怪兽并让玩家选择发动哪个分支效果
function c76754619.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件，检查自己场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 让玩家选择其中一个效果分支（攻击力上升200 或 守备力上升500），并将选择结果记录在Label中
	local op=Duel.SelectOption(tp,aux.Stringid(76754619,0),aux.Stringid(76754619,1))  --"攻击力上升200/守备力上升500"
	e:SetLabel(op)
end
-- 效果处理核心逻辑，获取自己场上所有表侧表示怪兽，并根据之前选择的分支分别适用攻击力上升或守备力上升的效果
function c76754619.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==0 then return end
	if e:GetLabel()==0 then
		local sc=g:GetFirst()
		while sc do
			-- ●自己的场上全部表侧表示存在的怪兽直到回合结束前攻击力上升200。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(200)
			sc:RegisterEffect(e1)
			sc=g:GetNext()
		end
	else
		local sc=g:GetFirst()
		while sc do
			-- ●自己的场上全部表侧表示存在的怪兽直到回合结束前守备力上升500。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_DEFENSE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(500)
			sc:RegisterEffect(e1)
			sc=g:GetNext()
		end
	end
end
