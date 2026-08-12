--神影金龍ドラッグルクシオン
-- 效果：
-- 8星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从额外卡组特殊召唤的场合才能发动。从卡组把1张「银河」卡或「时空」卡加入手卡。
-- ②：把这张卡2个超量素材取除才能发动。把1只龙族·8阶·攻击力3000的超量怪兽在自己场上的这张卡上面重叠当作超量召唤从额外卡组特殊召唤。那之后，可以从额外卡组把1只「银河」怪兽作为那超量素材。
local s,id,o=GetID()
-- 初始化效果，添加XYZ召唤手续并注册两个效果
function s.initial_effect(c)
	-- 为该卡添加XYZ召唤手续，使用等级为8、数量为2的怪兽作为素材
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
-- 效果条件：确认该卡是从额外卡组特殊召唤的
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- 检索过滤器：筛选「银河」或「时空」卡
function s.thfilter(c)
	return c:IsSetCard(0x7b,0x1b4) and c:IsAbleToHand()
end
-- 设置检索效果的目标信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为检索卡组并加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 设置超量召唤效果的消耗
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- XYZ召唤过滤器：筛选8星龙族XYZ怪兽且攻击力为3000
function s.xyzfilter(c,e,tp,mc)
	return c:IsRank(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:IsAttack(3000)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查是否有足够的额外召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置超量召唤效果的目标信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足成为超量素材的条件
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查是否有满足条件的XYZ怪兽
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息为特殊召唤XYZ怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 叠放过滤器：筛选「银河」怪兽且可作为叠放素材
function s.xfilter(c)
	return c:IsSetCard(0x7b) and c:IsCanOverlay()
end
-- 执行超量召唤效果的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足超量召唤的条件
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) and not c:IsImmuneToEffect(e) and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的XYZ怪兽
		local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
		local tc=g:GetFirst()
		if tc then
			local mg=c:GetOverlayGroup()
			if mg:GetCount()>0 then
				-- 将原卡的叠放素材叠放到新召唤的怪兽上
				Duel.Overlay(tc,mg)
			end
			tc:SetMaterial(Group.FromCards(c))
			-- 将原卡作为叠放素材叠放到新召唤的怪兽上
			Duel.Overlay(tc,Group.FromCards(c))
			-- 特殊召唤XYZ怪兽
			if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
				-- 检查额外卡组是否存在「银河」怪兽
				if Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_EXTRA,0,1,nil)
					-- 询问是否将「银河」怪兽作为超量素材
					and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把1只「银河」怪兽变成超量素材？"
					-- 提示玩家选择要作为超量素材的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
					-- 选择满足条件的「银河」怪兽
					local og=Duel.SelectMatchingCard(tp,s.xfilter,tp,LOCATION_EXTRA,0,1, 1,nil)
					if og:GetCount()>0 then
						-- 中断当前效果处理
						Duel.BreakEffect()
						-- 将选中的「银河」怪兽叠放到目标怪兽上
						Duel.Overlay(tc,og)
					end
				end
				tc:CompleteProcedure()
			end
		end
	end
end
