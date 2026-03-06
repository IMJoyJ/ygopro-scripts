--スプライト・キャロット
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有2星或连接2的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：对方把魔法·陷阱卡的效果发动时，把自己场上1只其他的2星·2阶·连接2的怪兽解放才能发动。那个效果无效。把2阶或连接2的怪兽解放发动的场合，可以再把那张无效的卡破坏。
function c2311090.initial_effect(c)
	-- 效果原文：①：自己场上有2星或连接2的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2311090,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2311090+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c2311090.spcon)
	c:RegisterEffect(e1)
	-- 效果原文：②：对方把魔法·陷阱卡的效果发动时，把自己场上1只其他的2星·2阶·连接2的怪兽解放才能发动。那个效果无效。把2阶或连接2的怪兽解放发动的场合，可以再把那张无效的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2311090,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,2311091)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c2311090.discon)
	e2:SetCost(c2311090.discost)
	e2:SetTarget(c2311090.distg)
	e2:SetOperation(c2311090.disop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于判断场上是否存在2星或连接2的怪兽
function c2311090.filter(c)
	return (c:IsLevel(2) or c:IsLink(2)) and c:IsFaceup()
end
-- 特殊召唤条件函数：检查是否满足特殊召唤条件（场上存在2星或连接2的怪兽且有空位）
function c2311090.spcon(e,c)
	if c==nil then return true end
	-- 规则层面操作：检查玩家是否有足够的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 规则层面操作：检查场上是否存在至少1只2星或连接2的怪兽
		and Duel.IsExistingMatchingCard(c2311090.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 无效效果发动条件函数：判断是否为对方发动的魔法或陷阱效果
function c2311090.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否为对方发动的魔法或陷阱效果且该效果可被无效
	return ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
-- 过滤函数：用于判断是否为2星、2阶或连接2的怪兽
function c2311090.cfilter(c)
	return c:IsLevel(2) or c:IsRank(2) or c:IsLink(2)
end
-- 效果发动代价函数：检查并选择1只2星、2阶或连接2的怪兽进行解放
function c2311090.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c2311090.cfilter,1,e:GetHandler()) end
	-- 规则层面操作：选择1只满足条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c2311090.cfilter,1,1,e:GetHandler())
	-- 规则层面操作：将选中的怪兽解放作为发动代价
	Duel.Release(g,REASON_COST)
	-- 规则层面操作：获取实际被解放的怪兽并保存到效果标签中
	local tc=Duel.GetOperatedGroup():GetFirst()
	e:SetLabelObject(tc)
end
-- 效果发动目标函数：设置效果处理时的目标信息
function c2311090.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置连锁处理时的无效效果目标
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果发动处理函数：使对方效果无效并根据条件决定是否破坏该卡
function c2311090.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 规则层面操作：使连锁效果无效并判断目标卡是否仍然存在且可破坏
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) and rc:IsDestructable()
		and (e:GetLabelObject():IsRank(2) or e:GetLabelObject():IsLink(2))
		-- 规则层面操作：询问玩家是否破坏被无效的卡
		and Duel.SelectYesNo(tp,aux.Stringid(2311090,2)) then  --"是否把那张卡破坏？"
		-- 规则层面操作：中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 规则层面操作：破坏被无效的卡
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
