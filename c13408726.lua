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
-- 初始化卡片效果，启用灵摆属性和仪式召唤限制
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆怪兽属性，允许灵摆召唤和灵摆卡发动
	aux.EnablePendulumAttribute(c)
	-- 设置卡片的特殊召唤条件为仪式召唤且不能使用9星怪兽
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置仪式召唤的过滤函数，限制只能使用非9星怪兽进行仪式召唤
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- 灵摆效果：当自己的「影灵衣」卡被除外时，可以除外场上一张魔法·陷阱卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"魔法·陷阱卡除外"
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
	-- 怪兽效果：在主要阶段可以除外对方场上一只怪兽，同时自己这张卡除外直到结束阶段
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"怪兽除外"
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
	-- 战斗破坏效果：自己「影灵衣」怪兽战斗破坏的怪兽不送去墓地而是除外
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e3:SetValue(LOCATION_REMOVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.immtg)
	c:RegisterEffect(e3)
end
-- 过滤器函数：判断怪兽是否不是9星
function s.mat_filter(c)
	return not c:IsLevel(9)
end
-- 过滤器函数：判断是否为表侧表示的「影灵衣」卡且之前属于该玩家
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsSetCard(0xb4)
end
-- 灵摆效果的发动条件：当有「影灵衣」卡被除外时触发
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 过滤器函数：判断是否为魔法·陷阱卡且可以除外
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 设置灵摆效果的目标选择函数，选择场上一张魔法·陷阱卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rmfilter(chkc) end
	-- 判断是否满足灵摆效果的目标选择条件
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一张魔法·陷阱卡作为除外对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行灵摆效果的操作，将目标卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以表侧表示形式除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 怪兽效果的发动条件：在主要阶段时可以发动
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 过滤器函数：判断是否为表侧表示的怪兽且可以除外
function s.rmfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToRemove()
end
-- 设置怪兽效果的目标选择函数，选择对方场上一只怪兽
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return c:IsAbleToRemove() and chkc:IsOnField() and chkc:IsControler(1-tp) and s.rmfilter2(chkc) end
	-- 判断是否满足怪兽效果的目标选择条件
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingTarget(s.rmfilter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上一只怪兽作为除外对象
	local g=Duel.SelectTarget(tp,s.rmfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置操作信息，表示将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行怪兽效果的操作，将自己和目标怪兽除外
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断是否满足怪兽效果的发动条件，包括自己可以除外且成功除外
	if c:IsRelateToEffect(e) and c:IsAbleToRemove() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		if c:GetOriginalCode()==id then
			-- 注册一个在结束阶段将自己返回场上的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetOperation(s.retop)
			-- 将效果注册到玩家环境中
			Duel.RegisterEffect(e1,tp)
		end
		if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
			-- 将目标怪兽以表侧表示形式除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 返回场上的效果处理函数
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己返回到场上
	Duel.ReturnToField(e:GetHandler())
end
-- 战斗破坏效果的目标过滤器，判断是否为「影灵衣」怪兽
function s.immtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0xb4)
end
