--ベリー・マジシャン・ガール
-- 效果：
-- ①：这张卡召唤成功的场合才能发动。从卡组把1只「魔术少女」怪兽加入手卡。
-- ②：1回合1次，这张卡成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。这张卡的表示形式变更，从卡组把「浆果魔术少女」以外的1只「魔术少女」怪兽特殊召唤。
function c20747792.initial_effect(c)
	-- ①：这张卡召唤成功的场合才能发动。从卡组把1只「魔术少女」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20747792,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c20747792.thtg)
	e1:SetOperation(c20747792.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。这张卡的表示形式变更，从卡组把「浆果魔术少女」以外的1只「魔术少女」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20747792,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c20747792.spcon1)
	e2:SetTarget(c20747792.sptg)
	e2:SetOperation(c20747792.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(20747792,2))
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c20747792.spcon2)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选出卡组中持有「魔术少女」字段、属于怪兽卡且可以被加入手卡的卡片。
function c20747792.thfilter(c)
	return c:IsSetCard(0x20a2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动条件判定与操作信息设定：在满足存在可检索对象的前提下，声明本效果将把卡组中的1张卡加入手卡。
function c20747792.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在至少1张满足检索过滤条件的「魔术少女」怪兽，用于决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c20747792.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本连锁将进行从卡组把1张卡加入手卡的处理（检索类效果）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的实际处理：从卡组选择1只符合条件的「魔术少女」怪兽加入手卡，并让对手确认。
function c20747792.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示当前玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张满足thfilter条件的「魔术少女」怪兽。
	local g=Duel.SelectMatchingCard(tp,c20747792.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽以效果原因送入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的手卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：筛选出卡组中持有「魔术少女」字段、不是「浆果魔术少女」自身、且可以被特殊召唤的怪兽。
function c20747792.spfilter(c,e,tp)
	return c:IsSetCard(0x20a2) and not c:IsCode(20747792) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果之“成为对方效果对象”的发动条件：本卡成为对方发动的效果的对象。
function c20747792.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and rp==1-tp
end
-- ②效果之“被选择作为攻击对象”的发动条件：本卡被对方怪兽选择为攻击对象。
function c20747792.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前被选择为攻击对象的卡包含本卡，且发动攻击的怪兽控制者为对方。
	return eg:IsContains(e:GetHandler()) and Duel.GetAttacker():IsControler(1-tp)
end
-- ②效果的发动条件判定：自己场上存在可用的主要怪兽区空格，且卡组中存在符合条件可特殊召唤的「魔术少女」怪兽。
function c20747792.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区格子，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足spfilter条件的「魔术少女」怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c20747792.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁包含从卡组特殊召唤1只怪兽的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本连锁还包含变更本卡表示形式的处理。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- ②效果的实际处理：先变更本卡的表示形式，再选择卡组中的1只符合条件的「魔术少女」怪兽特殊召唤。
function c20747792.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若本卡已与效果失去联系，或变更表示形式失败（返回0），则终止处理；否则先将本卡变更为表侧守备表示（原为攻击表示时）或表侧攻击表示（原为守备表示时）。
	if not c:IsRelateToEffect(e) or Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)==0 then return end
	-- 特殊召唤前再次确认自己场上仍有空余的主要怪兽区格子。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示当前玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1只满足spfilter条件的「魔术少女」怪兽。
	local g=Duel.SelectMatchingCard(tp,c20747792.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上，不进行召唤条件与苏生限制的额外检查。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
