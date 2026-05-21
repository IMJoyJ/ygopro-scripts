--超量士ブラックレイヤー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：对方把怪兽的效果发动时才能发动。从自己手卡选1张其他卡丢弃，这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。把1只「超级量子机兽」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤，从自己墓地把1只「超级量子」怪兽作为那超量素材。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把1张「超级量子」魔法卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特召，②特召成功时重叠超量召唤，③送墓检索「超级量子」魔法卡。
function s.initial_effect(c)
	-- ①：对方把怪兽的效果发动时才能发动。从自己手卡选1张其他卡丢弃，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。把1只「超级量子机兽」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤，从自己墓地把1只「超级量子」怪兽作为那超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"超量召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把1张「超级量子」魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：对方发动了怪兽的效果。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤条件：手卡中可以因效果丢弃的卡。
function s.cfilter(c)
	return c:IsDiscardable(REASON_EFFECT)
end
-- 效果①的发动准备与合法性检查。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在除这张卡以外可以丢弃的卡。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置连锁信息：包含特殊召唤自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：丢弃1张手卡，将这张卡特殊召唤。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取手卡中除这张卡以外可以丢弃的卡片组。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,aux.ExceptThisCard(e))
	-- 提示玩家选择要丢弃的手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 若成功将选中的卡丢弃，且这张卡仍在连锁中。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)>0 and c:IsRelateToChain() then
		-- 将这张卡在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：额外卡组中可以以这张卡为素材进行超量召唤的「超级量子机兽」超量怪兽。
function s.spfilter(c,e,tp,mc)
	return c:IsSetCard(0x20dc) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以超量召唤，以及额外怪兽区域或可用怪兽区域是否有空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 过滤条件：墓地中可以作为超量素材的「超级量子」怪兽。
function s.mtfilter(c,e)
	return c:IsSetCard(0xdc) and c:IsType(TYPE_MONSTER)
		and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果②的发动准备与合法性检查。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查这张卡是否必须作为特定超量素材的限制。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在可以重叠在自身之上特殊召唤的「超级量子机兽」超量怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 检查自己墓地是否存在可以作为超量素材的「超级量子」怪兽。
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_GRAVE,0,1,nil,e) end
	-- 设置连锁信息：包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理：将「超级量子机兽」超量怪兽重叠在自身上方特殊召唤，并从墓地补充1个素材。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查必须作为超量素材的限制，若不满足则不处理。
	if not aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if c:IsFaceup() and c:IsRelateToChain() and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
		-- 提示玩家选择要特殊召唤的超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从额外卡组选择1只满足条件的「超级量子机兽」超量怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local sc=g:GetFirst()
		if sc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将这张卡原本持有的超量素材转移给新特殊召唤的超量怪兽。
				Duel.Overlay(sc,mg)
			end
			sc:SetMaterial(Group.FromCards(c))
			-- 将这张卡重叠在新特殊召唤的超量怪兽下方作为超量素材。
			Duel.Overlay(sc,Group.FromCards(c))
			-- 将该超量怪兽当作超量召唤在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
			-- 提示玩家选择要作为超量素材的墓地怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			-- 玩家从墓地选择1只「超级量子」怪兽（受王家之谷影响）。
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
			if sg:GetCount()>0 then
				-- 将选中的墓地怪兽重叠作为该超量怪兽的超量素材。
				Duel.Overlay(sc,sg)
			end
		end
	end
end
-- 过滤条件：卡组中可以加入手卡的「超级量子」魔法卡。
function s.thfilter(c)
	return c:IsSetCard(0xdc) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果③的发动准备与合法性检查。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「超级量子」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：包含从卡组将1张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的处理：从卡组将1张「超级量子」魔法卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张「超级量子」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
