--メタトロンの影霊衣
-- 效果：
-- ←5 【灵摆】 5→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己的「影灵衣」卡被表侧除外的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
-- 【怪兽效果】
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除9星以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，以对方场上1只表侧表示怪兽为对象才能发动。这张卡直到结束阶段除外，作为对象的怪兽除外。
-- ②：自己的「影灵衣」怪兽战斗破坏的怪兽不去墓地而除外。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆属性
	aux.EnablePendulumAttribute(c)
	-- ①：自己的「影灵衣」卡被表侧除外的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置仪式召唤的条件过滤函数
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- ①：自己的「影灵衣」卡被表侧除外的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段，以对方场上1只表侧表示怪兽为对象才能发动。这张卡直到结束阶段除外，作为对象的怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e2:SetCondition(s.rmcon2)
	e2:SetTarget(s.rmtg2)
	e2:SetOperation(s.rmop2)
	c:RegisterEffect(e2)
	-- ②：自己的「影灵衣」怪兽战斗破坏的怪兽不去墓地而除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e3:SetValue(LOCATION_REMOVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.immtg)
	c:RegisterEffect(e3)
end
-- 判断怪兽是否为非9星的过滤函数
function s.mat_filter(c)
	return not c:IsLevel(9)
end
-- 判断被除外的卡是否为「影灵衣」卡的过滤函数
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsSetCard(0xb4)
end
-- 判断灵摆效果发动条件的函数
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 判断是否为可除外的魔法·陷阱卡的过滤函数
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 设置灵摆效果目标选择的函数
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rmfilter(chkc) end
	-- 判断灵摆效果是否可以发动
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择要除外的魔法·陷阱卡
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，告知将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行灵摆效果的函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断怪兽效果发动条件的函数
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 判断是否为可除外的怪兽的过滤函数
function s.rmfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToRemove()
end
-- 设置怪兽效果目标选择的函数
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return c:IsAbleToRemove() and chkc:IsOnField() and chkc:IsControler(1-tp) and s.rmfilter2(chkc) end
	-- 判断怪兽效果是否可以发动
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingTarget(s.rmfilter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的对方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择要除外的对方怪兽
	local g=Duel.SelectTarget(tp,s.rmfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置操作信息，告知将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行怪兽效果的函数
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断是否满足怪兽效果发动条件并执行除外操作
	if c:IsRelateToEffect(e) and c:IsAbleToRemove() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		if c:GetOriginalCode()==id then
			-- 设置结束阶段返回场上的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetOperation(s.retop)
			-- 注册效果到玩家
			Duel.RegisterEffect(e1,tp)
		end
		if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
			-- 将目标怪兽除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 返回场上的效果处理函数
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将卡返回到场上
	Duel.ReturnToField(e:GetHandler())
end
-- 判断是否为「影灵衣」怪兽的过滤函数
function s.immtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0xb4)
end
