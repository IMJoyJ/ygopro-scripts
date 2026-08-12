--ダイナレスラー・パンクラトプス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
-- ②：自己·对方回合，把自己场上1只「恐龙摔跤手」怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏。
function c82385847.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,82385847+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c82385847.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己·对方回合，把自己场上1只「恐龙摔跤手」怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,82385848)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c82385847.descost)
	e2:SetTarget(c82385847.destg)
	e2:SetOperation(c82385847.desop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件判定函数
function c82385847.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上的怪兽数量是否比自己场上的怪兽数量多
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)<Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)
end
-- 效果发动的代价判定函数，将Label设为1以标记需要支付解放代价
function c82385847.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤不能作为破坏目标的卡（排除作为装备卡装备在要解放的怪兽上的卡，以及要解放的怪兽自身）
function c82385847.desfilter(c,tc,ec)
	return c:GetEquipTarget()~=tc and c~=ec
end
-- 过滤可作为解放代价的「恐龙摔跤手」怪兽，且解放该怪兽后对方场上仍有可选择的破坏对象
function c82385847.costfilter(c,ec,tp)
	-- 检查是否为「恐龙摔跤手」怪兽，且对方场上存在至少1张不与该怪兽绑定的可选择卡片
	return c:IsSetCard(0x11a) and Duel.IsExistingTarget(c82385847.desfilter,tp,0,LOCATION_ONFIELD,1,c,c,ec)
end
-- 效果发动的目标选择与代价支付处理函数
function c82385847.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			-- 检查场上是否存在可作为解放代价的「恐龙摔跤手」怪兽
			return Duel.CheckReleaseGroup(tp,c82385847.costfilter,1,nil,c,tp)
		else
			-- 检查对方场上是否存在可以作为对象的卡
			return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
		end
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 选择自己场上1只满足条件的「恐龙摔跤手」怪兽作为解放代价
		local sg=Duel.SelectReleaseGroup(tp,c82385847.costfilter,1,1,nil,c,tp)
		-- 解放选择的「恐龙摔跤手」怪兽
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，执行破坏操作
function c82385847.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
