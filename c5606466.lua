--異次元の落とし穴
-- 效果：
-- 对方把1只怪兽守备表示盖放时才能发动。盖放的那1只怪兽和自己场上1只怪兽破坏并从游戏中除外。
function c5606466.initial_effect(c)
	-- 对方把1只怪兽守备表示盖放时才能发动。盖放的那1只怪兽和自己场上1只怪兽破坏并从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_MSET)
	e1:SetTarget(c5606466.target)
	e1:SetOperation(c5606466.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHANGE_POS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetTarget(c5606466.target2)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤对方盖放的里侧守备表示怪兽
function c5606466.filter(c,e,tp)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:GetReasonPlayer()==tp and c:IsCanBeEffectTarget(e) and c:IsAbleToRemove()
end
-- 过滤自己场上可以被选择为效果对象且可以被除外的怪兽
function c5606466.filter2(c,e)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
-- 过滤对方特殊召唤的里侧守备表示怪兽
function c5606466.filter3(c,e,tp)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsSummonPlayer(tp) and c:IsCanBeEffectTarget(e) and c:IsAbleToRemove()
end
-- 盖放或表示形式变更时的效果发动与对象选择处理
function c5606466.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local sg=eg:Filter(c5606466.filter,nil,e,1-tp)
		-- 检查是否刚好有1只对方盖放的怪兽，且自己场上存在至少1只其他可作为对象的怪兽
		return sg:GetCount()==1 and Duel.IsExistingMatchingCard(c5606466.filter2,tp,LOCATION_MZONE,0,1,sg:GetFirst(),e)
	end
	local sg1=eg:Filter(c5606466.filter,nil,e,1-tp)
	e:SetLabelObject(sg1:GetFirst())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1只用于破坏并除外的怪兽
	local sg2=Duel.SelectMatchingCard(tp,c5606466.filter2,tp,LOCATION_MZONE,0,1,1,sg1:GetFirst(),e)
	sg1:Merge(sg2)
	-- 将选中的两张卡（对方盖放的怪兽和自己场上的怪兽）设为效果处理的对象
	Duel.SetTargetCard(sg1)
	-- 设置连锁信息，表示该效果包含破坏这2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg1,sg1:GetCount(),0,0)
	-- 设置连锁信息，表示该效果包含除外这2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg1,sg1:GetCount(),0,0)
end
-- 对方特殊召唤里侧守备表示怪兽时的效果发动与对象选择处理
function c5606466.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local sg=eg:Filter(c5606466.filter3,nil,e,1-tp)
		-- 检查是否刚好有1只对方特殊召唤盖放的怪兽，且自己场上存在至少1只其他可作为对象的怪兽
		return sg:GetCount()==1 and Duel.IsExistingMatchingCard(c5606466.filter2,tp,LOCATION_MZONE,0,1,sg:GetFirst(),e)
	end
	local sg1=eg:Filter(c5606466.filter3,nil,e,1-tp)
	e:SetLabelObject(sg1:GetFirst())
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1只用于破坏并除外的怪兽
	local sg2=Duel.SelectMatchingCard(tp,c5606466.filter2,tp,LOCATION_MZONE,0,1,1,sg1:GetFirst(),e)
	sg1:Merge(sg2)
	-- 将选中的两张卡（对方特殊召唤盖放的怪兽和自己场上的怪兽）设为效果处理的对象
	Duel.SetTargetCard(sg1)
	-- 设置连锁信息，表示该效果包含破坏这2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg1,sg1:GetCount(),0,0)
	-- 设置连锁信息，表示该效果包含除外这2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg1,sg1:GetCount(),0,0)
end
-- 效果发动时的处理：获取对象卡片，确认其状态，并执行破坏与除外
function c5606466.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	local sc=e:GetLabelObject()
	if tc1 and tc1:IsRelateToEffect(e) and tc2 and tc2:IsRelateToEffect(e) and sc:IsFacedown() then
		-- 破坏对象卡片并将其除外（送往除外区）
		Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
	end
end
