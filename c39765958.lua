--琰魔竜 レッド・デーモン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，自己的主要阶段1才能发动。这张卡以外的场上表侧攻击表示存在的怪兽全部破坏。这个效果发动的回合，这张卡以外的怪兽不能攻击。
function c39765958.initial_effect(c)
	-- 为怪兽添加同调召唤手续：需要1只调整（无额外限制）和1只以上调整以外的怪兽，对应“调整＋调整以外的怪兽1只以上”。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文：1回合1次，自己的主要阶段1才能发动。这张卡以外的场上表侧攻击表示存在的怪兽全部破坏。这个效果发动的回合，这张卡以外的怪兽不能攻击。
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
-- 效果发动条件函数：限制该效果只能在主要阶段1发动，对应“自己的主要阶段1才能发动”。
function c39765958.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1，若是则条件成立，允许发动该效果。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 发动代价处理：无实际代价，但会在场上设置一个持续到结束阶段的“不能攻击”誓约效果，并排除本卡，使这张卡以外的怪兽本回合不能攻击，对应“这个效果发动的回合，这张卡以外的怪兽不能攻击”。
function c39765958.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 对应效果原文：这张卡以外的场上表侧攻击表示存在的怪兽全部破坏。这个效果发动的回合，这张卡以外的怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c39765958.ftarget)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述“不能攻击”的誓约效果注册到当前玩家场上，使其对全场怪兽生效（再通过ftarget排除本卡）。
	Duel.RegisterEffect(e1,tp)
end
-- 作为不能攻击效果的对象筛选条件：通过比较效果上记录的发动怪兽FieldID与当前怪兽的FieldID，排除“这张卡”自身，使仅这张卡以外的怪兽受到不能攻击限制。
function c39765958.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 破坏对象的筛选条件：选择场上的表侧攻击表示怪兽，对应“场上表侧攻击表示存在的怪兽”。
function c39765958.dfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 破坏效果的目标阶段：检查能否选出至少1只除自身以外的表侧攻击表示怪兽；若可以，则获取全部这类怪兽作为破坏对象，并登记操作信息。
function c39765958.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的合法性检查（chk==0）：场上存在除这张卡以外的表侧攻击表示怪兽才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c39765958.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除这张卡以外的所有表侧攻击表示怪兽，作为将要被破坏的集合。
	local sg=Duel.GetMatchingGroup(c39765958.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 向连锁系统设置本次破坏的操作信息（分类为破坏，对象为上述集合，数量为其数量），供星尘龙等卡正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理阶段：重新取得场上除这张卡以外的所有表侧攻击表示怪兽（不取对象），并将它们全部破坏。
function c39765958.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新筛选出场上除这张卡以外的表侧攻击表示怪兽，以保证处理时以实际场上状态为准。
	local sg=Duel.GetMatchingGroup(c39765958.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 以效果原因将这些怪兽全部破坏，实现“这张卡以外的场上表侧攻击表示存在的怪兽全部破坏”。
	Duel.Destroy(sg,REASON_EFFECT)
end
