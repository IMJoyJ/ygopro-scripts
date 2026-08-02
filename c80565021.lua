--Angelechy Opening to e4
local s,id,o=GetID()
-- 声明初始化函数
function s.initial_effect(c)
	-- 这张卡发动的效果处理
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡可以从手卡发动的效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
-- 从手卡发动的条件函数
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断当前回合数是否为1，且回合玩家是否为对方
	return Duel.GetTurnCount()==1 and Duel.GetTurnPlayer()==1-tp
		-- 判断当前阶段是否为准备阶段
		and Duel.GetCurrentPhase()==PHASE_STANDBY
end
-- 筛选卡名带有0x1e2且为场地魔法的过滤函数
function s.stfilter(c,tp)
	return c:IsSetCard(0x1e2) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 筛选卡名带有0x1e2的怪兽且能放置在魔陷区的过滤函数
function s.setfilter(c,tp)
	return c:IsSetCard(0x1e2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 筛选等级2到7的0x1e2字段怪兽，且能被特殊召唤并符合格子要求的过滤函数
function s.spfilter(c,e,tp,pchk)
	return c:IsLevel(2,7) and c:IsSetCard(0x1e2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断额外卡组是否可以特殊召唤怪兽
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
		-- 判断是否不需要额外检查或者额外卡组存在可以放置的怪兽
		and (not pchk or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_EXTRA,0,1,c,tp))
end
-- 发动时的检查和执行目标设定
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组、手卡或墓地是否存在满足条件的场地魔法
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp)
		-- 检查额外卡组是否存在可以特殊召唤的满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,true)
		-- 判断如果是从场上发动或者不检查cost时，自己魔陷区是否有空位
		and ((e:GetHandler():IsLocation(LOCATION_ONFIELD) or not e:IsCostChecked()) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 判断如果是从手卡发动，自己魔陷区是否有1个以上的空位
			or e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_SZONE)>1) end
	-- 设定从额外卡组特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动的效果执行过程
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要放置到场上的场地魔法
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组、手卡或墓地选择1张满足条件的场地魔法
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己的场地区域的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 将自己场地区域的卡规则送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果，以进行下一步处理
			Duel.BreakEffect()
		end
		-- 将选择的场地魔法放置到场地区域
		if Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) then
			-- 判断额外卡组是否有可以特殊召唤的满足条件的怪兽
			if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,true) then
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从额外卡组选择1只满足条件的怪兽
				local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
				-- 若成功将该怪兽特殊召唤
				if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)~=0 then
					-- 判断自己的魔陷区是否有空位
					if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
						-- 提示玩家选择要放置到魔陷区的怪兽
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
						-- 从额外卡组选择1张满足条件的怪兽
						local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
						local sc=sg:GetFirst()
						if sc then
							-- 将该怪兽表侧表示放置在魔陷区
							Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
							-- 将放置的怪兽当作永续魔法卡使用
							local e1=Effect.CreateEffect(c)
							e1:SetCode(EFFECT_CHANGE_TYPE)
							e1:SetType(EFFECT_TYPE_SINGLE)
							e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
							e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
							e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
							sc:RegisterEffect(e1)
						end
					end
				end
			else
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从额外卡组选择1只满足条件的怪兽
				local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,false)
				if g:GetCount()>0 then
					-- 将该怪兽特殊召唤
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
				end
			end
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 发动后适用不能从额外卡组特殊召唤的自肃效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		local ct=1
		-- 判断如果当前回合是自己回合，则自肃持续回合数加1
		if Duel.GetTurnPlayer()==tp then
			ct=2
		end
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,ct)
		-- 向玩家注册该自肃效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃效果的限制条件：不能从额外卡组特殊召唤同调怪兽以外的怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
