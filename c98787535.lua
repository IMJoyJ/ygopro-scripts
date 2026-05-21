--溟界の昏闇－アレート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡特殊召唤。那之后，对方可以从自身墓地选1只怪兽加入手卡。
-- ②：这张卡特殊召唤成功的场合，从除外的自己怪兽之中以包含爬虫类族怪兽的2只怪兽为对象才能发动。那些怪兽回到墓地。
function c98787535.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，把自己场上1只怪兽解放才能发动。这张卡特殊召唤。那之后，对方可以从自身墓地选1只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98787535,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,98787535)
	e1:SetCost(c98787535.spcost)
	e1:SetTarget(c98787535.sptg)
	e1:SetOperation(c98787535.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，从除外的自己怪兽之中以包含爬虫类族怪兽的2只怪兽为对象才能发动。那些怪兽回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98787535,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,98787536)
	e2:SetTarget(c98787535.rgtg)
	e2:SetOperation(c98787535.rgop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价（Cost）处理函数：解放自己场上1只怪兽
function c98787535.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可解放的怪兽组
	local g=Duel.GetReleaseGroup(tp)
	-- 检查是否存在可解放的怪兽，且解放后有足够的怪兽区域用于特殊召唤
	if chk==0 then return g:CheckSubGroup(aux.mzctcheckrel,1,1,tp) end
	-- 给玩家发送“选择要解放的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只满足解放后能腾出空位特召条件的怪兽
	local rg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,1,1,tp)
	-- 强制使用类似“暗影敌托邦”等代替解放效果的次数
	aux.UseExtraReleaseCount(rg,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(rg,REASON_COST)
end
-- ①号效果的发动准备（Target）函数：检查自身是否能特殊召唤并设置操作信息
function c98787535.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示该效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：对方墓地中可以加入手卡的怪兽
function c98787535.thfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand(1-tp)
end
-- ①号效果的处理（Operation）函数：特殊召唤自身，并让对方选择是否将墓地1只怪兽加入手卡
function c98787535.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并成功将自身以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查对方墓地是否存在可加入手卡的怪兽（受王家长眠之谷影响）
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c98787535.thfilter),tp,0,LOCATION_GRAVE,1,nil,tp)
		-- 询问对方玩家是否选择将墓地1只怪兽加入手卡
		and Duel.SelectYesNo(1-tp,aux.Stringid(98787535,2)) then  --"是否从墓地选怪兽加入手卡？"
		-- 中断当前效果处理，使后续的“加入手卡”与“特殊召唤”不视为同时处理（会造成错时点）
		Duel.BreakEffect()
		-- 给对方玩家发送“选择要加入手牌的卡”的提示信息
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让对方玩家从其墓地选择1只怪兽（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(c98787535.thfilter),tp,0,LOCATION_GRAVE,1,1,nil,tp)
		-- 将选中的怪兽加入对方手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给发动效果的玩家确认加入对方手卡的卡片
		Duel.ConfirmCards(tp,g)
	end
end
-- 过滤函数：除外状态的、表侧表示的、可以作为效果对象的怪兽
function c98787535.rgfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
end
-- 过滤函数：检查选中的卡片组中是否至少包含1只爬虫类族怪兽
function c98787535.fselect(g)
	return g:IsExists(Card.IsRace,1,nil,RACE_REPTILE)
end
-- ②号效果的发动准备（Target）函数：选择除外的2只怪兽（须包含爬虫类族）作为对象
function c98787535.rgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己除外状态下所有满足条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c98787535.rgfilter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c98787535.fselect,2,2) end
	-- 给玩家发送“选择要送去墓地的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c98787535.fselect,false,2,2)
	-- 将选中的2只怪兽设为当前连锁的效果对象
	Duel.SetTargetCard(sg)
	-- 设置连锁信息，表示该效果包含将这2只怪兽送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,2,0,0)
end
-- ②号效果的处理（Operation）函数：使作为对象的2只怪兽回到墓地
function c98787535.rgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 将这些怪兽送回墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
