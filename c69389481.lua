--魂の結束－ソウル・ユニオン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只表侧表示怪兽和自己墓地1只「元素英雄」怪兽为对象才能发动。作为对象的场上的怪兽的攻击力直到回合结束时上升作为对象的墓地的怪兽的攻击力数值。自己的场上或墓地有「元素英雄」通常怪兽存在的场合，可以再让以下效果适用。
-- ●自己墓地的怪兽作为融合素材除外，把1只「元素英雄」融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册卡片发动时的效果：提升场上怪兽攻击力，并可在满足条件时进行墓地融合召唤。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以场上1只表侧表示怪兽和自己墓地1只「元素英雄」怪兽为对象才能发动。作为对象的场上的怪兽的攻击力直到回合结束时上升作为对象的墓地的怪兽的攻击力数值。自己的场上或墓地有「元素英雄」通常怪兽存在的场合，可以再让以下效果适用。●自己墓地的怪兽作为融合素材除外，把1只「元素英雄」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中攻击力大于0的「元素英雄」怪兽。
function s.atkfilter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_MONSTER) and c:GetAttack()>0
end
-- 效果发动的对象选择与合法性检查。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查场上是否存在至少1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查自己墓地是否存在至少1只满足条件的「元素英雄」怪兽。
		and Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示怪兽作为对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 提示玩家选择作为效果对象的墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己墓地1只「元素英雄」怪兽作为对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- 过滤条件：可以被除外且不受当前效果影响的卡（用于融合素材）。
function s.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以使用指定素材进行融合召唤的「元素英雄」融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3008) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤条件：「元素英雄」通常怪兽。
function s.cfilter(c)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL)
end
-- 效果处理核心逻辑：提升攻击力，并根据条件判断是否追加进行墓地融合召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联的对象卡片。
	local stg=Duel.GetTargetsRelateToChain()
	local mc=stg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD):GetFirst()
	local gc=stg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	if not mc or not gc then return end
	if not mc:IsImmuneToEffect(e) then
		local atk=gc:GetAttack()
		-- 作为对象的场上的怪兽的攻击力直到回合结束时上升作为对象的墓地的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		mc:RegisterEffect(e1)
		if not mc:IsHasEffect(EFFECT_REVERSE_UPDATE)
			-- 检查自己的场上或墓地是否存在「元素英雄」通常怪兽。
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) then
			local chkf=tp
			-- 获取自己墓地中可作为融合素材除外的卡片组。
			local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e)
			-- 获取额外卡组中可以使用墓地素材融合召唤的「元素英雄」融合怪兽组。
			local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
			local mg2=nil
			local sg2=nil
			-- 获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 获取在使用连锁素材效果时，额外卡组中可以融合召唤的「元素英雄」融合怪兽组。
				sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
			end
			if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) then
				::cancel::
				-- 询问玩家是否选择适用追加效果进行融合召唤。
				if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否进行融合召唤？"
					local sg=sg1:Clone()
					if sg2 then sg:Merge(sg2) end
					-- 提示玩家选择要特殊召唤的融合怪兽。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local tg=sg:Select(tp,1,1,nil)
					local tc=tg:GetFirst()
					-- 判断是否使用本卡自身的效果（除外墓地素材）进行融合召唤。
					if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
						-- 玩家从墓地中选择用于融合召唤该怪兽的融合素材。
						local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
						if #mat1<2 then goto cancel end
						tc:SetMaterial(mat1)
						-- 插入时点中断，使后续的除外和特殊召唤处理与之前的攻击力上升不视为同时处理。
						Duel.BreakEffect()
						-- 将选定的融合素材怪兽从墓地表侧表示除外。
						Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
						-- 插入时点中断，使除外素材与特殊召唤不视为同时处理。
						Duel.BreakEffect()
						-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤到场上。
						Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
					elseif ce then
						-- 在适用连锁素材效果时，玩家选择对应的融合素材。
						local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
						if #mat2<2 then goto cancel end
						local fop=ce:GetOperation()
						-- 插入时点中断，使后续的连锁素材融合召唤处理不与之前的攻击力上升视为同时处理。
						Duel.BreakEffect()
						fop(ce,e,tp,tc,mat2)
					end
					tc:CompleteProcedure()
				end
			end
		end
	end
end
