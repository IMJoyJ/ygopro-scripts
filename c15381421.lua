--輝光竜セイファート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·场上（表侧表示）把龙族怪兽任意数量送去墓地才能发动。把持有和送去墓地的怪兽的原本等级合计相同等级的1只龙族怪兽从卡组加入手卡。
-- ②：把墓地的这张卡除外，以自己墓地1只光·暗属性的龙族·8星怪兽为对象才能发动。那只怪兽加入手卡。
function c15381421.initial_effect(c)
	-- ①：从自己的手卡·场上（表侧表示）把龙族怪兽任意数量送去墓地才能发动。把持有和送去墓地的怪兽的原本等级合计相同等级的1只龙族怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15381421,0))  --"请选择要加入手卡的怪兽的等级"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,15381421)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c15381421.thcost)
	e1:SetTarget(c15381421.thtg)
	e1:SetOperation(c15381421.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只光·暗属性的龙族·8星怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,15381422)
	-- 把墓地的这张卡除外作为发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c15381421.thtg2)
	e2:SetOperation(c15381421.thop2)
	c:RegisterEffect(e2)
end
-- 筛选可作为代价送去墓地的龙族怪兽：必须是龙族、原本等级大于0、可作为代价送去墓地，且位于手卡或场上表侧表示。
function c15381421.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:GetOriginalLevel()>0 and c:IsAbleToGraveAsCost()
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 判定卡组中的龙族怪兽能否作为检索对象：其为龙族、等级大于0、能加入手卡，且手卡/场上存在一组可作为代价的龙族怪兽，其原本等级合计等于该怪兽的等级。
function c15381421.filter(c,e,tp,rg)
	local lv=c:GetLevel()
	return lv>0 and c:IsRace(RACE_DRAGON) and c:IsAbleToHand() and rg:CheckWithSumEqual(Card.GetOriginalLevel,lv,1,99)
end
-- 代价检查阶段：将效果Label设为100作为标记，表示已进入代价选择流程；返回true表示代价可支付，真正的送墓操作在目标选择阶段进行。
function c15381421.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 目标选择阶段：获取可送墓的龙族怪兽候选组；若卡组中存在可检索目标，则让玩家宣言一个等级，再选择一组原本等级合计等于该宣言等级的龙族怪兽送去墓地作为代价，保存宣言等级并设置从卡组加入手卡的操作信息。
function c15381421.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方手卡及场上表侧表示中可作为代价的龙族怪兽候选组。
	local rg=Duel.GetMatchingGroup(c15381421.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查我方卡组是否存在至少1张满足检索条件的龙族怪兽（即等级与某组候选代价原本等级合计相同的可加入手卡的龙族怪兽）。
		return Duel.IsExistingMatchingCard(c15381421.filter,tp,LOCATION_DECK,0,1,nil,e,tp,rg) end
	-- 获取卡组中所有满足检索条件的龙族怪兽，用于后续选择可宣言的等级。
	local g=Duel.GetMatchingGroup(c15381421.filter,tp,LOCATION_DECK,0,nil,e,tp,rg)
	local lvt={}
	local pc=1
	for i=1,12 do
		if g:IsExists(c15381421.thfilter,1,nil,i) then lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 让玩家在可选等级中宣言1个等级，作为送墓怪兽的原本等级合计以及要检索的龙族怪兽的等级。
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	-- 重新获取当前手卡和场上表侧表示的龙族怪兽候选组，用于实际选择送墓的卡。
	local rg=Duel.GetMatchingGroup(c15381421.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 给玩家显示“请选择要送去墓地的卡”的提示，并进入选择送墓卡的状态。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=rg:SelectWithSumEqual(tp,Card.GetOriginalLevel,lv,1,99)
	-- 将选中的龙族怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(sg,REASON_COST)
	e:SetLabel(lv)
	-- 设置操作信息：本效果处理时预计从卡组将1张卡加入手卡（检索目标在处理时选择，因此对象暂不指定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索目标的筛选条件：卡组中等级等于宣言等级、龙族且能加入手卡的怪兽。
function c15381421.thfilter(c,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果处理：从卡组选择1只等级等于宣言等级且能加入手卡的龙族怪兽加入手牌，并向对方玩家确认。
function c15381421.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示“请选择要加入手牌的卡”的提示，进入选择检索目标状态。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足检索条件（龙族且等级等于宣言等级）且能加入手卡的龙族怪兽。
	local g=Duel.SelectMatchingCard(tp,c15381421.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的龙族怪兽以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选②效果的对象：自己墓地中光属性或暗属性、龙族、8星怪兽，且能够加入手卡。
function c15381421.thfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsLevel(8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的目标选择阶段：确认自己墓地存在合法对象后，选择1只符合条件的龙族怪兽作为对象，并设置操作信息为将其加入手卡。
function c15381421.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15381421.thfilter2(chkc) end
	-- 检查自己墓地是否存在至少1只满足thfilter2且能成为效果对象的龙族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c15381421.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示“请选择要加入手牌的卡”的提示，进入选择对象状态。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的龙族怪兽作为效果对象，并将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c15381421.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选择的1张对象卡加入持有者手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：取得对象卡，若对象仍与效果关联，则将其加入持有者手牌。
function c15381421.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果连锁中登记的对象卡（唯一对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
