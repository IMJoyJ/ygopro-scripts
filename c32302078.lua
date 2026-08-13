--交血鬼－ヴァンパイア・シェリダン
-- 效果：
-- 6星怪兽×2只以上
-- 把原本持有者是对方的怪兽作为这张卡的超量召唤的素材的场合，那些等级当作6星使用。
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡送去墓地。
-- ②：1回合1次，场上的怪兽卡被效果送去对方墓地的场合或者被战斗破坏送去对方墓地的场合，把这张卡1个超量素材取除才能发动。那1只怪兽在自己场上守备表示特殊召唤。
function c32302078.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加超量召唤手续：用等级6的怪兽2只以上作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,6,2,nil,nil,99)
	-- 把原本持有者是对方的怪兽作为这张卡的超量召唤的素材的场合，那些等级当作6星使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c32302078.lvtg)
	e1:SetValue(c32302078.lvval)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32302078,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c32302078.cost)
	e2:SetTarget(c32302078.tgtg)
	e2:SetOperation(c32302078.tgop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，场上的怪兽卡被效果送去对方墓地的场合或者被战斗破坏送去对方墓地的场合，把这张卡1个超量素材取除才能发动。那1只怪兽在自己场上守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32302078,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c32302078.cost)
	e3:SetTarget(c32302078.sptg)
	e3:SetOperation(c32302078.spop)
	c:RegisterEffect(e3)
end
-- 筛选出等级1以上且原本持有者不是己方的怪兽，即原本持有者是对方的怪兽，作为等级替换效果的适用对象。
function c32302078.lvtg(e,c)
	return c:IsLevelAbove(1) and c:GetOwner()~=e:GetHandlerPlayer()
end
-- 对于上述怪兽，当其作为这张卡的超量召唤素材时，将等级当作6星使用；否则保持原等级。
function c32302078.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc==e:GetHandler() then return 6
	else return lv end
end
-- 发动代价：检查并从这张卡上取除1个超量素材，作为效果发动的COST。
function c32302078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动与目标选择：进行取对象判定，选择对方场上1张卡作为对象，并设置送去墓地的操作信息。
function c32302078.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张可作为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给己方玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从对方场上选择1张卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 向系统登记本次效果将把对象卡送去墓地，数量为1，用于连锁时点检测等。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ①效果处理：若目标卡仍与该效果关联，则将其送去墓地。
function c32302078.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡（即选择送去墓地的目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将被选择的目标卡送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- ②效果的怪兽筛选条件：该怪兽从场上以战斗或效果原因被送去对方墓地（即原本持有者为对方），且当前位于墓地、可以被自己以表侧守备表示特殊召唤。
function c32302078.spfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsControler(1-tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动条件：己方主要怪兽区有空位，且本次被送去墓地的怪兽组中存在满足特殊召唤条件的怪兽。
function c32302078.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c32302078.spfilter,1,nil,e,tp) end
	-- 向系统登记本次效果将进行特殊召唤，可能涉及本次送去墓地的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,1,0,0)
end
-- ②效果处理：从本次送去墓地的怪兽中筛选出可特殊召唤且不受王家长眠之谷影响的怪兽，选择1只以表侧守备表示特殊召唤到自己场上。
function c32302078.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方主要怪兽区有空位，否则停止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sg=nil
	-- 从本次送去墓地的怪兽中筛选出满足特殊召唤条件且不受“王家长眠之谷”影响的怪兽组。
	local g=eg:Filter(aux.NecroValleyFilter(c32302078.spfilter),nil,e,tp)
	if g:GetCount()==0 then return end
	if g:GetCount()==1 then
		sg=g
	else
		sg=g:Select(tp,1,1,nil)
	end
	-- 将选择的那1只怪兽以表侧守备表示特殊召唤到自己场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
