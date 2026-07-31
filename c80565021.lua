--Angelechy Opening to e4
local s,id,o=GetID()
-- 初始化卡片效果：注册①卡片发动效果（放置场地区/特召/放置魔陷区）、②第1回合对方准备阶段可从手牌发动陷阱效果
function s.initial_effect(c)
	-- ①：卡片发动的效果处理：从卡组·手牌·墓地把1张「昂格勒契」场地魔法卡表侧表示放置，从额外卡组把1只2~7星的「昂格勒契」怪兽特殊召唤，再从额外卡组把1只「昂格勒契」怪兽当作永续魔法卡表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：第1回合的对方准备阶段，这张卡可以从手牌发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
-- 手牌发动条件检查：必须在第1回合的对方准备阶段
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查是否为第1回合且当前为对方回合
	return Duel.GetTurnCount()==1 and Duel.GetTurnPlayer()==1-tp
		-- 检查当前阶段是否为准备阶段
		and Duel.GetCurrentPhase()==PHASE_STANDBY
end
-- 过滤条件：手牌/卡组/墓地的「昂格勒契」场地魔法卡
function s.stfilter(c,tp)
	return c:IsSetCard(0x1e2) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤条件：额外卡组可作为永续魔法放置在魔法与陷阱区域的「昂格勒契」怪兽
function s.setfilter(c,tp)
	return c:IsSetCard(0x1e2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 过滤条件：额外卡组2~7星且可特殊召唤到额外怪兽区/特定格子的「昂格勒契」怪兽
function s.spfilter(c,e,tp,pchk)
	return c:IsLevel(2,7) and c:IsSetCard(0x1e2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查指定额外怪兽区域是否有空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
		-- 检查额外卡组是否存在除自身外可放置在魔陷区的怪兽
		and (not pchk or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_EXTRA,0,1,c,tp))
end
-- 卡片发动准备：检查场地卡放置、特殊召唤条件及魔陷区空位
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组/手牌/墓地是否存在可放置的「昂格勒契」场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp)
		-- 发动条件检查：额外卡组是否存在可特殊召唤的「昂格勒契」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,true)
		-- 检查魔法与陷阱区域是否有可用空格
		and ((e:GetHandler():IsLocation(LOCATION_ONFIELD) or not e:IsCostChecked()) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 从手牌发动时检查魔法与陷阱区域是否有至少2个空位
			or e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_SZONE)>1) end
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 卡片发动处理：放置场地魔法，特召额外怪兽，并将额外怪兽放置在魔陷区当作永续魔法
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要放置在场地区域的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组/手牌/墓地选择1张「昂格勒契」场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取己方场地区域现有的场地魔法卡
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			-- 依照规则将原有的场地魔法卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断效果处理（分隔送去墓地与放置场地卡）
			Duel.BreakEffect()
		end
		-- 将选中的卡表侧表示放置到场地区域
		if Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) then
			-- 检查额外卡组是否存在可特召且能满足后续放置魔陷区条件的怪兽
			if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,true) then
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从额外卡组选择1只满足条件的「昂格勒契」怪兽
				local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
				-- 将选中的怪兽特殊召唤到指定区域，并检查特召是否成功
				if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)~=0 then
					-- 检查魔法与陷阱区域是否有空位
					if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
						-- 提示玩家选择要放置到魔法与陷阱区域的卡
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
						-- 从额外卡组选择1只「昂格勒契」怪兽
						local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
						local sc=sg:GetFirst()
						if sc then
							-- 将选中的怪兽表侧表示移动到魔法与陷阱区域
							Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
							-- 将放置到魔法与陷阱区域的怪兽当作永续魔法卡使用
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
				-- 从额外卡组选择1只满足条件的「昂格勒契」怪兽
				local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,false)
				if g:GetCount()>0 then
					-- 将选中的怪兽特殊召唤到指定区域
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
				end
			end
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下一个自己回合结束时，自己不是同调怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		local ct=1
		-- 检查当前回合是否为自己回合，确定限制生效的持续回合数
		if Duel.GetTurnPlayer()==tp then
			ct=2
		end
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,ct)
		-- 为玩家注册额外卡组特殊召唤限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 特召限制条件：禁止从额外卡组特殊召唤同调怪兽以外的怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
