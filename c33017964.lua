--幻魔の扉
-- 效果：
-- 这个卡名的效果在决斗中只能适用1次。
-- ①：把基本分支付一半才能发动。对方场上的怪兽全部破坏。那之后，可以从对方墓地把1只怪兽无视召唤条件在自己场上特殊召唤。
local s,id,o=GetID()
-- 注册卡牌效果，设置为发动时点、支付费用、进行破坏和特殊召唤操作
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c)  e1:SetDescription(aux.Stringid(id,0))  --"发动"  e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)  e1:SetType(EFFECT_TYPE_ACTIVATE)  e1:SetCode(EVENT_FREE_CHAIN)  e1:SetCost(s.cost)  e1:SetTarget(s.target)  e1:SetOperation(s.activate)  c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 支付一半基本分作为发动费用
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 设置发动时的处理目标，检查是否满足发动条件并设置破坏对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已发动过此效果且对方场上存在怪兽
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽作为破坏对象
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，确定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 定义特殊召唤的过滤条件，检查是否为怪兽卡且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 执行发动效果，先判断是否已发动过，然后注册标识效果，破坏对方场上怪兽并尝试特殊召唤对方墓地怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果已发动过此效果则直接返回
	if Duel.GetFlagEffect(tp,id)>0 then return end
	-- 注册标识效果，防止此卡名效果在决斗中重复使用
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	-- 获取对方场上的所有怪兽
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 破坏对方场上所有怪兽并检查己方是否有空怪兽区
	if Duel.Destroy(dg,REASON_EFFECT)>0 and Duel.GetMZoneCount(tp)>0 then
		-- 获取对方墓地中满足特殊召唤条件的怪兽
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,0,LOCATION_GRAVE,nil,e,tp)
		-- 如果对方墓地有可特殊召唤的怪兽且玩家选择发动，则进行特殊召唤
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local g=sg:Select(tp,1,1,nil)
			-- 显示所选卡被选为对象的动画效果
			Duel.HintSelection(g)
			-- 将选中的怪兽特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
