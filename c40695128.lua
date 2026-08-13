--磨破羅魏
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。此外，这张卡召唤·反转时发动。下次的自己的抽卡阶段的抽卡前把自己卡组最上面的卡确认再回到卡组最上面或者最下面。
function c40695128.initial_effect(c)
	-- 为这张卡添加灵魂怪兽的返回手卡效果：在它被召唤或反转的回合的结束阶段时，若仍在自己场上则回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的效果值设为 false，使这张卡永远不允许被特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 此外，这张卡召唤·反转时发动。下次的自己的抽卡阶段的抽卡前把自己卡组最上面的卡确认再回到卡组最上面或者最下面。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(40695128,1))  --"确认卡"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c40695128.regop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
-- 这是召唤·反转时发动的诱发效果的处理操作：若该玩家尚未拥有对应标志，则注册一个在下次自己的抽卡阶段抽卡前执行的持续效果，并登记同名效果标志，从而在抽卡前确认卡组顶并选择放回上/下方。
function c40695128.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否已存在该效果的标志；若已有，说明本系列效果已经发动过，直接结束，避免重复注册抽卡前效果。
	if Duel.GetFlagEffect(tp,40695128)~=0 then return end
	-- 下次的自己的抽卡阶段的抽卡前把自己卡组最上面的卡确认再回到卡组最上面或者最下面。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(c40695128.condition)
	e1:SetOperation(c40695128.operation)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,1)
	-- 将新创建的持续效果注册给玩家tp，使其作为全场效果监听抽卡阶段的事件，用于在下次自己的抽卡阶段抽卡前触发。
	Duel.RegisterEffect(e1,tp)
	-- 给玩家tp登记该效果已发动的标志，并设置其在第2个结束阶段后自动清除，用于防止同一回合内因多次召唤/反转而重复发动。
	Duel.RegisterFlagEffect(tp,40695128,RESET_PHASE+PHASE_END,0,2)
end
-- 该持续效果的发动条件：必须是该效果的持有者tp的当前回合（即自己的抽卡阶段），且自己卡组中至少有1张卡。
function c40695128.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足为自己的抽卡阶段并且卡组不为空。
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end
-- 该效果的实际处理：确认自己卡组最上方1张卡，由玩家选择将其放回卡组最上面或最下面；若选择最下面则执行移动。
function c40695128.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得tp卡组最上方的1张卡，存入卡片组g。
	local g=Duel.GetDecktopGroup(tp,1)
	-- 将取出的卡组顶卡展示给tp确认。
	Duel.ConfirmCards(tp,g)
	local tc=g:GetFirst()
	-- 让tp选择放回的位置：0代表放回卡组最上面，1代表放回卡组最下面；返回所选序号作为opt。
	local opt=Duel.SelectOption(tp,aux.Stringid(40695128,2),aux.Stringid(40695128,3))  --"放回卡组最上面/放回卡组最下面"
	if opt==1 then
		-- 将这张卡移动到卡组最下面（opt为1时执行；opt为0时放回最上面，不需要额外移动）。
		Duel.MoveSequence(tc,opt)
	end
end
