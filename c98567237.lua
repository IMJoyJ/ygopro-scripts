--刻まれし魔の詠聖
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只恶魔族·光属性怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册卡片效果：①卡组检索恶魔族·光属性怪兽并丢弃1张手牌；②墓地除外自身进行「刻魔」融合怪兽的融合召唤。
function s.initial_effect(c)
	-- ①：从卡组把1只恶魔族·光属性怪兽加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 把墓地的这张卡除外作为发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 过滤卡组中可检索的恶魔族·光属性怪兽。
function s.filter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果①（检索并丢弃）的发动准备与效果分类确定。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可检索的恶魔族·光属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将卡组的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 效果①（检索并丢弃）的处理逻辑。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只满足条件的恶魔族·光属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功将选中的怪兽加入手牌。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的手牌。
		Duel.ShuffleHand(tp)
		-- 中断当前效果，使后续的丢弃手牌处理不与检索同时进行（错时点）。
		Duel.BreakEffect()
		-- 玩家选择并丢弃1张手牌。
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	end
end
-- 过滤不受效果影响的怪兽（融合素材不能免疫效果）。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「刻魔」融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1b0) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果②（融合召唤）的发动准备与可行性检查。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手牌和场上可用的融合素材。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前素材融合召唤的「刻魔」融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在受「连锁素材」等效果影响的融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用「连锁素材」等效果的素材时，是否能融合召唤「刻魔」融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②（融合召唤）的处理逻辑。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家手牌和场上可用且不免疫此效果的融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的「刻魔」融合怪兽集合。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的「连锁素材」等效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在使用「连锁素材」等效果的素材时，可以融合召唤的「刻魔」融合怪兽集合。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规的手牌·场上素材进行融合召唤（而非「连锁素材」等效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 玩家选择用于融合召唤该怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使送去墓地与特殊召唤不视为同时进行。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 玩家选择使用「连锁素材」等效果提供的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
