--メタル化・鋼炎装甲
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把有「金属化·强化反射装甲」的卡名记述的自己场上1只表侧表示怪兽解放才能把这张卡发动。把有「金属化·强化反射装甲」的卡名记述的1只不能通常召唤的怪兽无视召唤条件从卡组特殊召唤。那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
-- ●装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果：注册卡名记述信息，并创建这张卡的发动效果（设置特殊召唤+装备的分类、魔陷发动类型、自由时点、同名卡1回合1次限制以及代价·对象·处理函数）
function s.initial_effect(c)
	-- 在这张卡上记录记述了卡号为89812483的「金属化·强化反射装甲」这一卡名
	aux.AddCodeList(c,89812483)
	-- 这个卡名的卡在1回合只能发动1张。①：把有「金属化·强化反射装甲」的卡名记述的自己场上1只表侧表示怪兽解放才能把这张卡发动。把有「金属化·强化反射装甲」的卡名记述的1只不能通常召唤的怪兽无视召唤条件从卡组特殊召唤。那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义解放用过滤函数：筛选效果文本记述了「金属化·强化反射装甲」卡名、表侧表示、且其离场后自己场上仍有空怪兽区的怪兽
function s.cfilter(c,e,tp)
	-- 该卡记述了「金属化·强化反射装甲」的卡名、为表侧表示，且这张卡离场后自己的主要怪兽区仍有空位
	return aux.IsCodeListed(c,89812483) and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
-- 发动代价处理：设置标签标记本效果通过cost发动，检查并让自己场上1只记述了「金属化·强化反射装甲」卡名的表侧表示怪兽解放作为代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 发动条件检查：确认自己场上存在至少1只满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,e,tp) end
	-- 让自己从场上选择1只满足条件的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,e,tp)
	-- 把选择的怪兽作为代价解放
	Duel.Release(g,REASON_COST)
end
-- 定义特殊召唤用过滤函数：筛选卡组中记述了「金属化·强化反射装甲」卡名、不能通常召唤、且可以无视召唤条件特殊召唤的怪兽
function s.spfilter(c,e,tp)
	-- 该卡记述了「金属化·强化反射装甲」的卡名、是怪兽卡、且属于不能通常召唤的怪兽
	return aux.IsCodeListed(c,89812483) and c:IsType(TYPE_MONSTER) and not c:IsSummonableCard()
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 对象函数：发动时检查（已通过cost解放腾出格子或场上仍有空怪兽区）且卡组存在可特殊召唤的怪兽，然后设置特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==100
		-- 确认已通过cost解放腾出空位或自己主要怪兽区有空位，并且卡组里存在至少1只满足条件的可特殊召唤怪兽
		return (res or Duel.GetLocationCount(tp,LOCATION_MZONE)>0) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置操作信息：宣言将从卡组特殊召唤1只怪兽（用于星尘龙等效果的发动检测）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：确认有空怪兽区后，从卡组选1只满足条件的怪兽无视召唤条件特殊召唤，那之后若通过cost发动且这张卡仍在场上，可询问玩家是否把这张卡装备给那只怪兽；装备成功则赋予装备限制和破坏代替效果，否则正常送去墓地
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 向玩家提示「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从卡组选择1只满足过滤条件的怪兽并取得该卡
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 将选择的怪兽无视召唤条件以表侧表示特殊召唤到自己场上，并确认本次发动经过了cost
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)~=0 and e:GetLabel()==100
		-- 确认这张卡仍在场上且与效果保持关联，并询问玩家是否把这张卡装备给那只怪兽
		and c:IsOnField() and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否装备？"
		-- 中断当前效果处理，使后续的装备处理视为不同时处理（避免错时点问题）
		Duel.BreakEffect()
		c:CancelToGrave(true)
		-- 若把这张卡作为装备卡装备给那只特殊召唤的怪兽成功则继续处理
		if Duel.Equip(tp,c,tc) then
			-- 那之后，可以把这张卡当作持有以下效果的装备卡使用给那只怪兽装备。
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			c:RegisterEffect(e1)
			-- ●装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_DESTROY_REPLACE)
			e2:SetTarget(s.destg)
			e2:SetOperation(s.desop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
		else
			c:CancelToGrave(false)
		end
	end
end
-- 装备限制：这张卡只能装备给那只被特殊召唤的怪兽（装备对象仅为这张卡的装备目标本身）
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 破坏代替效果的对象检查：这张卡可以送去墓地、尚未处于破坏确认状态，且装备怪兽正因战斗或效果被破坏
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return c:IsAbleToGrave() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) end
	-- 询问玩家是否适用破坏代替（把这张卡送去墓地代替装备怪兽破坏）
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 破坏代替的处理：把这张卡作为代替送去墓地
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果·代替的原因把这张卡送去墓地，代替装备怪兽的破坏
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
