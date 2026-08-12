--ブラック・バード・クローズ
-- 效果：
-- 自己场上有「黑羽」同调怪兽或者「黑翼龙」存在的场合，这张卡的发动从手卡也能用。
-- ①：对方场上的怪兽把效果发动时，把自己场上1只表侧表示的「黑羽」怪兽送去墓地才能发动。那个发动无效并破坏。那之后，可以从额外卡组把1只「黑翼龙」特殊召唤。
function c80254726.initial_effect(c)
	-- 注册卡片关联密码（黑翼龙）
	aux.AddCodeList(c,9012916)
	-- ①：对方场上的怪兽把效果发动时，把自己场上1只表侧表示的「黑羽」怪兽送去墓地才能发动。那个发动无效并破坏。那之后，可以从额外卡组把1只「黑翼龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c80254726.condition)
	e1:SetCost(c80254726.cost)
	e1:SetTarget(c80254726.target)
	e1:SetOperation(c80254726.activate)
	c:RegisterEffect(e1)
	-- 自己场上有「黑羽」同调怪兽或者「黑翼龙」存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80254726,1))  --"适用「黑鸟断道翼」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c80254726.handcon)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定
function c80254726.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发效果的连锁发生位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 判定是否为对方场上的怪兽发动效果且该发动可以被无效
	return ep~=tp and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤自己场上表侧表示且能送去墓地的「黑羽」怪兽
function c80254726.discfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价处理
function c80254726.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足条件的「黑羽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c80254726.discfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只表侧表示的「黑羽」怪兽
	local g=Duel.SelectMatchingCard(tp,c80254726.discfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动目标判定与操作信息注册
function c80254726.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 注册“使发动无效”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 注册“破坏”的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤额外卡组中可以特殊召唤的「黑翼龙」
function c80254726.sfilter(c,e,tp)
	-- 判定卡名是否为「黑翼龙」、能否特殊召唤以及额外怪兽区域是否有空位
	return c:IsCode(9012916) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的效果处理
function c80254726.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否成功使发动无效且该卡在场上存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		-- 判定是否成功破坏该卡
		and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 获取额外卡组中第1张满足条件的「黑翼龙」
		local sc=Duel.GetFirstMatchingCard(c80254726.sfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		-- 询问玩家是否选择特殊召唤「黑翼龙」
		if sc and Duel.SelectYesNo(tp,aux.Stringid(80254726,0)) then  --"是否特殊召唤「黑翼龙」？"
			-- 中断效果处理，使后续特殊召唤与前面的破坏不视为同时处理
			Duel.BreakEffect()
			-- 将「黑翼龙」以表侧表示特殊召唤
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤自己场上表侧表示的「黑羽」同调怪兽或「黑翼龙」
function c80254726.cfilter(c)
	return c:IsFaceup() and ((c:IsSetCard(0x33) and c:IsType(TYPE_SYNCHRO)) or c:IsCode(9012916))
end
-- 手卡发动条件判定函数
function c80254726.handcon(e)
	-- 判定自己场上是否存在「黑羽」同调怪兽或者「黑翼龙」
	return Duel.IsExistingMatchingCard(c80254726.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
