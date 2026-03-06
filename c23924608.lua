--砂塵の大嵐
-- 效果：
-- 这张卡发动的回合，自己不能进行战斗阶段。
-- ①：以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
function c23924608.initial_effect(c)
	-- 效果原文内容：这张卡发动的回合，自己不能进行战斗阶段。
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
-- 效果作用：检查是否在发动回合进入过战斗阶段，若未进入则设置不能进入战斗阶段的效果
function c23924608.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否在该玩家的战斗阶段中已经进行过活动
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 效果原文内容：①：以场上最多2张魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将不能进入战斗阶段的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：处理选择对象的函数，设置选择目标的条件
function c23924608.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) and chkc~=e:GetHandler() end
	-- 效果作用：判断场上是否存在满足条件的魔法·陷阱卡作为目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),TYPE_SPELL+TYPE_TRAP) end
	-- 效果作用：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择场上1~2张魔法·陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
	-- 效果作用：设置连锁操作信息，确定破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果作用：处理效果发动后的主要破坏操作
function c23924608.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中确定的目标卡组，并筛选出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 效果作用：以效果原因将目标卡组破坏
	Duel.Destroy(g,REASON_EFFECT)
end
