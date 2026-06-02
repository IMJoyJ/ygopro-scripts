--法の神霊アイワス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡除外才能发动。从卡组把1只「阿莱斯特」怪兽加入手卡。场上发动的场合，可以再进行1只魔法师族怪兽的召唤。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的融合怪兽被战斗以外送去墓地的场合才能发动。这张卡特殊召唤。那之后，可以把自己的手卡·场上的怪兽作为融合素材，把1只「召唤兽」怪兽融合召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册起动效果检索「阿莱斯特」怪兽并可召唤魔法师族怪兽，以及墓地诱发效果特殊召唤并融合召唤「召唤兽」融合怪兽
function s.initial_effect(c)
	-- ①：把手卡·场上的这张卡除外才能发动。从卡组把1只「阿莱斯特」怪兽加入手卡。场上发动的场合，可以再进行1只魔法师族怪兽的召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	-- 将手卡或场上的自身除外作为发动的Cost
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的融合怪兽被战斗以外送去墓地的场合才能发动。这张卡特殊召唤。那之后，可以把自己的手卡·场上的怪兽作为融合素材，把1只「召唤兽」怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤可检索的「阿莱斯特」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x1e1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义检索效果的对象选择与操作信息注册函数，并在卡片从场上除外发动时设置Label为1
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前验证卡组中是否存在可检索的「阿莱斯特」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	if e:GetHandler():IsPreviousLocation(LOCATION_MZONE) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 设置效果处理的操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤可通常召唤的魔法师族怪兽
function s.sumfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsSummonable(true,nil)
end
-- 定义检索效果的执行操作函数，若在场上发动则可追加进行1只魔法师族怪兽的召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的「阿莱斯特」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「阿莱斯特」怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的怪兽卡以供确认
		Duel.ConfirmCards(1-tp,g)
		-- 检查手牌或场上是否存在可召唤的魔法师族怪兽
		if Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			and e:GetLabel()==1
			-- 询问玩家是否要追加进行魔法师族怪兽的召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否进行召唤？"
			-- 中断效果处理步骤以进入召唤的执行结算流程
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的魔法师族怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 从手牌或场上选择1只符合召唤条件的魔法师族怪兽
			local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
			if tc then
				-- 将选择卡片的玩家的手牌洗切
				Duel.ShuffleHand(tp)
				-- 以忽略召唤次数限制的规则将选择的魔法师族怪兽通常召唤
				Duel.Summon(tp,tc,true,nil)
			end
		end
	end
end
-- 过滤被战斗以外送去墓地且原先在场上表侧表示存在的融合怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and not c:IsReason(REASON_BATTLE)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 定义特殊召唤效果的发动条件函数，确认发生了自己场上表侧表示融合怪兽因战斗以外送去墓地且不包含自身
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 定义特殊召唤与后续融合召唤效果的对象选择与操作信息注册函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区域有空位且本卡在墓地可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的操作信息为特殊召唤墓地中的自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤未受效果影响的卡片
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤可融合召唤的「召唤兽」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xf4) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义特殊召唤与融合召唤效果的执行处理操作函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡目前依然与当前连锁关系相符且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将墓地中的本卡特殊召唤到自己场上
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 立即刷新场地的所有相关状态信息
		Duel.AdjustAll()
		local chkf=tp
		-- 获取融合召唤可用的全部融合素材并过滤去受影响的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检测以常规方式是否能够融合召唤「召唤兽」融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的外部连锁融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检测在外部融合效果影响下是否能融合召唤「召唤兽」融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 询问玩家在成功特殊召唤本卡后，是否选择继续进行融合召唤
		if res and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否融合召唤？"
			-- 中断特殊召唤效果的动作，以进入融合召唤的特殊处理和结算流程
			Duel.BreakEffect()
			-- 洗切特殊召唤本卡玩家的手牌
			Duel.ShuffleHand(tp)
			-- 获取常规融合素材下可以融合召唤的额外卡组「召唤兽」融合怪兽群
			local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
			local mg2=nil
			local sg2=nil
			-- 获取存在外部连锁融合素材效果时所拥有的素材卡片组
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 获取使用外部连锁融合素材时可以融合召唤的额外卡组「召唤兽」融合怪兽群
				sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
			end
			if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
				local sg=sg1:Clone()
				if sg2 then sg:Merge(sg2) end
				-- 提示玩家选择要融合召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				local tc=tg:GetFirst()
				-- 判断选择的怪兽是否能够通过常规融合方式进行召唤，或若满足多种融合方式时是否选择不用外部连锁效果
				if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
					-- 为选定的融合怪兽选择符合要求的融合素材
					local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
					tc:SetMaterial(mat1)
					-- 将选定的融合素材怪兽送去墓地
					Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
					-- 中断效果处理步骤，以进行融合特殊召唤结算
					Duel.BreakEffect()
					-- 把选择的「召唤兽」融合怪兽进行融合召唤特殊召唤上场
					Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				elseif ce then
					-- 为选择的融合怪兽在外部连锁素材效果下挑选融合素材
					local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
					local fop=ce:GetOperation()
					fop(ce,e,tp,tc,mat2)
				end
				tc:CompleteProcedure()
			end
		end
	end
end
