--融合募兵
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡，把额外卡组1只融合怪兽给对方观看才能发动。除为这个效果发动而丢弃的卡外的1只在给人观看的怪兽有卡名记述的融合素材怪兽从自己的卡组·墓地加入手卡。这个效果把通常怪兽加入手卡的场合，可以再把另1只加入手卡。这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：丢弃1张手卡，把额外卡组1只融合怪兽给对方观看才能发动。除为这个效果发动而丢弃的卡外的1只在给人观看的怪兽有卡名记述的融合素材怪兽从自己的卡组·墓地加入手卡。这个效果把通常怪兽加入手卡的场合，可以再把另1只加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的代价（Cost）判定与执行函数
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以展示的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
		-- 检查手卡中是否存在除这张卡以外可以丢弃的卡
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 获取额外卡组中所有满足展示条件的融合怪兽
	local exg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil,tp)
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	-- 获取刚刚被丢弃的手卡
	local og=Duel.GetOperatedGroup()
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local cg=exg:Select(tp,1,1,nil)
	-- 将选中的融合怪兽给对方确认
	Duel.ConfirmCards(1-tp,cg)
	og:Merge(cg)
	e:SetLabelObject(og)
	og:KeepAlive()
end
-- 过滤额外卡组中可展示融合怪兽的条件函数
function s.cfilter(c,tp)
	-- 过滤条件：是融合怪兽，且卡组或墓地存在该怪兽记述的融合素材
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
-- 过滤要加入手卡的融合素材的条件函数
function s.thfilter(c,fc)
	-- 过滤条件：卡名被记述在融合怪兽的素材列表中，且可以加入手卡
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsAbleToHand()
end
-- 效果发动的目标（Target）判定与处理函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	local og=e:GetLabelObject()
	-- 从操作卡片组中筛选出非融合怪兽（即作为代价丢弃的手卡）
	local tc=og:Filter(aux.NOT(Card.IsType),nil,TYPE_FUSION):GetFirst()
	-- 将丢弃的手卡设为效果处理的目标（用于后续排除）
	Duel.SetTargetCard(tc)
	-- 从操作卡片组中筛选出展示的融合怪兽并保存
	local fc=og:Filter(aux.TRUE,tc):GetFirst()
	e:SetLabelObject(fc)
	og:DeleteGroup()
	-- 设置效果处理信息：从卡组或墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理（Operation）执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为代价丢弃的手卡（用于排除）
	local nc=Duel.GetFirstTarget()
	local fc=e:GetLabelObject()
	if not nc:IsRelateToChain() then nc=nil end
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张记述在展示融合怪兽上的素材（排除丢弃的卡，并受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nc,fc)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的融合素材加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsLocation(LOCATION_HAND) and tc:IsType(TYPE_NORMAL)
			-- 检查卡组或墓地是否还存在其他满足条件的融合素材
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nc,fc)
			-- 询问玩家是否选择再将另1只加入手卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否再把1只加入手卡？"
			-- 提示玩家选择第二张要加入手卡的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组或墓地选择第二张记述在展示融合怪兽上的素材
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nc,fc)
			local tc2=sg:GetFirst()
			if tc2 then
				-- 中断当前效果处理，使后续的加入手卡处理不与前一次同时进行
				Duel.BreakEffect()
				-- 将第二张选中的融合素材加入手卡
				Duel.SendtoHand(tc2,nil,REASON_EFFECT)
				-- 将第二张加入手卡的卡给对方确认
				Duel.ConfirmCards(1-tp,tc2)
			end
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家从额外卡组特殊召唤非融合怪兽的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数：不能从额外卡组特殊召唤非融合怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
