--苦渋の黙札
-- 效果：
-- ①：把自己场上1只怪兽解放才能发动。从自己的卡组·墓地选和解放的怪兽是原本卡名不同并是原本的种族·属性·等级相同的1只怪兽加入手卡。
function c20513882.initial_effect(c)
	-- ①：把自己场上1只怪兽解放才能发动。从自己的卡组·墓地选和解放的怪兽是原本卡名不同并是原本的种族·属性·等级相同的1只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(c20513882.cost)
	e1:SetTarget(c20513882.target)
	e1:SetOperation(c20513882.activate)
	c:RegisterEffect(e1)
end
-- 代价检查阶段：先把标签设为100，标记已经进入代价处理流程，再返回true表示代价可行；实际选择并解放怪兽的动作延后到target中处理。
function c20513882.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 定义可解放怪兽的过滤条件：需要是原本等级大于0的怪兽，同时自己卡组·墓地中存在1张能以其为参照被检索加入手卡的怪兽。
function c20513882.cfilter(c,tp)
	return c:GetOriginalLevel()>0
		-- 检查玩家tp的卡组·墓地中是否存在至少1张满足thfilter过滤条件、且以作为代价的候选怪兽c为参照的候选卡。
		and Duel.IsExistingMatchingCard(c20513882.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
-- 定义检索目标的过滤条件：必须是怪兽卡，原本等级、原本种族、原本属性都与解放的怪兽相同，原本卡名不同，并且能够加入手卡。
function c20513882.thfilter(c,tc)
	return c:IsType(TYPE_MONSTER)
		and c:GetOriginalLevel()==tc:GetOriginalLevel()
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and not c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
		and c:IsAbleToHand()
end
-- 效果发动时的目标处理：先检查e的标签是否为100以确认已经过代价检查，若不符则不能发动并将标签重置；然后检查存在可解放的满足条件的怪兽，接着选择1只解放怪兽，将其记录到e的LabelObject中，执行解放，并设置本连锁为从卡组·墓地检索加入手卡的操作信息。
function c20513882.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1只满足cfilter条件（即可解放且能检索）的怪兽。
		return Duel.CheckReleaseGroup(tp,c20513882.cfilter,1,nil,tp)
	end
	-- 让自己选择1只满足cfilter条件的怪兽，作为发动效果的解放代价。
	local g=Duel.SelectReleaseGroup(tp,c20513882.cfilter,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选中的怪兽解放，解放原因为代价，该动作不因效果免疫而无效。
	Duel.Release(g,REASON_COST)
	-- 设置操作信息：本次效果处理将进行“加入手卡”操作，数量为1，检索区域为卡组·墓地，检索方为tp，用于供相关效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：取出之前记录的解放怪兽，提示玩家选择1张符合条件的怪兽从卡组·墓地加入手卡；选到后送入持有着手卡并让对方确认。
function c20513882.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 弹出“请选择要加入手牌的卡”的选择提示，并预备选择框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地选择1张满足thfilter条件且不受王家长眠之谷影响的怪兽卡（以解放的怪兽tc作为匹配基准）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20513882.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc)
	if g:GetCount()>0 then
		-- 将选中的检索目标加入持有者手卡，加入原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡，用于确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
