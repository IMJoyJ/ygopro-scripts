--ヴェンデット・デイブレイク
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方场上的卡数量比自己场上的卡多的场合才能发动。选自己场上1只仪式召唤的「复仇死者」怪兽，那只怪兽以外的场上的卡全部破坏。那只「复仇死者」怪兽只要在场上表侧表示存在不能直接攻击。
function c60375194.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方场上的卡数量比自己场上的卡多的场合才能发动。选自己场上1只仪式召唤的「复仇死者」怪兽，那只怪兽以外的场上的卡全部破坏。那只「复仇死者」怪兽只要在场上表侧表示存在不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,60375194+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c60375194.condition)
	e1:SetTarget(c60375194.target)
	e1:SetOperation(c60375194.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件：对方场上的卡数量比自己场上的卡多
function c60375194.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的卡片数量是否大于自己场上的卡片数量
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
-- 定义过滤条件：自己场上表侧表示、且是仪式召唤的「复仇死者」怪兽
function c60375194.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x106) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 定义效果发动的目标检查与操作信息设置
function c60375194.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否存在至少1只符合过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c60375194.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取双方场上的所有卡片
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏效果的操作信息，预估破坏数量为场上卡片总数减1（排除选中的那只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount()-1,0,0)
end
-- 定义效果处理：选择1只符合条件的怪兽，破坏其以外的场上所有卡，并对该怪兽施加不能直接攻击的效果
function c60375194.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 发送系统提示，要求玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只符合过滤条件的「复仇死者」怪兽
	local tc=Duel.SelectMatchingCard(tp,c60375194.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if not tc then return end
	-- 获取选中的怪兽以外的场上所有卡片
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,tc)
	if g:GetCount()>0 then
		-- 将这些卡片全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
	-- 那只「复仇死者」怪兽只要在场上表侧表示存在不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
