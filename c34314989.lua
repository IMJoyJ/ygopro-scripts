--闇の眼を持つ幻想師・ノー・フェイス
local s,id,o=GetID()
-- 注册丢弃自身发动两个分支效果、以及战斗不破坏的两个效果
function s.initial_effect(c)
	-- 在系统卡片信息中注册本卡关联的卡片密码「卡通世界」与「看透心灵之眼」
	aux.AddCodeList(c,15259703,34298391)
	-- ①：可以把这张卡从手卡丢弃，从以下效果选择1个发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：如果这张卡与怪兽进行战斗，那次战斗中双方都不会被破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）：将手牌的此卡丢弃去墓地，并选择此卡作为效果对象
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡作为Cost丢弃去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 将此卡选择为本效果的对象
	Duel.SetTargetCard(e:GetHandler())
end
-- 过滤条件：卡名为「看透心灵之眼」且不在场上受限、可以在场上放置的卡
function s.tffilter(c,tp)
	return c:IsCode(34298391)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤条件：有「卡通世界」卡名记述且可以加入手牌的怪兽
function s.thfilter(c)
	-- 检查卡片是否记述有「卡通世界」、是怪兽且可以加入手牌
	return aux.IsCodeListed(c,15259703) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的Target函数：检查并选择是放置「看透心灵之眼」还是回收记述有「卡通世界」的墓地怪兽，并根据选择注册对应的分类与Flag限制
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 分支1判定条件：检查自己魔法与陷阱区是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且手牌或卡组是否存在可放置的「看透心灵之眼」
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp)
		-- 且本回合尚未发动过分支效果A
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 分支2判定条件：检查墓地是否存在除此卡外记述有「卡通世界」的怪兽
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		-- 且本回合尚未发动过分支效果B
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 提示并让玩家从可用的选项中选择其中1项发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2})
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(0)
			-- 标记玩家本回合已使用过分支效果A
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
			-- 标记玩家本回合已使用过分支效果B
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置当前效果的操作信息为从墓地回收1张卡加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 效果①的Operation函数：执行选择的分支，若为放置「看透心灵之眼」则将其从手卡·卡组放置到场上；若为回收怪兽，则将墓地怪兽加入手牌，可进一步无视召唤条件特殊召唤
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 分支效果A处理：检查自己魔法与陷阱区是否有空位，若无则结束效果
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从手牌或卡组选择1张「看透心灵之眼」
		local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then
			-- 将选中的卡片在魔陷区表侧表示放置
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 在墓地选择1只除此卡外记述有「卡通世界」的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,aux.ExceptThisCard(e))
		local tc=g:GetFirst()
		if tc then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
			if tc:IsLocation(LOCATION_HAND)
				-- 检查怪兽区域是否有空位，且该怪兽是否能被无视召唤条件特殊召唤
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
				-- 询问玩家是否选择无视条件特殊召唤该怪兽
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				-- 中断当前效果处理，建立“那之后”的时点
				Duel.BreakEffect()
				-- 无视召唤条件将该怪兽特殊召唤
				Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end
-- 效果②的Target函数：确定该不会被战破效果适用于此卡以及与此卡进行战斗的怪兽
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
