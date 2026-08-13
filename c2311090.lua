--スプライト・キャロット
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有2星或连接2的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：对方把魔法·陷阱卡的效果发动时，把自己场上1只其他的2星·2阶·连接2的怪兽解放才能发动。那个效果无效。把2阶或连接2的怪兽解放发动的场合，可以再把那张无效的卡破坏。
function c2311090.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次；①：自己场上有2星或连接2的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2311090,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2311090+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c2311090.spcon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次；②：对方把魔法·陷阱卡的效果发动时，把自己场上1只其他的2星·2阶·连接2的怪兽解放才能发动。那个效果无效。把2阶或连接2的怪兽解放发动的场合，可以再把那张无效的卡破坏。
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
-- 筛选自己场上表侧表示且等级为2或连接标记为2的怪兽。
function c2311090.filter(c)
	return (c:IsLevel(2) or c:IsLink(2)) and c:IsFaceup()
end
-- ①效果的特殊召唤条件：自己场上有满足条件的怪兽且主要怪兽区有空位时才能从手卡特殊召唤。
function c2311090.spcon(e,c)
	if c==nil then return true end
	-- 检查该怪兽控制者场上是否有可用的主要怪兽区空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查该怪兽控制者场上是否存在至少1只表侧表示的2星或连接2的怪兽（不取对象）。
		and Duel.IsExistingMatchingCard(c2311090.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动条件：对方发动魔法·陷阱卡的效果，且该连锁可以被无效时才能发动。
function c2311090.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家发动魔法·陷阱卡效果，且该连锁效果可以被无效。
	return ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
-- 筛选可以作为解放的怪兽：等级2·阶级2或连接标记2的怪兽。
function c2311090.cfilter(c)
	return c:IsLevel(2) or c:IsRank(2) or c:IsLink(2)
end
-- ②效果的发动代价：解放自己场上1只其他的等级2·阶级2·连接2的怪兽，并记录解放的怪兽。
function c2311090.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：自己场上是否存在至少1只满足条件的可解放怪兽（不包含发动效果的这张卡）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c2311090.cfilter,1,e:GetHandler()) end
	-- 选择1只满足条件的怪兽作为解放代价（不能选择这张卡自身）。
	local g=Duel.SelectReleaseGroup(tp,c2311090.cfilter,1,1,e:GetHandler())
	-- 将选择的怪兽解放，作为效果的发动代价。
	Duel.Release(g,REASON_COST)
	-- 获取刚刚解放的那只怪兽，存入效果标签，用于后续判断是否追加破坏。
	local tc=Duel.GetOperatedGroup():GetFirst()
	e:SetLabelObject(tc)
end
-- ②效果的发动目标处理：无需选择对象，宣告要无效对方发动的效果。
function c2311090.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次操作信息，分类为无效效果，对象为对方发动的那张魔法·陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果处理：无效对方发动的效果；若解放的是2阶或连接2的怪兽，则可以选择将那张卡破坏。
function c2311090.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 若对方连锁效果被成功无效，且那张卡仍与该效果关联且可以被破坏，则进入后续判断。
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) and rc:IsDestructable()
		and (e:GetLabelObject():IsRank(2) or e:GetLabelObject():IsLink(2))
		-- 若解放的怪兽是2阶或连接2，则询问玩家是否把那张无效的卡破坏。
		and Duel.SelectYesNo(tp,aux.Stringid(2311090,2)) then  --"是否把那张卡破坏？"
		-- 中断当前效果处理，使后续破坏处理视为另一次处理，避免错过时点。
		Duel.BreakEffect()
		-- 破坏对方那张被无效的魔法·陷阱卡，破坏原因为效果。
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
