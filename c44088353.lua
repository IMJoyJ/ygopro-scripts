--ドールハンマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，自己抽2张。那之后，可以把对方场上1只怪兽的表示形式变更。
-- ②：这张卡在墓地存在的状态，从自己墓地有怪兽特殊召唤的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 执行对应的效果条件检查或辅助函数处理
function s.initial_effect(c)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 执行对应的效果条件检查或辅助函数处理
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 执行对应的效果条件检查或辅助函数处理
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 执行对应的效果条件检查或辅助函数处理
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetTargetPlayer(tp)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetTargetParam(2)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 执行对应的效果条件检查或辅助函数处理
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行对应的效果条件检查或辅助函数处理
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER)
	-- 执行对应的效果条件检查或辅助函数处理
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)>0
		-- 执行对应的效果条件检查或辅助函数处理
		and Duel.Draw(p,d,REASON_EFFECT)~=0
		-- 执行对应的效果条件检查或辅助函数处理
		and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil)
		-- 执行对应的效果条件检查或辅助函数处理
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变表示形式？"
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 执行对应的效果条件检查或辅助函数处理
		local cg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
		if cg:GetCount()>0 then
			-- 执行对应的效果条件检查或辅助函数处理
			Duel.BreakEffect()
			-- 执行对应的效果条件检查或辅助函数处理
			Duel.HintSelection(cg)
			-- 执行对应的效果条件检查或辅助函数处理
			Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end
-- 执行对应的效果条件检查或辅助函数处理
function s.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetPreviousControler()==tp and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 执行对应的效果条件检查或辅助函数处理
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行对应的效果条件检查或辅助函数处理
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
