--マグマッチョ・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把最多3只炎属性怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外数量×400。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的炎属性怪兽被效果破坏的场合才能发动。这张卡特殊召唤。那之后，自己抽1张。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c50951254.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从自己墓地把最多3只炎属性怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50951254,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50951254)
	e1:SetCost(c50951254.atkcost)
	e1:SetOperation(c50951254.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的炎属性怪兽被效果破坏的场合才能发动。这张卡特殊召唤。那之后，自己抽1张。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50951254,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,86346363)
	e2:SetCondition(c50951254.spcon)
	e2:SetTarget(c50951254.sptg)
	e2:SetOperation(c50951254.spop)
	c:RegisterEffect(e2)
end
-- 代价筛选函数：判断墓地里的怪兽是否为炎属性且可以作为代价除外，用于从自己墓地选择可除外的炎属性怪兽。
function c50951254.costfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价处理：确认墓地存在符合条件的炎属性怪兽后，提示玩家选择1~3张，将其表侧除外作为代价，并把实际除外的数量记录到效果标签，供后续攻击力上升使用。
function c50951254.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：墓地中必须存在至少1只满足代价筛选条件的炎属性怪兽，才允许发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c50951254.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示“请选择要除外的卡”的选择提示，引导玩家从墓地选择要除外的炎属性怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 获取自己墓地中所有满足代价筛选条件的炎属性怪兽，作为本次代价的可选集合。
	local g=Duel.GetMatchingGroup(c50951254.costfilter,tp,LOCATION_GRAVE,0,nil)
	local sg=g:Select(tp,1,3,nil)
	-- 将玩家选中的墓地的炎属性怪兽以表侧表示除外作为代价，并把实际除外的数量存入效果标签。
	e:SetLabel(Duel.Remove(sg,POS_FACEUP,REASON_COST))
end
-- ①效果处理：若本卡仍表侧表示且与发动效果关联，则给它附加攻击力上升效果，上升数值为除外数量×400，持续到回合结束。
function c50951254.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升除外数量×400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- ②效果诱发条件过滤：判断被破坏的怪兽是否满足破坏前在我方场上表侧表示、属性为炎、位于怪兽区且因效果被破坏。
function c50951254.sfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_FIRE)~=0
		and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- ②效果发动条件：本次被破坏的怪兽中存在至少1只满足条件的我方表侧炎属性怪兽，且被破坏的怪兽中不包含墓地中的这张卡自身。
function c50951254.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50951254.sfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ②效果的发动目标与操作信息登记：确认自己场上有空余怪兽区且墓地的此卡可特殊召唤，然后登记本连锁将抽1张卡并将此卡特殊召唤。
function c50951254.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：自己场上存在可用怪兽区域，且墓地的这张卡能够特殊召唤，才允许发动②效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本连锁处理中自己将抽1张卡（对应“那之后，自己抽1张”）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 登记操作信息：本连锁处理中会将墓地中的这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：若此卡仍与效果关联，则将其从墓地特殊召唤；成功后给它附加“从场上离开时改为除外”的效果（不可被无效），然后使自己抽1张卡。
function c50951254.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与效果关联后，将其从墓地以表侧表示特殊召唤到自己怪兽区；特殊召唤成功（返回值非0）时才继续附加离场除外效果和抽卡。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 那之后，自己抽1张。这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 执行抽卡：自己抽1张卡，作为②效果中“那之后，自己抽1张”的处理。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
