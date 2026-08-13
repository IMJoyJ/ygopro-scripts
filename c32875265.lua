--傀儡葬儀－パペット・パレード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，把最多有那个相差数量的「机关傀儡」怪兽从卡组特殊召唤（同名卡最多1张）。自己基本分比对方少2000以上的场合，可以再从卡组选1张「升阶魔法」通常魔法卡在自己的魔法与陷阱区域盖放。这张卡的发动后，直到回合结束时自己不是「机关傀儡」怪兽不能特殊召唤。
function c32875265.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方场上的怪兽数量比自己场上的怪兽多的场合，把最多有那个相差数量的「机关傀儡」怪兽从卡组特殊召唤（同名卡最多1张）。自己基本分比对方少2000以上的场合，可以再从卡组选1张「升阶魔法」通常魔法卡在自己的魔法与陷阱区域盖放。这张卡的发动后，直到回合结束时自己不是「机关傀儡」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,32875265+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c32875265.target)
	e1:SetOperation(c32875265.activate)
	c:RegisterEffect(e1)
end
-- 筛选函数：选出卡组中属于「机关傀儡」系列且能够被当前效果特殊召唤的怪兽。
function c32875265.spfilter(c,e,tp)
	return c:IsSetCard(0x1083) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的条件判定函数：检查自己怪兽区是否有空位、对方场上怪兽数量是否多于自己、卡组是否存在可特殊召唤的「机关傀儡」怪兽，并登记特殊召唤的操作信息。
function c32875265.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己主要怪兽区是否存在可用空格（用于后续特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定对方场上的怪兽数量是否比自己场上的怪兽数量多（差值即最多可特殊召唤的数量）。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 判定卡组中是否存在至少1只满足特殊召唤条件的「机关傀儡」怪兽。
		and Duel.IsExistingMatchingCard(c32875265.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次效果登记为包含特殊召唤的操作信息：预定从持有者（tp）的卡组特殊召唤1只怪兽，用于连锁与相关时点判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 筛选函数：选出卡组中属于「升阶魔法」字段、种类为通常魔法且可以盖放到魔法与陷阱区域的卡。
function c32875265.setfilter(c)
	return c:IsSetCard(0x95) and c:GetType()==TYPE_SPELL and c:IsSSetable()
end
-- 效果处理函数：先计算可特殊召唤的「机关傀儡」怪兽数量，从卡组选择最多该数量且卡名互不相同的怪兽表侧表示特殊召唤；若自己LP比对方少2000以上且卡组有可盖放的「升阶魔法」通常魔法，则追加盖放1张；最后给己方附加直到回合结束只能特殊召唤「机关傀儡」怪兽的限制。
function c32875265.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区当前可用的空格数量，作为本次特殊召唤的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 计算对方场上怪兽数量减去自己场上怪兽数量的差值，即最多可特殊召唤的「机关傀儡」怪兽数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if ft>0 and ct>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		ct=math.min(ct,ft)
		-- 从卡组中获取所有满足特殊召唤条件的「机关傀儡」怪兽，构成候选集合供玩家选择。
		local g=Duel.GetMatchingGroup(c32875265.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 向玩家显示“请选择要特殊召唤的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从候选集合中选择1至ct张卡，且所选卡的卡名互不相同，以满足“同名卡最多1张”的限制。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
		-- 将玩家选择的「机关傀儡」怪兽以表侧表示特殊召唤到自己场上，并返回是否至少有1只召唤成功。
		if sg and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0
			-- 判定自己当前基本分是否比对方少2000以上，以决定能否进行追加盖放。
			and Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
			-- 判定卡组中是否存在至少1张可盖放的「升阶魔法」通常魔法卡。
			and Duel.IsExistingMatchingCard(c32875265.setfilter,tp,LOCATION_DECK,0,1,nil)
			-- 询问玩家是否从卡组盖放1张「升阶魔法」魔法卡。
			and Duel.SelectYesNo(tp,aux.Stringid(32875265,0)) then  --"是否盖放「升阶魔法」魔法卡？"
			-- 中断当前效果处理，使后续盖放操作与前面的特殊召唤不视为同时处理，避免产生错误的连锁时点。
			Duel.BreakEffect()
			-- 向玩家显示“请选择要盖放的卡”的提示消息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			-- 从卡组选择1张满足条件的「升阶魔法」通常魔法卡。
			local tg=Duel.SelectMatchingCard(tp,c32875265.setfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选择的「升阶魔法」通常魔法卡盖放到自己的魔法与陷阱区域。
			Duel.SSet(tp,tg)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是「机关傀儡」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c32875265.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家tp注册一个永续效果，限制其在结束阶段前不能特殊召唤非「机关傀儡」怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 限制判定函数：若要被特殊召唤的怪兽不属于「机关傀儡」系列，则禁止该特殊召唤（即只有「机关傀儡」怪兽可以特殊召唤）。
function c32875265.splimit(e,c)
	return not c:IsSetCard(0x1083)
end
