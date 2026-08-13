--サブテラーの戦士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「地中族」怪兽送去墓地才能发动。原本等级合计直到变成那只「地中族」怪兽的等级以上为止，把这张卡和自己场上的怪兽1只以上解放，把那只「地中族」怪兽表侧守备表示或者里侧守备表示从墓地特殊召唤。这个效果在对方回合也能发动。
-- ②：自己场上的「地中族邪界」怪兽反转的场合才能发动（伤害步骤也能发动）。墓地的这张卡特殊召唤。
function c16719140.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从卡组把1只「地中族」怪兽送去墓地才能发动。原本等级合计直到变成那只「地中族」怪兽的等级以上为止，把这张卡和自己场上的怪兽1只以上解放，把那只「地中族」怪兽表侧守备表示或者里侧守备表示从墓地特殊召唤。这个效果在对方回合也能发动。
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
-- 效果发动代价的预检查：将效果标签设为100，标记已完成代价检查，且不在此处实际支付；实际代价在目标选择阶段将卡组怪兽送入墓地。
function c16719140.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 筛选可作为代价的「地中族」怪兽：需为等级1以上、卡名属于「地中族」的怪兽卡，可从卡组作为代价送入墓地，并能被本效果以守备表示特殊召唤；同时还需存在一组可解放的怪兽（最终还要加上本卡一起解放）通过解放后能空出怪兽区且原等级合计达到该怪兽等级以上。
function c16719140.costfilter(c,e,tp,mg,rlv,mc)
	if not (c:IsLevelAbove(0) and c:IsSetCard(0xed) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)) then return false end
	return mg:CheckSubGroup(c16719140.fselect,1,c:GetLevel(),tp,c:GetLevel()-rlv,mc)
end
-- 判断选出的额外解放组g是否合法：将本卡mc加入后，若解放这些卡仍能空出怪兽区；若本卡等级已足够，则g只需包含1只怪兽；否则g的怪兽原等级合计需达到补足等级，并用CheckWithSumGreater进行累计判定。
function c16719140.fselect(g,tp,lv,mc)
	local mg=g:Clone()
	mg:AddCard(mc)
	-- 检查这些候选解放的怪兽（含本卡）被解放后，自己场上是否仍有怪兽区空格，以保证后续特殊召唤有位置可用。
	if Duel.GetMZoneCount(tp,mg)>0 then
		if lv<=0 then
			return g:GetCount()==1
		else
			-- 将当前候选解放组设为“已选择卡片”，使后续CheckWithSumGreater在进行等级合计时以此为基准。
			Duel.SetSelectedCard(g)
			return g:CheckWithSumGreater(Card.GetOriginalLevel,lv)
		end
	else return false end
end
-- 筛选可解放对象：只允许解放等级1以上的怪兽（等级为0的怪兽无法用于凑等级）。
function c16719140.relfilter(c)
	return c:IsLevelAbove(1)
end
-- 效果①的发动条件检查与发动处理：先确认已进行过代价检查且本卡可被解放、有可解放的等级1以上怪兽、卡组有符合条件的「地中族」怪兽；满足后选择卡组1只「地中族」怪兽送入墓地作为代价，并将其设为对象，同时登记特殊召唤的操作信息。
function c16719140.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取我方场上当前可用于效果解放的等级1以上怪兽组，并排除本卡（本卡将单独作为解放对象之一）。
	local mg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(c16719140.relfilter,c)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if not c:IsLevelAbove(1) or not c:IsReleasableByEffect() or mg:GetCount()==0 then return false end
		-- 检查卡组中是否存在至少1只满足costfilter的「地中族」怪兽，即既能作为代价送墓，又能通过解放补足等级后被特殊召唤。
		return Duel.IsExistingMatchingCard(c16719140.costfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mg,c:GetOriginalLevel(),c)
	end
	e:SetLabel(0)
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足costfilter的「地中族」怪兽，作为发动代价送去墓地。
	local g=Duel.SelectMatchingCard(tp,c16719140.costfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mg,c:GetOriginalLevel(),c)
	-- 将选择的「地中族」怪兽以代价形式送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
	-- 将送入墓地的这只「地中族」怪兽设为当前连锁的效果对象，便于处理阶段获取。
	Duel.SetTargetCard(g)
	-- 设置操作信息：本次效果将从墓地特殊召唤1只怪兽，预定特殊召唤的持有者为tp，来源位置为墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的结算处理：确认本卡和对象怪兽仍与效果关联后，重新获取可解放怪兽组，并在对象不受墓地效果限制且能被守备表示特殊召唤时，让玩家选择额外解放怪兽，连同本卡一起解放；解放成功后将对象「地中族」怪兽以守备表示特殊召唤，若为里侧表示则由对方确认。
function c16719140.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时被送入墓地的「地中族」怪兽对象卡。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	-- 结算时再次获取我方场上可用于效果解放的等级1以上怪兽组，并且不包含本卡。
	local mg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT):Filter(c16719140.relfilter,c)
	if mg:GetCount()==0 then return end
	-- 检查对象怪兽是否不受王家长眠之谷等干扰墓地特殊召唤的效果影响，且能被当前效果以守备表示特殊召唤。
	if aux.NecroValleyFilter()(tc) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE) then
		-- 向玩家显示“请选择要解放的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local g=mg:SelectSubGroup(tp,c16719140.fselect,false,1,tc:GetLevel(),tp,tc:GetLevel()-c:GetOriginalLevel(),c)
		if g and g:GetCount()>0 then
			g:AddCard(c)
			-- 解放选择的怪兽组（含本卡）；若实际解放成功（返回不为0）才继续特殊召唤。
			if Duel.Release(g,REASON_EFFECT)~=0 then
				-- 将对象「地中族」怪兽以守备表示特殊召唤到自己场上。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)
				if tc:IsFacedown() then
					-- 如果特殊召唤的是里侧守备表示怪兽，则向对方玩家确认该怪兽的信息。
					Duel.ConfirmCards(1-tp,tc)
				end
			end
		end
	end
end
-- 筛选反转怪兽中是否有属于「地中族邪界」字段且控制者是自己场上的怪兽。
function c16719140.cfilter(c,tp)
	return c:IsSetCard(0x10ed) and c:IsControler(tp)
end
-- 效果②的发动条件：当自己场上的「地中族邪界」怪兽反转时满足触发条件。
function c16719140.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16719140.cfilter,1,nil,tp)
end
-- 效果②的发动检查：自己怪兽区有空位，且墓地的这张卡能够被特殊召唤；无对象选择操作。
function c16719140.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查时，确认自己场上还有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将把墓地的这张卡特殊召唤到自己场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的结算处理：若这张卡仍在墓地且与效果关联，则将其从墓地特殊召唤。
function c16719140.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地的这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
