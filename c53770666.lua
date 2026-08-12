--武装転生
-- 效果：
-- ①：把最多有自己墓地的装备魔法卡以及持有把自身当作装备卡使用来装备效果的陷阱卡数量的「武装转生衍生物」（战士族·光·1星·攻/守500）在自己场上特殊召唤。那之后，以下可以适用。这个回合，自己不能把怪兽特殊召唤。
-- ●包含这张卡的自己的魔法与陷阱区域的卡全部破坏。那之后，装备魔法卡以及持有把自身当作装备卡使用来装备效果的陷阱卡从自己墓地尽可能到自己场上盖放。把陷阱卡盖放的场合，那些在盖放的回合也能发动。
local s,id,o=GetID()
-- 创建效果，设置发动时的描述、分类、类型、时点、目标和效果处理函数
function s.initial_effect(c)
	-- 发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断效果是否为装备效果
function s.equip_filter(e)
	return e:IsHasCategory(CATEGORY_EQUIP)
end
-- 判断卡片是否为装备魔法卡或具有装备效果的陷阱卡
function s.eqfilter(c)
	return c:IsType(TYPE_EQUIP) or c:IsType(TYPE_TRAP) and c:IsOriginalEffectProperty(s.equip_filter)
end
-- 判断是否满足发动条件，包括墓地存在装备卡、场上存在空位、可以特殊召唤衍生物
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地是否存在装备卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	-- 设置操作信息为召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息为特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 判断卡片是否在魔法与陷阱区域且为场上区域
function s.desfilter(c)
	return c:GetSequence()<5
end
-- 判断卡片是否可以盖放且为装备卡
function s.eqfilter2(c)
	return c:IsSSetable() and s.eqfilter(c)
end
-- 效果处理函数，执行特殊召唤衍生物和后续盖放操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上怪兽区域的空位数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取玩家墓地装备卡数量
	local ct=Duel.GetMatchingGroupCount(s.eqfilter,tp,LOCATION_GRAVE,0,nil)
	if ft>ct then ft=ct end
	-- 判断是否可以特殊召唤衍生物
	if ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local ctn=true
		while ft>0 and ctn do
			-- 创建一张衍生物
			local token=Duel.CreateToken(tp,id+o)
			-- 特殊召唤一张衍生物
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			ft=ft-1
			-- 询问是否继续特殊召唤衍生物
			if ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then ctn=false end  --"是否继续特殊召唤衍生物？"
		end
		-- 完成特殊召唤步骤
		Duel.SpecialSummonComplete()
		local c=e:GetHandler()
		if c:IsRelateToChain() then
			-- 获取玩家场上魔法与陷阱区域的卡
			local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,0,nil)
			-- 判断场上是否存在魔法与陷阱区域的卡
			if dg:GetCount()>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
				-- 询问是否适用后续效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否适用以下效果？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 判断破坏是否成功且该卡在被破坏的卡中
				if Duel.Destroy(dg,REASON_EFFECT)>0 and Duel.GetOperatedGroup():IsContains(c) then
					-- 获取不受王家长眠之谷影响的可盖放装备卡
					local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter2),tp,LOCATION_GRAVE,0,nil)
					-- 获取玩家魔法与陷阱区域的空位数量
					local count=Duel.GetLocationCount(tp,LOCATION_SZONE)
					if count>sg:GetCount() then count=sg:GetCount() end
					-- 提示玩家选择要盖放的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
					local tg=sg:Select(tp,count,count,nil)
					-- 中断当前效果处理
					Duel.BreakEffect()
					-- 将卡盖放到玩家场上
					Duel.SSet(tp,tg)
					-- 遍历盖放的卡
					for tc in aux.Next(tg) do
						-- 适用「武装转生」的效果来发动
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetDescription(aux.Stringid(id,3))  --"适用「武装转生」的效果来发动"
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
						e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
					end
				end
			end
		end
	end
	-- 禁止自己在本回合特殊召唤怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果
	Duel.RegisterEffect(e1,tp)
end
