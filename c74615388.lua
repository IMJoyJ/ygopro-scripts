--影の王 レイヴァーテイン
-- 效果：
-- 9星怪兽×2只以上
-- ①：「影界王战 雷瓦汀王」在自己场上只能有1只表侧表示存在。
-- ②：对方场上的怪兽的攻击力·守备力下降1000。
-- ③：自己·对方回合，把超量召唤的这张卡解放才能发动。从额外卡组把天使族怪兽以外的1只「王战」超量怪兽特殊召唤。那之后，可以选最多有这张卡持有的超量素材数量的自己或者对方的场上·墓地的卡在这个效果特殊召唤的怪兽下面重叠作为超量素材。
local s,id,o=GetID()
-- 注册卡片效果：场上只能存在1只、超量召唤手续、对方怪兽攻守下降、二速解放自身特召额外卡组王战超量怪兽并重叠素材
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- 添加超量召唤手续：9星怪兽2只以上
	aux.AddXyzProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ②：对方场上的怪兽的攻击力·守备力下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合，把超量召唤的这张卡解放才能发动。从额外卡组把天使族怪兽以外的1只「王战」超量怪兽特殊召唤。那之后，可以选最多有这张卡持有的超量素材数量的自己或者对方的场上·墓地的卡在这个效果特殊召唤的怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"从额外卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果③的发动代价：检查并解放超量召唤的自身，并记录解放时的超量素材数量
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() and c:IsSummonType(SUMMON_TYPE_XYZ) end
	local ct=c:GetOverlayCount()
	-- 解放自身作为发动代价
	Duel.Release(c,REASON_COST)
	e:SetLabel(ct)
end
-- 过滤额外卡组中非天使族的「王战」超量怪兽
function s.filter(c,e,tp,rc)
	return not c:IsRace(RACE_FAIRY)
		and c:IsSetCard(0x134) and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查在解放自身后，是否有可用的额外怪兽区域或连接端用于特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
end
-- 过滤可以作为超量素材重叠且不受该效果影响的卡片
function s.mtfilter(c,e)
	return c:IsCanOverlay() and not c:IsImmuneToEffect(e)
end
-- 效果③的发动准备：检查额外卡组是否存在可特召的怪兽，并声明特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查额外卡组是否存在至少1只满足条件的「王战」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的效果处理：特殊召唤1只「王战」超量怪兽，并可选择双方场上·墓地的卡作为其超量素材
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「王战」超量怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,e:GetHandler())
	if #g>0 then
		local tc=g:GetFirst()
		-- 获取双方场上及墓地中，除被特召怪兽以外的、可作为超量素材的卡片组（受王家长眠之谷影响）
		local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,tc,e)
		-- 若成功特殊召唤该怪兽，且被解放的自身原本持有超量素材
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and ct>0
			-- 且场上或墓地存在可作为素材的卡时，询问玩家是否选择卡片重叠作为超量素材
			and #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否选卡重叠作为超量素材？"
			-- 中断当前效果处理，使后续的重叠素材处理与特殊召唤不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要作为超量素材的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local xg=mg:Select(tp,1,ct,nil)
			local tc1=xg:GetFirst()
			while tc1 do
				tc1:CancelToGrave()
				local og=tc1:GetOverlayGroup()
				if #og>0 then
					-- 将作为素材的卡片原本持有的超量素材送去墓地
					Duel.SendtoGrave(og,REASON_RULE)
				end
				tc1=xg:GetNext()
			end
			-- 将选中的卡片重叠在特殊召唤的怪兽下面作为超量素材
			Duel.Overlay(tc,xg)
		end
	end
end
