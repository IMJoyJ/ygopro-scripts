--砂塵の大嵐
-- 效果：
-- 这张卡发动的回合，自己不能进行战斗阶段。
-- ①：以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
function c23924608.initial_effect(c)
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetCost(c23924608.cost)
	e1:SetTarget(c23924608.target)
	e1:SetOperation(c23924608.activate)
	c:RegisterEffect(e1)
end
-- 检查发动代价：己方本回合没有进行过战斗阶段，然后给自己附加本回合不能进行战斗阶段的誓约效果。
function c23924608.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：仅当己方本回合尚未进行过战斗阶段时才允许发动此卡。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 这张卡发动的回合，自己不能进行战斗阶段。①：以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述‘不能进行战斗阶段’的效果作为誓约效果注册给己方玩家，使该效果在本回合剩余时间内持续适用。
	Duel.RegisterEffect(e1,tp)
end
-- 发动时的取对象处理：选择场上除自身以外的最多2张魔法·陷阱卡作为对象，并设置对应的破坏操作信息。
function c23924608.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) and chkc~=e:GetHandler() end
	-- 检查是否满足发动条件：场上存在至少1张除本卡以外的魔法·陷阱卡可供选择作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),TYPE_SPELL+TYPE_TRAP) end
	-- 向操作玩家显示‘请选择要破坏的卡’的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作玩家从场上选择1～2张除本卡以外的魔法·陷阱卡作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
	-- 设置本连锁的破坏信息，通知系统这些对象已被确定为将被效果破坏，用于后续的时点与效果判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：获取连锁处理时的对象卡，并对其执行破坏处理。
function c23924608.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出取对象阶段选择的卡，并仅保留仍与该效果存在关联的卡（即未被离场或效果重置中断联系的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因破坏过滤后剩余的对象卡。
	Duel.Destroy(g,REASON_EFFECT)
end
