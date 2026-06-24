--闇の眼を持つ幻想師・ノー・フェイス
local s,id,o=GetID()
-- 初始化效果，注册两个效果：起动效果和场上的不被战斗破坏效果
function s.initial_effect(c)
	-- 记录该卡上记载着15259703和34298391这两张卡名
	aux.AddCodeList(c,15259703,34298391)
	-- 创建一个起动效果，可以在手牌时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 创建一个场上的不被战斗破坏效果，影响自己和对方的怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 支付费用函数，将自身送去墓地作为费用
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手牌送去墓地，并标记为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 设置当前处理的连锁对象为自己
	Duel.SetTargetCard(e:GetHandler())
end
-- 过滤函数，用于选择可以放置到场上的卡（34298391），且未被禁止、满足唯一性条件
function s.tffilter(c,tp)
	return c:IsCode(34298391)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤函数，用于从墓地选择可以加入手牌的卡（15259703）
function s.thfilter(c)
	-- 判断卡是否为15259703类型且为怪兽卡并能加入手牌
	return aux.IsCodeListed(c,15259703) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 目标选择函数，根据条件决定发动哪种效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的魔法区域
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家手牌或牌组中是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp)
		-- 若未支付费用则检查是否已使用过该效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查玩家墓地中是否存在满足条件的卡
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		-- 若未支付费用则检查是否已使用过该效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择发动哪种效果
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2})
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(0)
			-- 注册标识效果，防止在本回合再次使用效果1
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
			-- 注册标识效果，防止在本回合再次使用效果2
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息，准备将墓地的卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 效果处理函数，根据选择的效果执行不同的操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 检查场上是否有足够的魔法区域
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 选择一张满足条件的卡
		local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then
			-- 将选中的卡移动到场上
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从墓地中选择一张满足条件的卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,aux.ExceptThisCard(e))
		local tc=g:GetFirst()
		if tc then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认选中的卡
			Duel.ConfirmCards(1-tp,g)
			if tc:IsLocation(LOCATION_HAND)
				-- 检查是否有足够的怪兽区域并能特殊召唤
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
				-- 询问玩家是否要特殊召唤该卡
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				-- 中断当前效果处理，使后续效果视为错时点
				Duel.BreakEffect()
				-- 将选中的卡特殊召唤到场上
				Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end
-- 不被战斗破坏效果的目标过滤函数，影响自己和战斗对象
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
