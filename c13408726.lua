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
-- 初始化并注册该卡的全部效果：使其成为灵摆怪兽，设置只能通过仪式召唤特殊召唤的限制，并注册灵摆区的诱发除外效果、怪兽区的二速除外效果以及战斗破坏改为除外的永续效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 将这张卡作为灵摆怪兽处理，使其获得灵摆召唤和灵摆区域发动等能力。
	aux.EnablePendulumAttribute(c)
	-- 「影灵衣」仪式魔法卡降临 这张卡若非以只使用除9星以外的怪兽来作的仪式召唤则不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件：只有通过仪式召唤才能特殊召唤这张卡。
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己的「影灵衣」卡被表侧除外的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
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
	-- 这个卡名的①的怪兽效果1回合只能使用1次。①：自己·对方的主要阶段，以对方场上1只表侧表示怪兽为对象才能发动。这张卡直到结束阶段除外，作为对象的怪兽除外。
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
-- 仪式召唤素材过滤：等级9的怪兽不能作为这张卡的仪式召唤素材。
function s.mat_filter(c)
	return not c:IsLevel(9)
end
-- 判定一张被除外的卡是否满足条件：卡名属于「影灵衣」，且是被我方表侧除外、除外的控制者与我方相同。
function s.cfilter(c,tp)
	return c:IsFaceupEx() and c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsSetCard(0xb4)
end
-- 灵摆效果的发动条件：本次除外事件中存在我方表侧除外的「影灵衣」卡，且这张灵摆卡的效果处于有效状态。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 选择对象用过滤器：场上可以除外的魔法·陷阱卡。
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 灵摆效果发动时：从双方场上选择1张可以除外的魔法·陷阱卡作为对象，并登记此次除外处理信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rmfilter(chkc) end
	-- 发动前判定：双方场上是否存在至少1张可以除外的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方场上选择1张可以除外的魔法·陷阱卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 将选中的对象卡登记为效果处理时要被除外的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 灵摆效果处理：若对象卡仍与效果关联，将其表侧表示除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个效果对象（即被选择的魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 怪兽效果的发动条件：当前处于主要阶段。
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 仅当当前是主要阶段时，该速攻效果才能发动。
	return Duel.IsMainPhase()
end
-- 选择对象过滤器：对方场上的表侧表示且可以除外的怪兽。
function s.rmfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToRemove()
end
-- 速攻效果发动时：选择对方场上1只表侧表示可以除外的怪兽作为对象，同时将自身也加入对象组，并设置除外处理信息。
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return c:IsAbleToRemove() and chkc:IsOnField() and chkc:IsControler(1-tp) and s.rmfilter2(chkc) end
	-- 发动前判定：自身可以除外，且对方怪兽区有1只符合条件的表侧表示怪兽。
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingTarget(s.rmfilter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方怪兽区选择1只符合条件的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.rmfilter2,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选择的对象怪兽登记为除外处理对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 速攻效果处理：先检查并暂时除外自身；若成功，且选中的对象怪兽仍与效果关联，则将该对象怪兽除外；同时注册结束阶段将自身返回场上的效果。
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果对象怪兽（对方场上被选中的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断自身是否仍与效果关联且可以除外，若是则暂时除外自身；该除外操作成功（返回非0）才继续处理。
	if c:IsRelateToEffect(e) and c:IsAbleToRemove() and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		if c:GetOriginalCode()==id then
			-- 这张卡直到结束阶段除外，作为对象的怪兽除外。②：自己的「影灵衣」怪兽战斗破坏的怪兽不去墓地而除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetOperation(s.retop)
			-- 将结束阶段返回自身的效果注册到当前玩家，使这一暂时除外的处理能在结束阶段复原。
			Duel.RegisterEffect(e1,tp)
		end
		if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
			-- 将对象怪兽表侧表示除外。
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 结束阶段处理：将被暂时除外的这张卡返回场上。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行返回操作，将暂时除外的这张卡放回场上。
	Duel.ReturnToField(e:GetHandler())
end
-- 用于战斗破坏替代除外的过滤：判定怪兽是否为表侧表示且属于「影灵衣」系列。
function s.immtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0xb4)
end
