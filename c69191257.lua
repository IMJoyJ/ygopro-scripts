--翠鋁の機竜
-- 效果：
-- 调整+调整以外的怪兽1只以上
-- 这张卡特殊召唤的场合：可以从卡组把1只机械族调整送去墓地。自己场上有持有和原本等级不同等级的怪兽的场合，也能作为代替特殊召唤。「翠铁之机龙」的这个效果1回合只能使用1次。
-- 同调召唤的这张卡被效果破坏送去墓地的场合：可以从自己墓地把调整任意数量除外，以那个数量的场上的卡为对象；那些卡破坏。
local s,id,o=GetID()
-- 初始化「翠铝之机龙」(69191257)：设置同调召唤手续与苏生限制，并注册①特召成功时堆墓或特召机械族调整、以及②同调召唤的自身被效破送墓时除外墓地调整炸场的效果
function s.initial_effect(c)
	-- 设置同调召唤手续：1只调整＋1只以上调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤的场合才能发动。从卡组把1只机械族调整送去墓地。持有和原本等级不同等级的怪兽在自己场上存在的场合，也能不送去墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被效果破坏送去墓地的场合，从自己墓地把调整任意数量除外，以那个数量的场上的卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选卡组中机械族调整怪兽，要求可送去墓地或在check为真时可特殊召唤
function s.tgfilter(c,e,tp,check)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_TUNER) and c:IsRace(RACE_MACHINE)
		and (c:IsAbleToGrave() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 过滤函数：筛选己方场上表侧表示、当前等级有效(>=1)且与原本等级不同的怪兽
function s.cfilter(c)
	local lv=c:GetOriginalLevel()
	return c:IsFaceup() and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- 效果①的Target函数：检测是否满足替代特召条件check，并确认卡组中存在可送墓或特召的机械族调整
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查己方怪兽区是否存在与原本等级不同等级的怪兽
		local check=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 且检查己方主要怪兽区是否至少有1个可用空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动检测时确认己方卡组中存在至少1只满足操作条件的机械族调整怪兽
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- 效果①的Operation函数：从卡组选1只机械族调整怪兽，根据场面条件与玩家选择将其表侧特殊召唤或送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新检查效果处理时己方怪兽区是否存在等级变化过的怪兽
	local check=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 重新检查效果处理时己方主要怪兽区是否仍有可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 向己方玩家发送选择要操作的机械族调整怪兽提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从己方卡组中选择1只符合条件的机械族调整怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若该怪兽无法送墓，或玩家在送去墓地(1191)与特殊召唤(1152)之间选择了特殊召唤，则执行特召分支
			and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1191,1152)==1) then
			-- 将选中的机械族调整怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif tc:IsAbleToGrave() then
			-- 若选中的机械族调整怪兽可以送去墓地，则以效果将其送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 效果②的Condition函数：检查这张卡是否以同调召唤出场、原本在怪兽区且因效果破坏原因送去墓地
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤函数：筛选墓地中可以作为代价除外的调整怪兽
function s.costfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的Cost函数：统计场上可成为对象的卡片上限rt，从己方墓地选择1至rt只调整表侧除外并将实际除外数量记录到Label
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测时确认己方墓地存在至少1只可作为代价除外的调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取双方场上当前可以成为效果对象的卡片总数rt，作为最多可除外的调整数量上限
	local rt=Duel.GetTargetCount(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 向己方玩家发送选择要除外的墓地调整怪兽提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从己方墓地选择1至rt只可除外的调整怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,rt,nil)
	-- 将选中的调整怪兽作为发动代价表侧除外，并返回实际除外的数量ct
	local ct=Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(ct)
end
-- 效果②的Target函数：发动检测时确认场上存在至少1张可作为对象的卡，随后根据除外调整数ct取场上等量卡片为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动检测时确认双方场上存在至少1张可以成为当前效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 向己方玩家发送选择要破坏的场上卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择恰好ct张（等于Cost除外的调整数量）卡片作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置将所选ct张对象卡破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 效果②的Operation函数：筛选出仍与本次连锁关联且仍在场上的对象卡，并将其以效果破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前仍与本次连锁保持关联且仍在场上的对象卡片组
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if #tg>0 then
		-- 以效果破坏选中的场上对象卡
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
