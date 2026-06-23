--磨破羅魏
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。此外，这张卡召唤·反转时发动。下次的自己的抽卡阶段的抽卡前把自己卡组最上面的卡确认再回到卡组最上面或者最下面。
function c40695128.initial_effect(c)
	-- 为该卡添加在召唤或反转时回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 下次的自己的抽卡阶段的抽卡前把自己卡组最上面的卡确认再回到卡组最上面或者最下面
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
-- 注册效果，用于在抽卡阶段前触发确认并移动卡组最上方的卡
function c40695128.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否已使用过该效果，避免重复触发
	if Duel.GetFlagEffect(tp,40695128)~=0 then return end
	-- 创建一个在抽卡阶段前触发的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(c40695128.condition)
	e1:SetOperation(c40695128.operation)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,1)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个标识效果，用于标记该效果已使用
	Duel.RegisterFlagEffect(tp,40695128,RESET_PHASE+PHASE_END,0,2)
end
-- 判断是否为当前回合玩家且卡组不为空
function c40695128.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家且卡组有卡
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end
-- 执行抽卡阶段前的确认与选择操作
function c40695128.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	-- 确认玩家卡组最上方的卡
	Duel.ConfirmCards(tp,g)
	local tc=g:GetFirst()
	-- 让玩家选择将卡放回卡组最上面或最下面
	local opt=Duel.SelectOption(tp,aux.Stringid(40695128,2),aux.Stringid(40695128,3))  --"放回卡组最上面/放回卡组最下面"
	if opt==1 then
		-- 根据选择将卡移动到卡组最上面或最下面
		Duel.MoveSequence(tc,opt)
	end
end
