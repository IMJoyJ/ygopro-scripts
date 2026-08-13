--武装転生
-- 效果：
-- ①：把最多有自己墓地的装备魔法卡以及持有把自身当作装备卡使用来装备效果的陷阱卡数量的「武装转生衍生物」（战士族·光·1星·攻/守500）在自己场上特殊召唤。那之后，以下可以适用。这个回合，自己不能把怪兽特殊召唤。
-- ●包含这张卡的自己的魔法与陷阱区域的卡全部破坏。那之后，装备魔法卡以及持有把自身当作装备卡使用来装备效果的陷阱卡从自己墓地尽可能到自己场上盖放。把陷阱卡盖放的场合，那些在盖放的回合也能发动。
local s,id,o=GetID()
-- 定义并注册「武装转生」的发动效果：设置效果描述、分类（特殊召唤+衍生物+盖放）、类型（魔陷发动）、发动时点（自由时点）、发动条件和处理函数。
function s.initial_effect(c)
	-- ①：把最多有自己墓地的装备魔法卡以及持有把自身当作装备卡使用来装备效果的陷阱卡数量的「武装转生衍生物」（战士族·光·1星·攻/守500）在自己场上特殊召唤。那之后，以下可以适用。这个回合，自己不能把怪兽特殊召唤。●包含这张卡的自己的魔法与陷阱区域的卡全部破坏。那之后，装备魔法卡以及持有把自身当作装备卡使用来装备效果的陷阱卡从自己墓地尽可能到自己场上盖放。把陷阱卡盖放的场合，那些在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断一个效果是否带有“装备”类别，用于识别“持有把自身当作装备卡使用来装备效果”的陷阱卡的装备效果。
function s.equip_filter(e)
	return e:IsHasCategory(CATEGORY_EQUIP)
end
-- 筛选墓地中可作为衍生物数量基准的卡：装备魔法卡，或持有装备自身效果的陷阱卡（通过原始效果是否含CATEGORY_EQUIP判断）。
function s.eqfilter(c)
	return c:IsType(TYPE_EQUIP) or c:IsType(TYPE_TRAP) and c:IsOriginalEffectProperty(s.equip_filter)
end
-- 发动条件检查：自己墓地存在符合条件的卡，自己主要怪兽区有空位，且自己可以特殊召唤「武装转生衍生物」。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在至少1张符合条件的装备魔法卡/装备效果陷阱卡，且自己主要怪兽区有可用空格。
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家能否特殊召唤「武装转生衍生物」（1星·光·战士族·攻/守500的衍生物）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	-- 向系统登记本次效果包含“衍生物”操作，预计特殊召唤1只衍生物（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 向系统登记本次效果包含“特殊召唤”操作，预计特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 选取自己主魔陷区域（不包含场地区域）的卡，作为“包含这张卡的自己的魔法与陷阱区域的卡”的破坏对象。
function s.desfilter(c)
	return c:GetSequence()<5
end
-- 筛选墓地中既满足可盖放，又满足“装备魔法卡或拥有装备效果的陷阱卡”的卡，用于后续从墓地盖放。
function s.eqfilter2(c)
	return c:IsSSetable() and s.eqfilter(c)
end
-- 效果处理：根据墓地符合条件的卡数与可用怪兽区空格数，特殊召唤最多数量的「武装转生衍生物」（若受「青眼精灵龙」效果影响则最多1只），并询问玩家是否继续；之后若「武装转生」仍在连锁中且满足条件，可适用破坏自己魔陷区并尽可能盖放墓地的装备卡/陷阱卡；最后为自己附加“这个回合不能特殊召唤怪兽”的自肃。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己可用的主要怪兽区空格数量，作为可特殊召唤衍生物的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 统计自己墓地中符合条件的装备魔法卡/装备效果陷阱卡的数量，决定最多可特殊召唤多少只衍生物。
	local ct=Duel.GetMatchingGroupCount(s.eqfilter,tp,LOCATION_GRAVE,0,nil)
	if ft>ct then ft=ct end
	-- 若还有可用的怪兽区空格，且玩家可以特殊召唤「武装转生衍生物」，则开始特殊召唤衍生物的处理。
	if ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,500,500,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local ctn=true
		while ft>0 and ctn do
			-- 创建一只「武装转生衍生物」（token）到场上。
			local token=Duel.CreateToken(tp,id+o)
			-- 以表侧表示将衍生物特殊召唤到自己主要怪兽区，作为多只衍生物同时特殊召唤的处理步骤。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			ft=ft-1
			-- 当已召唤到数量上限，或玩家选择不再继续特殊召唤衍生物时，停止循环。
			if ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then ctn=false end  --"是否继续特殊召唤衍生物？"
		end
		-- 完成衍生物的特殊召唤处理，统一结算特殊召唤成功。
		Duel.SpecialSummonComplete()
		local c=e:GetHandler()
		if c:IsRelateToChain() then
			-- 获取自己主魔陷区域的所有卡（不包含场地区域），作为“包含这张卡的自己的魔法与陷阱区域的卡”的候选。
			local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_SZONE,0,nil)
			-- 当自己主魔陷区存在卡，且墓地存在可盖放的装备魔法卡/装备效果陷阱卡时，才考虑适用破坏+盖放的追加效果。
			if dg:GetCount()>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
				-- 向玩家确认是否适用“破坏自己魔陷区的卡，并从墓地尽可能盖放装备/陷阱卡”的后续效果。
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否适用以下效果？"
				-- 中断当前效果处理，使之后的破坏处理与前面特殊召唤处理不在同一时点结算。
				Duel.BreakEffect()
				-- 破坏自己主魔陷区的所有卡；若破坏成功且「武装转生」这张卡也在其中，才继续后续盖放处理。
				if Duel.Destroy(dg,REASON_EFFECT)>0 and Duel.GetOperatedGroup():IsContains(c) then
					-- 从墓地筛选出可以盖放且符合条件的装备魔法卡/装备效果陷阱卡，并排除受「王家长眠之谷」效果影响的卡。
					local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter2),tp,LOCATION_GRAVE,0,nil)
					-- 获取自己当前可用的魔法与陷阱区域空格数，决定最多能盖放多少张卡。
					local count=Duel.GetLocationCount(tp,LOCATION_SZONE)
					if count>sg:GetCount() then count=sg:GetCount() end
					-- 向玩家展示选卡提示信息“请选择要盖放的卡”。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
					local tg=sg:Select(tp,count,count,nil)
					-- 再次中断效果处理，使盖放处理与之前的破坏处理分开结算。
					Duel.BreakEffect()
					-- 将玩家选出的卡以里侧表示盖放到自己魔法与陷阱区域。
					Duel.SSet(tp,tg)
					-- 遍历所有被盖放的卡，为其中每张卡附加“盖放的回合也能发动”的效果。
					for tc in aux.Next(tg) do
						-- 把陷阱卡盖放的场合，那些在盖放的回合也能发动。
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
	-- 这个回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“这个回合不能特殊召唤怪兽”的永续效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
