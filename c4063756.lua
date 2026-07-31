--幻獄神メディクリウス
local s,id,o=GetID()
-- 连接召唤手续添加，要求2~3个连接素材，且至少包含一个融合/同调/超量/连接类型的怪兽；启用特殊召唤限制；注册三个效果
function s.initial_effect(c)
	-- 为该卡添加连接召唤手续，要求2~3个连接素材，且至少包含一个融合/同调/超量/连接类型的怪兽
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	-- 效果1：起动效果，消耗1次发动次数，条件为该卡已连接怪兽数量≥1；目标为对方场上所有表侧表示怪兽；效果为使目标怪兽效果无效并将其攻击力变为一半
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.lmcon(1))
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- 效果2：永续效果，自身免疫对方发动的效果；条件为该卡已连接怪兽数量≥2；效果为免疫对方发动的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.lmcon(2))
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	-- 效果3：诱发即时效果，可在任意时点发动，消耗1次发动次数，条件为该卡已连接怪兽数量=3且当前回合玩家不是自己；目标为场上的所有卡；效果为将目标卡除外
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 连接素材检查函数，判断连接素材中是否包含融合/同调/超量/连接类型的怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
-- 连接数量条件函数，返回一个判断该卡已连接怪兽数量是否大于等于指定值的条件函数
function s.lmcon(ct)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetLinkedGroupCount()>=ct
	end
end
-- 效果1的目标选择函数，检查对方场上是否存在至少一张表侧表示怪兽；若存在则设置操作信息为使目标怪兽效果无效
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少一张表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有表侧表示怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息为使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果1的处理函数，对所有对方场上的表侧表示怪兽使效果无效并将其攻击力变为一半
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的所有表侧表示怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 遍历所有对方场上的表侧表示怪兽
	for tc in aux.Next(g) do
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建一个使目标怪兽效果无效的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 创建一个使目标怪兽效果无效的效果（持续到结束阶段）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 手动刷新场上卡牌的无效状态
	Duel.AdjustInstantly()
	-- 遍历所有对方场上的表侧表示怪兽
	for tc in aux.Next(g) do
		local atk=tc:GetAttack()
		-- 创建一个将目标怪兽攻击力变为一半的效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e3)
	end
end
-- 效果免疫过滤函数，判断是否为对方发动且已激活的效果
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end
-- 效果3的发动条件函数，判断该卡已连接怪兽数量=3且当前回合玩家不是自己
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroupCount()==3
		-- 判断当前回合玩家不是自己
		and Duel.GetTurnPlayer()~=tp
end
-- 效果3的目标选择函数，检查自身是否可以除外；若可以则设置操作信息为将场上的所有卡除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	-- 获取场上的所有卡组成的卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	g:AddCard(c)
	-- 设置操作信息为将目标卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 效果3的处理函数，将场上的所有卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上的所有卡组成的卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToChain() then g:AddCard(c) end
	-- 将目标卡除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
