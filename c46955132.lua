--メルフィー・ラビィーズ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：对方把怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把自己的手卡·场上的怪兽作为融合素材，把1只「童话动物」融合怪兽融合召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「童话动物」怪兽加入手卡。这个效果把通常怪兽加入手卡的场合，可以再从手卡把兽族怪兽任意数量特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 对方把怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把自己的手卡·场上的怪兽作为融合素材，把1只「童话动物」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「童话动物」怪兽加入手卡。这个效果把通常怪兽加入手卡的场合，可以再从手卡把兽族怪兽任意数量特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤对方召唤·特殊召唤的怪兽
function s.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 对方把怪兽召唤·特殊召唤的场合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 特殊召唤效果的发动检测与操作整理
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测自身是否能特殊召唤到怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤不受当前效果影响的融合素材
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤可以进行融合召唤的「童话动物」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x146) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 特殊召唤自身并选择是否进行融合召唤的效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 若这张卡特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 刷新场地信息
		Duel.AdjustAll()
		local chkf=tp
		-- 获取玩家手卡和场上可用的融合素材并过滤
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检测额外卡组是否存在可以融合成的「童话动物」融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检测连锁素材是否能融合召唤「童话动物」融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 若有可融合召唤的怪兽且玩家选择进行融合召唤
		if res and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否融合召唤？"
			-- 获取正常素材可以融合成的「童话动物」融合怪兽组
			local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
			local mg2=nil
			local sg2=nil
			-- 获取连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 获取连锁素材可以融合成的「童话动物」融合怪兽组
				sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
			end
			if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
				local sg=sg1:Clone()
				if sg2 then sg:Merge(sg2) end
				-- 提示玩家选择要特殊召唤的卡片
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				local tc=tg:GetFirst()
				-- 判断是否使用自身手卡场上素材进行融合召唤
				if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
					-- 选择融合素材
					local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
					tc:SetMaterial(mat1)
					-- 将融合素材送去墓地
					Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
					-- 中断当前效果处理
					Duel.BreakEffect()
					-- 将融合怪兽特殊召唤
					Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				elseif ce then
					-- 使用连锁素材效果选择融合素材
					local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
					local fop=ce:GetOperation()
					fop(ce,e,tp,tc,mat2)
				end
				tc:CompleteProcedure()
			end
		end
	end
end
-- 过滤卡组中的「童话动物」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x146) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动检测与操作整理
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在可检索的「童话动物」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索卡组卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤手卡中可以特殊召唤的兽族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索效果的具体处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只「童话动物」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 获取玩家怪兽区域的空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		if g:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
			-- 检测手卡是否存在可特召的兽族怪兽且场上有空位
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and ft>0
			-- 玩家选择是否进行特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择要特殊召唤的兽族怪兽
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
			if sg:GetCount()>0 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 洗切手牌
				Duel.ShuffleHand(tp)
				-- 将选中的怪兽特殊召唤
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
