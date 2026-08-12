--No.39 希望皇ホープ・ダブル
-- 效果：
-- 4星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方回合，把这张卡1个超量素材取除才能发动。从卡组把1张「翻倍机会」加入手卡。那之后，「No.39 希望皇 霍普·翻倍」以外的1只「希望皇 霍普」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽的攻击力变成2倍，不能直接攻击。
function c62517849.initial_effect(c)
	-- 设置超量召唤手续：4星怪兽2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，把这张卡1个超量素材取除才能发动。从卡组把1张「翻倍机会」加入手卡。那之后，「No.39 希望皇 霍普·翻倍」以外的1只「希望皇 霍普」超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。这个效果特殊召唤的怪兽的攻击力变成2倍，不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62517849,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,62517849)
	e1:SetCost(c62517849.spcost)
	e1:SetTarget(c62517849.sptg)
	e1:SetOperation(c62517849.spop)
	c:RegisterEffect(e1)
end
-- 设置该怪兽的「No.」数值为39
aux.xyz_number[62517849]=39
-- 效果发动的代价：把这张卡1个超量素材取除
function c62517849.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：卡名为「翻倍机会」且能加入手卡
function c62517849.thfilter(c)
	return c:IsCode(94770493) and c:IsAbleToHand()
end
-- 过滤条件：额外卡组中除「No.39 希望皇 霍普·翻倍」以外的「希望皇 霍普」超量怪兽，且能以当前卡为素材进行超量召唤
function c62517849.spfilter(c,e,tp,mc)
	return not c:IsCode(62517849) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x107f) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能以超量召唤的方式特殊召唤，且额外怪兽区域或可用的主怪兽区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动的目标：检查卡组中是否存在「翻倍机会」，自身是否满足超量素材限制，以及额外卡组是否存在可特殊召唤的「希望皇 霍普」超量怪兽
function c62517849.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手卡的「翻倍机会」
	if chk==0 then return Duel.IsExistingMatchingCard(c62517849.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查自身是否受到必须作为超量素材等效果的限制
		and aux.MustMaterialCheck(e:GetHandler(),tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在满足特殊召唤条件的「希望皇 霍普」超量怪兽
		and Duel.IsExistingMatchingCard(c62517849.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：将「翻倍机会」加入手卡，之后将额外卡组的「希望皇 霍普」超量怪兽在自身重叠超量召唤，并使其攻击力翻倍且不能直接攻击
function c62517849.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张「翻倍机会」
	local g1=Duel.SelectMatchingCard(tp,c62517849.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g1:GetCount()==0 then return end
	-- 将选择的卡加入手卡
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	-- 让对方玩家确认加入手卡的卡
	Duel.ConfirmCards(1-tp,g1)
	local c=e:GetHandler()
	-- 检查自身是否满足作为超量素材的限制
	if aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then
		if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家从额外卡组选择1只满足条件的「希望皇 霍普」超量怪兽
			local g=Duel.SelectMatchingCard(tp,c62517849.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
			local sc=g:GetFirst()
			if sc then
				-- 划分效果处理时点，使后续的特殊召唤处理与加入手卡不视为同时进行
				Duel.BreakEffect()
				local mg=c:GetOverlayGroup()
				if mg:GetCount()~=0 then
					-- 将这张卡原本持有的超量素材转移给新特殊召唤的超量怪兽
					Duel.Overlay(sc,mg)
				end
				sc:SetMaterial(Group.FromCards(c))
				-- 将这张卡重叠作为新特殊召唤怪兽的超量素材
				Duel.Overlay(sc,Group.FromCards(c))
				-- 尝试将选择的超量怪兽以超量召唤的形式表侧表示特殊召唤
				if Duel.SpecialSummonStep(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP) then
					-- 这个效果特殊召唤的怪兽的攻击力变成2倍
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_SET_ATTACK)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					e1:SetValue(sc:GetAttack()*2)
					sc:RegisterEffect(e1)
					-- 不能直接攻击
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e2)
				end
				-- 完成特殊召唤的流程
				Duel.SpecialSummonComplete()
				sc:CompleteProcedure()
			end
		end
	end
end
