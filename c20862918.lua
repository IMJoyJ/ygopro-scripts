--クロス・ブリード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把2只原本的种族·属性相同而卡名不同的怪兽除外才能发动。和那些怪兽是原本的种族·属性相同而卡名不同的1只怪兽从卡组加入手卡。
function c20862918.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡以及自己场上的表侧表示怪兽之中把2只原本的种族·属性相同而卡名不同的怪兽除外才能发动。和那些怪兽是原本的种族·属性相同而卡名不同的1只怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,20862918+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c20862918.cost)
	e1:SetTarget(c20862918.target)
	e1:SetOperation(c20862918.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
end
-- 代价判定函数：设置标记值为100，表示代价已选择完毕；在无代价检查时返回true，允许发动。
function c20862918.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 定义第一张可除外代价怪兽的筛选条件：存在于手牌或自己场上表侧表示、是怪兽且可作为代价除外，并且还存在至少一张满足条件的第二张候选怪兽。
function c20862918.costfilter1(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 确认存在至少一只与第一张候选怪兽原本种族·属性相同且卡名不同的另一只怪兽，可从手牌或自己场上表侧表示的怪兽中选择，以保证能凑成一对代价。
		and Duel.IsExistingMatchingCard(c20862918.costfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c,c:GetOriginalRace(),c:GetOriginalAttribute(),c:GetCode(),tp)
end
-- 定义第二张可除外代价怪兽的筛选条件：从手牌或自己场上表侧表示中选择，是怪兽且可作为代价除外；与第一张原本种族·属性相同、卡名不同，并且卡组中存在对应的检索目标。
function c20862918.costfilter2(c,race,att,code,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		and c:GetOriginalRace()==race and c:GetOriginalAttribute()==att and not c:IsCode(code)
		-- 确认卡组中存在至少一只与两张代价怪兽原本种族·属性相同、卡名不同且可加入手牌的怪兽作为检索目标。
		and Duel.IsExistingMatchingCard(c20862918.thfilter,tp,LOCATION_DECK,0,1,nil,race,att,code,c:GetCode())
end
-- 定义最终从卡组加入手牌的怪兽的筛选条件：原本种族·属性与除外的两张怪兽相同，卡名与二者均不同，是怪兽且可以加入手牌。
function c20862918.thfilter(c,race,att,code1,code2)
	return c:GetOriginalRace()==race and c:GetOriginalAttribute()==att and not c:IsCode(code1,code2)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时的目标处理函数：确认代价已满足后，依次选择两张要除外的怪兽，记录其种族、属性和卡号，将两张卡作为代价除外，并设置效果处理时将检索1张加入手牌。
function c20862918.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 发动合法性检查：确认本效果为魔法陷阱卡的发动效果，并且手牌或自己场上存在满足第一张代价筛选条件的怪兽，允许发动。
		return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(c20862918.costfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
	end
	e:SetLabel(0)
	-- 弹出提示，要求玩家选择要除外的卡（第一张代价怪兽的选择提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手牌以及自己场上的表侧表示怪兽中选择第一张要除外的怪兽。
	local g1=Duel.SelectMatchingCard(tp,c20862918.costfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	local race=g1:GetFirst():GetOriginalRace()
	local att=g1:GetFirst():GetOriginalAttribute()
	local code=g1:GetFirst():GetCode()
	-- 弹出提示，要求玩家选择要除外的卡（第二张代价怪兽的选择提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择第二张要除外的怪兽，要求与第一张原本种族·属性相同且卡名不同。
	local g2=Duel.SelectMatchingCard(tp,c20862918.costfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,g1:GetFirst(),race,att,code,tp)
	e:SetLabel(race,att,code,g2:GetFirst():GetCode())
	g1:Merge(g2)
	-- 将选中的两张怪兽以表侧表示除外，作为发动效果的代价。
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
	-- 设置操作信息：本次连锁在效果处理时会将1张怪兽从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：读取之前保存的原本种族、属性和两张卡号，从卡组选择1只满足条件的怪兽加入手牌，并向对方展示。
function c20862918.activate(e,tp,eg,ep,ev,re,r,rp)
	local race,att,code1,code2=e:GetLabel()
	-- 弹出提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只满足thfilter过滤条件的怪兽作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c20862918.thfilter,tp,LOCATION_DECK,0,1,1,nil,race,att,code1,code2)
	if g:GetCount()>0 then
		-- 将选择的怪兽送去其持有者的手卡，即加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
