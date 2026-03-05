--サブテラーの戦士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「地中族」怪兽送去墓地才能发动。原本等级合计直到变成那只「地中族」怪兽的等级以上为止，把这张卡和自己场上的怪兽1只以上解放，把那只「地中族」怪兽表侧守备表示或者里侧守备表示从墓地特殊召唤。这个效果在对方回合也能发动。
-- ②：自己场上的「地中族邪界」怪兽反转的场合才能发动（伤害步骤也能发动）。墓地的这张卡特殊召唤。
function c16719140.initial_effect(c)
	-- ①：从卡组把1只「地中族」怪兽送去墓地才能发动。原本等级合计直到变成那只「地中族」怪兽的等级以上为止，把这张卡和自己场上的怪兽1只以上解放，把那只「地中族」怪兽表侧守备表示或者里侧守备表示从墓地特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16719140,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,16719140)
	e1:SetCost(c16719140.spcost)
	e1:SetTarget(c16719140.sptg1)
	e1:SetOperation(c16719140.spop1)
	c:RegisterEffect(e1)
	-- ②：自己场上的「地中族邪界」怪兽反转的场合才能发动（伤害步骤也能发动）。墓地的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16719140,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FLIP)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,16719141)
	e2:SetCondition(c16719140.spcon)
	e2:SetTarget(c16719140.sptg2)
	e2:SetOperation(c16719140.spop2)
	c:RegisterEffect(e2)
end
-- 设置效果标记为100，表示该效果已准备就绪。
function c16719140.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 检查目标怪兽是否满足作为代价的条件：等级大于等于0、属于地中族、是怪兽卡、可以送去墓地、可以特殊召唤为守备表示。
function c16719140.costfilter(c,e,tp,mg,rlv,mc)
	if not (c:IsLevelAbove(0) and c:IsSetCard(0xed) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)) then return false end
	return mg:CheckSubGroup(c16719140.fselect,1,c:GetLevel(),tp,c:GetLevel()-rlv,mc)
end
-- 检查目标怪兽组是否满足等级合计条件，用于判断是否可以解放足够的怪兽来满足召唤条件。
function c16719140.fselect(g,tp,lv,mc)
	local mg=g:Clone()
	mg:AddCard(mc)
	-- 判断目标怪兽组是否能放入怪兽区域。
	if Duel.GetMZoneCount(tp,mg)>0 then
		if lv<=0 then
			return g:GetCount()==1
		else
			-- 设置当前选择的卡片组，用于后续的等级合计判断。
			Duel.SetSelectedCard(g)
			return g:CheckWithSumGreater(Card.GetOriginalLevel,lv)
		end
	else return false end
end
-- 过滤条件：检查目标怪兽是否等级大于等于1。
function c16719140.relfilter(c)
	return c:IsLevelAbove(1)
end
-- 设置效果的发动条件：检查是否满足发动条件，包括是否为100标记、是否满足等级要求、是否可以解放怪兽、是否在卡组中存在满足条件的怪兽。
function c16719140.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家可解放的怪兽组。
	local mg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(c16719140.relfilter,c)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if not c:IsLevelAbove(1) or not c:IsReleasableByEffect() or mg:GetCount()==0 then return false end
		-- 检查卡组中是否存在满足条件的「地中族」怪兽。
		return Duel.IsExistingMatchingCard(c16719140.costfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mg,c:GetOriginalLevel(),c)
	end
	e:SetLabel(0)
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽并将其送去墓地。
	local g=Duel.SelectMatchingCard(tp,c16719140.costfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mg,c:GetOriginalLevel(),c)
	-- 将选中的怪兽送去墓地作为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
	-- 设置当前效果的目标为选中的怪兽。
	Duel.SetTargetCard(g)
	-- 设置效果操作信息，表示将特殊召唤1只怪兽到墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行效果的处理流程：获取目标怪兽、检查是否满足特殊召唤条件、选择要解放的怪兽、进行解放操作、特殊召唤目标怪兽。
function c16719140.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	-- 获取玩家可解放的怪兽组。
	local mg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(c16719140.relfilter,c)
	if mg:GetCount()==0 then return end
	-- 检查目标怪兽是否不受王家长眠之谷影响且可以特殊召唤为守备表示。
	if aux.NecroValleyFilter()(tc) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE) then
		-- 提示玩家选择要解放的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local g=mg:SelectSubGroup(tp,c16719140.fselect,false,1,tc:GetLevel(),tp,tc:GetLevel()-c:GetOriginalLevel(),c)
		if g and g:GetCount()>0 then
			g:AddCard(c)
			-- 执行解放操作，如果成功则继续特殊召唤。
			if Duel.Release(g,REASON_EFFECT)~=0 then
				-- 将目标怪兽特殊召唤到场上。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)
				if tc:IsFacedown() then
					-- 确认对方是否能看到目标怪兽。
					Duel.ConfirmCards(1-tp,tc)
				end
			end
		end
	end
end
-- 过滤条件：检查目标怪兽是否为「地中族邪界」且为玩家控制。
function c16719140.cfilter(c,tp)
	return c:IsSetCard(0x10ed) and c:IsControler(tp)
end
-- 判断是否满足发动条件：场上是否有「地中族邪界」怪兽被反转。
function c16719140.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16719140.cfilter,1,nil,tp)
end
-- 设置效果的发动条件：检查是否满足特殊召唤条件。
function c16719140.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果操作信息，表示将特殊召唤1只怪兽到场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果的处理流程：检查是否满足特殊召唤条件、进行特殊召唤操作。
function c16719140.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
