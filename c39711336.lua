--不死王リッチー
-- 效果：
-- 这张卡不能通常召唤。满足条件的「大神官 迪·扎德」做祭品特殊召唤。这张卡1个回合可以有1次变成里侧守备表示。场上表侧表示存在的这张卡为对象的魔法·陷阱卡的发动和效果无效并破坏。这张卡反转时，选择自己的墓地的1只不死族怪兽特殊召唤上场。
function c39711336.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡1个回合可以有1次变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39711336,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c39711336.target)
	e1:SetOperation(c39711336.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转时，选择自己的墓地的1只不死族怪兽特殊召唤上场。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39711336,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c39711336.sptg)
	e2:SetOperation(c39711336.spop)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的这张卡为对象的魔法·陷阱卡的发动和效果无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_F)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCondition(c39711336.discon)
	e3:SetTarget(c39711336.distg)
	e3:SetOperation(c39711336.disop)
	c:RegisterEffect(e3)
end
-- 检查此卡是否可以变更为里侧守备表示且此卡在本回合未发动过效果
function c39711336.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(39711336)==0 end
	c:RegisterFlagEffect(39711336,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置此卡变为里侧守备表示的效果信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 将此卡变为里侧守备表示
function c39711336.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将此卡变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 筛选墓地中的不死族怪兽作为特殊召唤目标
function c39711336.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否有满足条件的不死族怪兽可特殊召唤
function c39711336.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39711336.spfilter(chkc,e,tp) end
	-- 检查召唤区域是否为空
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的不死族怪兽
		and Duel.IsExistingTarget(c39711336.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c39711336.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的效果信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 将目标卡特殊召唤
function c39711336.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断连锁是否为魔法或陷阱卡的发动且对象为此卡
function c39711336.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁对象卡组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(e:GetHandler()) then return false end
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 设置无效和破坏的效果信息
function c39711336.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的效果信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏的效果信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理连锁无效和破坏
function c39711336.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前连锁
	if Duel.GetCurrentChain()~=ev+1 then return end
	-- 判断是否成功使发动无效且对象卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对象卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
