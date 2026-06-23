--氷の王 ニードヘッグ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「冰界王战 尼德霍格王」在自己场上只能有1只表侧表示存在。
-- ②：对方把怪兽特殊召唤之际，把自己场上1只「王战」怪兽或者幻龙族怪兽解放才能发动。那次特殊召唤无效，那些怪兽破坏。
function c49275969.initial_effect(c)
	c:SetUniqueOnField(1,0,49275969)
	-- 创建效果②，为诱发即时效果，对应二速的【……才能发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49275969,0))
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,49275969)
	e1:SetCondition(c49275969.discon)
	e1:SetCost(c49275969.discost)
	e1:SetTarget(c49275969.distg)
	e1:SetOperation(c49275969.disop)
	c:RegisterEffect(e1)
end
-- 效果条件：对方把怪兽特殊召唤时且当前无连锁处理中
function c49275969.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家与自己玩家不同且当前连锁序号为0
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 判断解放的卡是否为「王战」怪兽或幻龙族怪兽
function c49275969.costfilter(c)
	return c:IsSetCard(0x134) or c:IsRace(RACE_WYRM)
end
-- 检查是否有满足条件的卡可作为解放，并选择一张进行解放
function c49275969.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的可解放卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,c49275969.costfilter,1,nil) end
	-- 从场上选择1张满足条件的可解放卡
	local g=Duel.SelectReleaseGroup(tp,c49275969.costfilter,1,1,nil)
	-- 以代價原因解放所选卡
	Duel.Release(g,REASON_COST)
end
-- 设置连锁操作信息，确定要无效召唤和破坏的怪兽
function c49275969.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置要无效召唤的怪兽数量及对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置要破坏的怪兽数量及对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果处理：使对方特殊召唤无效并破坏相关怪兽
function c49275969.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方的特殊召唤无效
	Duel.NegateSummon(eg)
	-- 以效果原因破坏相关怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
