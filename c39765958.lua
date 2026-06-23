--琰魔竜 レッド・デーモン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，自己的主要阶段1才能发动。这张卡以外的场上表侧攻击表示存在的怪兽全部破坏。这个效果发动的回合，这张卡以外的怪兽不能攻击。
function c39765958.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，自己的主要阶段1才能发动。这张卡以外的场上表侧攻击表示存在的怪兽全部破坏。这个效果发动的回合，这张卡以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(39765958,0))  --"破坏"
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c39765958.descon)
	e1:SetCost(c39765958.descost)
	e1:SetTarget(c39765958.destg)
	e1:SetOperation(c39765958.desop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前阶段为自己的主要阶段1
function c39765958.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为自己的主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 效果费用：为对方场上所有怪兽添加不能攻击的效果
function c39765958.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 为对方场上所有怪兽添加不能攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c39765958.ftarget)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 目标过滤函数：排除自身，使其他怪兽不能攻击
function c39765958.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 过滤函数：筛选表侧攻击表示的怪兽
function c39765958.dfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 效果目标设定：检索场上所有表侧攻击表示的怪兽
function c39765958.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果发动条件：场上存在至少1只表侧攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c39765958.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上所有表侧攻击表示的怪兽组成组
	local sg=Duel.GetMatchingGroup(c39765958.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置连锁操作信息：准备破坏场上所有表侧攻击表示的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：破坏场上所有表侧攻击表示的怪兽
function c39765958.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧攻击表示的怪兽组成组（排除自身）
	local sg=Duel.GetMatchingGroup(c39765958.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将目标怪兽全部破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
