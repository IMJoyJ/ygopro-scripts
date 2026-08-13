--ギアギアチェンジ
-- 效果：
-- 「齿轮齿轮变形」在1回合只能发动1张。
-- ①：以自己墓地的「齿轮齿轮人」怪兽2只以上为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤，只用那些怪兽为素材把1只超量怪兽超量召唤。
function c29087919.initial_effect(c)
	-- 「齿轮齿轮变形」在1回合只能发动1张。①：以自己墓地的「齿轮齿轮人」怪兽2只以上为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤，只用那些怪兽为素材把1只超量怪兽超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,29087919+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c29087919.target)
	e1:SetOperation(c29087919.activate)
	c:RegisterEffect(e1)
end
-- 筛选自己墓地中满足「齿轮齿轮人」字段、可作为效果对象且可被特殊召唤的怪兽，作为超量召唤素材候选。
function c29087919.filter(c,e,tp)
	return c:IsSetCard(0x1072) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选额外卡组中能够以候选素材（mg）为素材进行超量召唤的超量怪兽，素材数要求至少2且不超过可用主要怪兽区域数（ct）。
function c29087919.xyzfilter(c,mg,ct)
	return c:IsXyzSummonable(mg,2,ct)
end
-- 判断所选素材组是否满足卡名互不相同（对应“同名卡最多1张”），且额外卡组中存在能用这些素材进行超量召唤的超量怪兽。
function c29087919.fgoal(sg,exg)
	-- 确认所选素材卡名互不相同，且额外卡组中存在可以以这些素材为全部素材进行超量召唤的超量怪兽。
	return aux.dncheck(sg) and exg:IsExists(Card.IsXyzSummonable,1,nil,sg,#sg,#sg)
end
-- 发动时的目标选择处理：获取墓地候选素材、计算可用主要怪兽区格数、筛选额外卡组可用超量怪兽；在满足特殊召唤次数、不受青眼精灵龙限制、空位>1且存在合法素材组时，让玩家选择素材并设为效果对象。
function c29087919.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 取得自己墓地中所有符合filter条件的「齿轮齿轮人」怪兽，作为超量召唤的素材候选组。
	local mg=Duel.GetMatchingGroup(c29087919.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 取得自己场上可用的主要怪兽区域数量，用于限制素材数量和后续超量召唤的可行性。
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 取得额外卡组中能利用候选素材（mg）进行超量召唤的超量怪兽组，用于判断素材组是否可完成超量召唤。
	local exg=Duel.GetMatchingGroup(c29087919.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg,ct)
	-- 效果发动条件检查：确认玩家本回合还能特殊召唤至少2只怪兽，且不受青眼精灵龙“双方不能把2只以上的怪兽同时特殊召唤”的影响，同时自己主要怪兽区空位>1，并且存在满足同名卡最多1张且可超量召唤的素材组合。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and ct>1 and mg:CheckSubGroup(c29087919.fgoal,2,ct,exg) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，引导玩家选择要特殊召唤的素材怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=mg:SelectSubGroup(tp,c29087919.fgoal,false,2,ct,exg)
	-- 将玩家选择的素材组设置为当前连锁的效果对象，使这些卡与效果建立关联。
	Duel.SetTargetCard(sg1)
	-- 登记效果处理信息：声明将选中的素材怪兽特殊召唤，数量为所选素材数，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg1,sg1:GetCount(),0,0)
end
-- 效果处理时，从连锁对象中筛选出仍与效果关联且可被特殊召唤的「齿轮齿轮人」怪兽，用于实际特殊召唤。
function c29087919.filter2(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选额外卡组中能够以实际特殊召唤成功的素材（g）为素材进行超量召唤的超量怪兽。
function c29087919.spfilter(c,mg,ct)
	return c:IsXyzSummonable(mg,ct,ct)
end
-- 效果处理：若不受青眼精灵龙限制，则将选中的素材怪兽特殊召唤；若成功且素材仍在场上，则让玩家选择额外卡组中的超量怪兽，用这些素材进行超量召唤。
function c29087919.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 取得当前连锁的效果对象中仍然与效果相关且可特殊召唤的卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c29087919.filter2,nil,e,tp)
	-- 将筛选出的素材怪兽以表侧表示特殊召唤到自己的主要怪兽区，并返回实际特殊召唤成功的数量。
	local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	-- 立即刷新场地信息，确保后续区域和怪兽状态判定基于最新场地。
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<ct then return end
	-- 取得额外卡组中能够以实际特殊召唤成功的素材为全部素材进行超量召唤的超量怪兽组。
	local xyzg=Duel.GetMatchingGroup(c29087919.spfilter,tp,LOCATION_EXTRA,0,nil,g,ct)
	if ct>=2 and xyzg:GetCount()>0 then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示，引导玩家选择要超量召唤的额外怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		-- 使用特殊召唤出的素材g作为全部超量素材，将选定的超量怪兽xyz进行超量召唤。
		Duel.XyzSummon(tp,xyz,g)
	end
end
