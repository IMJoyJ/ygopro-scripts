--神影金龍ドラッグルクシオン
-- 效果：
-- 8星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从额外卡组特殊召唤的场合才能发动。从卡组把1张「银河」卡或「时空」卡加入手卡。
-- ②：把这张卡2个超量素材取除才能发动。把1只龙族·8阶·攻击力3000的超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。那之后，可以从额外卡组把1只「银河」怪兽作为那超量素材。
local s,id,o=GetID()
-- 定义该卡的初始化函数，为其添加超量召唤手续（8星怪兽×2）与苏生限制，并注册①检索效果和②叠放超量召唤效果。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：需要2只8星怪兽作为超量素材（不额外限制素材条件）。
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：这张卡从额外卡组特殊召唤的场合才能发动。从卡组把1张「银河」卡或「时空」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把这张卡2个超量素材取除才能发动。把1只龙族·8阶·攻击力3000的超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。那之后，可以从额外卡组把1只「银河」怪兽作为那超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"叠放特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：检查这张卡是否从额外卡组特殊召唤成功。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 定义检索过滤器：满足「银河」或「时空」字段，且能够加入手卡的卡片。
function s.thfilter(c)
	return c:IsSetCard(0x7b,0x1b4) and c:IsAbleToHand()
end
-- ①效果的目标判定：确认卡组存在符合条件的检索卡，并登记本次效果将把卡从卡组加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认卡组中至少存在1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向连锁系统登记本次效果包含从卡组将1张卡加入手卡的处理。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果：从卡组选择1张「银河」或「时空」卡加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动玩家弹出“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从卡组中选择1张满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动代价：从这张卡上取除2个超量素材（作为COST）。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 筛选可特殊召唤的额外卡组怪兽：龙族、8阶、攻击力3000的超量怪兽，且当前卡可作为其超量素材，并满足超量召唤条件和额外怪兽区空格要求。
function s.xyzfilter(c,e,tp,mc)
	return c:IsRank(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsAttack(3000)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 额外卡组的怪兽特殊召唤前，确认在将当前卡作为素材使用后，场上仍有可供额外卡组怪兽出场的空格。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果的目标判定：确认这张卡可作为超量素材，且额外卡组存在至少1只符合条件的可特殊召唤怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查这张卡是否受到“必须作为超量素材”等无法作为素材的限制效果影响。
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 确认额外卡组存在至少1只满足条件的怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 登记本次效果包含从额外卡组进行特殊召唤的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义追加素材的筛选条件：是「银河」字段且可以作为超量素材叠放的卡片。
function s.xfilter(c)
	return c:IsSetCard(0x7b) and c:IsCanOverlay()
end
-- 执行②效果：把当前卡的素材转移给目标怪兽，并将当前卡自身作为素材叠放，再以超量召唤方式特殊召唤目标怪兽；成功后询问是否追加1只「银河」怪兽作为素材。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时确认：这张卡仍表侧表示、与效果仍有关联、由本玩家控制、不免疫该效果，且未受“必须作为超量素材”限制。
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then
		-- 给玩家弹出“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只符合条件的龙族·8阶·攻击力3000的超量怪兽。
		local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local tc=g:GetFirst()
		if tc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()>0 then
				-- 把当前卡原有的超量素材全部转移叠放到目标怪兽下面。
				Duel.Overlay(tc,mg)
			end
			tc:SetMaterial(Group.FromCards(c))
			-- 把当前卡自身作为超量素材叠放到目标怪兽下面。
			Duel.Overlay(tc,Group.FromCards(c))
			-- 以超量召唤方式将目标怪兽表侧表示特殊召唤到本玩家场上，并判断是否召唤成功。
			if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
				-- 检查额外卡组是否存在至少1只可作为追加素材的「银河」怪兽。
				if Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_EXTRA,0,1,nil)
					-- 询问玩家是否从额外卡组把1只「银河」怪兽作为追加超量素材。
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把1只「银河」怪兽变成超量素材？"
					-- 给玩家弹出“请选择要作为超量素材的卡”的提示。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
					-- 让玩家从额外卡组选择1只可作为追加素材的「银河」怪兽。
					local og=Duel.SelectMatchingCard(tp,s.xfilter,tp,LOCATION_EXTRA,0,1, 1,nil)
					if og:GetCount()>0 then
						-- 中断当前效果连锁，使后续的追加素材叠放处理在规则上被视为另一段处理，避免错过时点。
						Duel.BreakEffect()
						-- 将选中的「银河」怪兽作为超量素材叠放到目标怪兽下面。
						Duel.Overlay(tc,og)
					end
				end
				tc:CompleteProcedure()
			end
		end
	end
end
