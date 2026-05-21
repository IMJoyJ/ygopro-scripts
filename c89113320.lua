--EMビッグバイトタートル
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，自己主要阶段才能发动。手卡1只「娱乐伙伴」怪兽或者「异色眼」怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
-- 【怪兽效果】
-- ①：这张卡被战斗破坏时才能发动。把让这张卡破坏的怪兽破坏。
function c89113320.initial_effect(c)
	-- 添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动等规则）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己主要阶段才能发动。手卡1只「娱乐伙伴」怪兽或者「异色眼」怪兽给对方观看。这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89113320,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c89113320.lvtg)
	e2:SetOperation(c89113320.lvop)
	c:RegisterEffect(e2)
	-- ①：这张卡被战斗破坏时才能发动。把让这张卡破坏的怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89113320,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetTarget(c89113320.target)
	e3:SetOperation(c89113320.operation)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡中的「娱乐伙伴」怪兽或「异色眼」怪兽
function c89113320.filter(c)
	return c:IsSetCard(0x9f,0x99) and c:IsType(TYPE_MONSTER)
end
-- 灵摆效果的发动准备与可行性检查
function c89113320.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只除自身以外的「娱乐伙伴」或「异色眼」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89113320.filter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
-- 灵摆效果的执行：展示手卡怪兽并使其及同名卡等级下降1星
function c89113320.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡选择1只符合过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c89113320.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 给对方玩家确认选中的怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
	-- 获取手卡中所有与被展示怪兽同名的怪兽组
	local hg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND,0,nil,g:GetFirst():GetCode())
	local tc=hg:GetFirst()
	while tc do
		-- 这个回合，那只怪兽以及自己手卡的同名怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
end
-- 怪兽效果的发动准备与可行性检查：获取战斗对手并设置破坏操作信息
function c89113320.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsRelateToBattle() end
	-- 设置当前连锁的操作信息为破坏该战斗对手怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 怪兽效果的执行：破坏让这张卡破坏的怪兽
function c89113320.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将该战斗对手怪兽因效果破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
