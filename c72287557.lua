--ヘル・ポリマー
-- 效果：
-- 对方的融合怪兽融合召唤时发动。把自己场上1只怪兽作为祭品，得到那1只融合怪兽的控制权。
function c72287557.initial_effect(c)
	-- 对方的融合怪兽融合召唤时发动。把自己场上1只怪兽作为祭品，得到那1只融合怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c72287557.condition)
	e1:SetCost(c72287557.cost)
	e1:SetTarget(c72287557.target)
	e1:SetOperation(c72287557.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件是否满足：对方仅有1只融合怪兽融合召唤成功
function c72287557.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsControler(1-tp) and tc:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 设置标签为1，用于在target中区分是检查发动还是实际发动并支付代价
function c72287557.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤函数：检查解放该怪兽后，是否能留出空位以接收控制权
function c72287557.costfilter(c,tp)
	-- 检查解放该怪兽后，自己场上是否有可用的怪兽区域
	return Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 效果的目标选择与代价支付：检查并选择对方融合召唤的怪兽为对象，并支付解放怪兽的代价
function c72287557.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local tc=eg:GetFirst()
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查自己场上是否存在可作为解放代价的怪兽
			return Duel.CheckReleaseGroup(tp,c72287557.costfilter,1,tc,tp)
				and tc:IsCanBeEffectTarget(e) and tc:IsControlerCanBeChanged(true)
		else
			return tc:IsCanBeEffectTarget(e) and tc:IsControlerCanBeChanged()
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择自己场上1只怪兽作为解放的代价
		local sg=Duel.SelectReleaseGroup(tp,c72287557.costfilter,1,1,tc,tp)
		-- 解放选中的怪兽
		Duel.Release(sg,REASON_COST)
	end
	-- 将对方融合召唤的怪兽设为效果的对象
	Duel.SetTargetCard(eg)
	-- 设置操作信息：效果分类为控制权转移，数量为1
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,1,0,0)
end
-- 效果处理：获取对象怪兽，若其仍存在于场上则转移其控制权
function c72287557.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 得到该怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
