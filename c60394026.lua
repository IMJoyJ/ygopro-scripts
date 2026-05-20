--ライゼオル・プラグイン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己的墓地·除外状态的1只超量怪兽或「雷火沸动」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从卡组把1张「雷火沸动」卡作为自己场上1只4阶超量怪兽的超量素材。这个回合，自己不用4阶超量怪兽不能攻击宣言。
local s,id,o=GetID()
-- 注册卡片发动时的效果：1回合只能发动1张，选择墓地或除外的超量怪兽或「雷火沸动」怪兽特殊召唤，之后可将卡组的「雷火沸动」卡作为场上4阶超量怪兽的素材，并施加攻击限制。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己的墓地·除外状态的1只超量怪兽或「雷火沸动」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从卡组把1张「雷火沸动」卡作为自己场上1只4阶超量怪兽的超量素材。这个回合，自己不用4阶超量怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤墓地或除外状态的、可以特殊召唤的「雷火沸动」怪兽或超量怪兽。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and (c:IsSetCard(0x1be) or c:IsType(TYPE_XYZ))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的靶向检测，检查是否存在可特殊召唤的合法目标，并进行取对象操作。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的墓地或除外状态是否存在至少1只满足特殊召唤条件的合法怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择墓地或除外状态的1只合法怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁处理信息，表明该效果包含特殊召唤该对象的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤场上表侧表示的4阶超量怪兽，且卡组中存在可以作为其超量素材的「雷火沸动」卡。
function s.xyzfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(4)
		-- 检查卡组中是否存在至少1张可以作为超量素材的「雷火沸动」卡。
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_DECK,0,1,nil,e)
end
-- 过滤卡组中可以作为超量素材叠放的「雷火沸动」卡。
function s.mtfilter(c,e)
	return c:IsSetCard(0x1be)
		and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果处理的核心逻辑：特殊召唤对象怪兽，之后可选择场上1只4阶超量怪兽，将卡组中的1张「雷火沸动」卡重叠在其下方作为超量素材。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为特殊召唤对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关联、是否受王家之谷影响，并将其以表侧表示特殊召唤。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己场上是否存在可以塞素材的4阶超量怪兽。
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 询问玩家是否要执行“从卡组把1张「雷火沸动」卡作为超量素材”的后续效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否获取超量素材？"
		-- 中断当前效果处理，使特殊召唤与重叠超量素材的处理不视为同时进行。
		Duel.BreakEffect()
		-- 玩家选择场上1只表侧表示的4阶超量怪兽作为重叠素材的对象。
		local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		local xc=g:GetFirst()
		-- 提示玩家选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 玩家从卡组选择1张「雷火沸动」卡。
		local mg=Duel.SelectMatchingCard(tp,s.mtfilter,tp,LOCATION_DECK,0,1,1,nil,e)
		if mg:GetCount()>0 then
			-- 将选中的卡作为超量素材重叠在选中的超量怪兽下方。
			Duel.Overlay(xc,mg)
		end
	end
	-- 这个回合，自己不用4阶超量怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该攻击限制效果给玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤不能进行攻击宣言的怪兽（非4阶超量怪兽）。
function s.atktg(e,c)
	return not (c:IsType(TYPE_XYZ) and c:IsRank(4))
end
