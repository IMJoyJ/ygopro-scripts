--魔轟神獣クダベ
-- 效果：
-- 名字带有「魔轰神」的调整＋调整以外的怪兽1只以上
-- 这张卡得到自己手卡的数量的以下效果。
-- ●0张：这张卡不会被战斗以及卡的效果破坏。
-- ●3张以上：结束阶段时这张卡破坏。
function c89194103.initial_effect(c)
	-- 设定同调召唤的手续为名字带有「魔轰神」的调整加1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x35),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ●0张：这张卡不会被战斗以及卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c89194103.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ●3张以上：结束阶段时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c89194103.descon)
	e3:SetTarget(c89194103.destg)
	e3:SetOperation(c89194103.desop)
	c:RegisterEffect(e3)
end
-- 定义不会被破坏效果的适用条件函数
function c89194103.indcon(e)
	-- 判断自己手卡数量是否为0张
	return Duel.GetFieldGroupCount(e:GetHandler():GetControler(),LOCATION_HAND,0)==0
end
-- 定义结束阶段破坏效果的发动条件函数
function c89194103.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己手卡数量是否在3张以上
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=3
end
-- 定义结束阶段破坏效果的发动准备与目标确认函数
function c89194103.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏这张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 定义结束阶段破坏效果的执行函数
function c89194103.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 因效果破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
