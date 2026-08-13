--超重武者ワカ－O2
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
-- ②：这张卡不会被战斗破坏。
function c41628550.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。这张卡的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41628550,0))  --"表示变更"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c41628550.postg)
	e1:SetOperation(c41628550.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 作为①效果的发动条件判定：chk==0时直接返回true表示满足召唤成功的发动条件，并登记改变表示形式的操作信息。
function c41628550.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次连锁要进行的操作信息设为“改变表示形式”，对象为这张卡，数量1；用于正确传递效果类别，使相关卡能据此响应。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 效果处理时执行以下动作：获取效果持有者（这张卡），若这张卡仍与该效果关联（未被无效或离场），则变更其表示形式。
function c41628550.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡的表示形式变更：若当前是表侧攻击表示则变成表侧守备表示；其他表示形式则变成表侧攻击表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
