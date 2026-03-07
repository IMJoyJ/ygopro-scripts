--交血鬼－ヴァンパイア・シェリダン
-- 效果：
-- 6星怪兽×2只以上
-- 把原本持有者是对方的怪兽作为这张卡的超量召唤的素材的场合，那些等级当作6星使用。
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡送去墓地。
-- ②：1回合1次，场上的怪兽卡被效果送去对方墓地的场合或者被战斗破坏送去对方墓地的场合，把这张卡1个超量素材取除才能发动。那1只怪兽在自己场上守备表示特殊召唤。
function c32302078.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，使用等级为6的怪兽2只以上作为素材进行超量召唤
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
-- 过滤条件：怪兽等级大于等于1且拥有者不是当前怪兽的控制者
function c32302078.lvtg(e,c)
	return c:IsLevelAbove(1) and c:GetOwner()~=e:GetHandlerPlayer()
end
-- 当作为超量素材的怪兽被用于此卡的超量召唤时，其等级视为6星
function c32302078.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc==e:GetHandler() then return 6
	else return lv end
end
-- 支付1个超量素材作为代价
function c32302078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择对方场上的1张卡作为效果对象
function c32302078.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否存在对方场上的卡可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，表示将有1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 将选择的卡送去墓地
function c32302078.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 过滤条件：怪兽从场上送去墓地且控制者为对方，破坏原因为战斗或效果，且可以特殊召唤
function c32302078.spfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsControler(1-tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 检查是否满足特殊召唤条件
function c32302078.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c32302078.spfilter,1,nil,e,tp) end
	-- 设置效果操作信息，表示将有1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,1,0,0)
end
-- 执行特殊召唤操作，将符合条件的怪兽以守备表示特殊召唤到场上
function c32302078.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sg=nil
	-- 筛选满足特殊召唤条件的怪兽，排除受王家长眠之谷影响的怪兽
	local g=eg:Filter(aux.NecroValleyFilter(c32302078.spfilter),nil,e,tp)
	if g:GetCount()==0 then return end
	if g:GetCount()==1 then
		sg=g
	else
		sg=g:Select(tp,1,1,nil)
	end
	-- 将符合条件的怪兽以守备表示特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
