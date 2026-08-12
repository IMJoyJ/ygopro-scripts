--真紅眼の鉄騎士－ギア・フリード
-- 效果：
-- ①：1回合1次，这张卡有装备卡被装备的场合才能发动。那些装备卡破坏。那之后，可以选对方场上1张魔法·陷阱卡破坏。
-- ②：1回合1次，把这张卡装备的自己场上1张装备卡送去墓地，以自己墓地1只7星以下的「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。
function c85651167.initial_effect(c)
	-- ①：1回合1次，这张卡有装备卡被装备的场合才能发动。那些装备卡破坏。那之后，可以选对方场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85651167,0))  --"装备卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_EQUIP)
	e1:SetCountLimit(1)
	e1:SetTarget(c85651167.destg)
	e1:SetOperation(c85651167.desop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡装备的自己场上1张装备卡送去墓地，以自己墓地1只7星以下的「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85651167,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c85651167.spcost)
	e2:SetTarget(c85651167.sptg)
	e2:SetOperation(c85651167.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选装备在这张卡上的装备卡
function c85651167.filter1(c,ec)
	return c:GetEquipTarget()==ec
end
-- 效果①的发动检测与效果处理准备函数（检测是否有装备卡装备，并设置破坏操作信息）
function c85651167.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c85651167.filter1,1,nil,e:GetHandler()) end
	local g=eg:Filter(c85651167.filter1,nil,e:GetHandler())
	-- 设置操作信息：在连锁处理时破坏这些装备卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的效果处理函数（破坏装备卡，并可选破坏对方场上1张魔法·陷阱卡）
function c85651167.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c85651167.filter1,nil,e:GetHandler())
	-- 获取对方场上的所有魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	-- 如果成功破坏了装备卡，且对方场上存在魔法·陷阱卡
	if Duel.Destroy(g,REASON_EFFECT)~=0 and sg:GetCount()>0
		-- 询问玩家是否选择发动后续的破坏对方魔法·陷阱卡的效果
		and Duel.SelectYesNo(tp,aux.Stringid(85651167,2)) then  --"是否选对方场上1张魔法·陷阱卡破坏？"
		-- 中断当前效果，使前后的破坏处理不视为同时处理（造成错时点）
		Duel.BreakEffect()
		-- 给玩家发送提示信息：请选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local tg=sg:Select(tp,1,1,nil)
		-- 手动为选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(tg)
		-- 因效果破坏选中的对方魔法·陷阱卡
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 过滤函数：筛选属于自己且可以作为Cost送去墓地的卡
function c85651167.spcostfilter(c,tp)
	return c:IsControler(tp) and c:IsAbleToGraveAsCost()
end
-- 效果②的发动代价（Cost）处理函数（将这张卡装备的1张装备卡送去墓地）
function c85651167.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetEquipGroup()
	if chk==0 then return g:IsExists(c85651167.spcostfilter,1,nil,tp) end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tg=g:FilterSelect(tp,c85651167.spcostfilter,1,1,nil,tp)
	-- 将选中的装备卡作为发动代价送去墓地
	Duel.SendtoGrave(tg,REASON_COST)
end
-- 过滤函数：筛选自己墓地中7星以下的「真红眼」怪兽，且该怪兽可以特殊召唤
function c85651167.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动检测与目标选择函数（检测怪兽区域空位，并选择墓地中的「真红眼」怪兽作为对象）
function c85651167.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c85651167.spfilter(chkc,e,tp) end
	-- 在发动检测时，确认自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地存在至少1只符合条件的「真红眼」怪兽
		and Duel.IsExistingTarget(c85651167.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「真红眼」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c85651167.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：在连锁处理时特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理函数（将选中的对象怪兽特殊召唤）
function c85651167.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
