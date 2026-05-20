--スプライト・レッド
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有2星或连接2的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：对方把怪兽的效果发动时，把自己场上1只其他的2星·2阶·连接2的怪兽解放才能发动。那个效果无效。把2阶或连接2的怪兽解放发动的场合，可以再把那只无效的怪兽破坏。
function c75922381.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有2星或连接2的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75922381,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,75922381+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c75922381.spcon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：对方把怪兽的效果发动时，把自己场上1只其他的2星·2阶·连接2的怪兽解放才能发动。那个效果无效。把2阶或连接2的怪兽解放发动的场合，可以再把那只无效的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75922381,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,75922382)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c75922381.discon)
	e2:SetCost(c75922381.discost)
	e2:SetTarget(c75922381.distg)
	e2:SetOperation(c75922381.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的2星或连接2的怪兽
function c75922381.filter(c)
	return (c:IsLevel(2) or c:IsLink(2)) and c:IsFaceup()
end
-- 特殊召唤规则的判定条件
function c75922381.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只满足过滤条件的怪兽（2星或连接2且表侧表示）
		and Duel.IsExistingMatchingCard(c75922381.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 效果无效发动的判定条件
function c75922381.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的怪兽效果，且该连锁效果可以被无效
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 过滤条件：2星、2阶或连接2的怪兽（用于解放代价）
function c75922381.cfilter(c)
	return c:IsLevel(2) or c:IsRank(2) or c:IsLink(2)
end
-- 效果无效发动的代价（Cost）处理函数
function c75922381.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否存在除自身以外可解放的满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c75922381.cfilter,1,e:GetHandler()) end
	-- 选择自己场上1只除自身以外满足条件的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c75922381.cfilter,1,1,e:GetHandler())
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
	-- 获取刚才实际被解放的怪兽并将其保存为标签对象
	local tc=Duel.GetOperatedGroup():GetFirst()
	e:SetLabelObject(tc)
end
-- 效果无效发动的目标（Target）处理函数
function c75922381.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：该效果包含使对方发动的效果无效的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果无效发动的效果处理（Operation）函数
function c75922381.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 如果成功使该效果无效，且该卡在场上存在并可以被破坏
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) and rc:IsDestructable()
		and (e:GetLabelObject():IsRank(2) or e:GetLabelObject():IsLink(2))
		-- 且解放的是2阶或连接2的怪兽时，询问玩家是否选择将该怪兽破坏
		and Duel.SelectYesNo(tp,aux.Stringid(75922381,2)) then  --"是否把那只怪兽破坏？"
		-- 中断当前效果处理，使后续的破坏处理不与无效处理同时进行
		Duel.BreakEffect()
		-- 破坏那只被无效效果的怪兽
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
