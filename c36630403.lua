--妖刀－不知火
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合，以调整以外的自己墓地1只不死族怪兽为对象才能发动。那只怪兽和这张卡从墓地除外，把持有和那2只的等级合计相同等级的1只不死族同调怪兽从额外卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c36630403.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，以调整以外的自己墓地1只不死族怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,36630403)
	-- 这个效果在这张卡送去墓地的回合不能发动。
	e1:SetCondition(aux.exccon)
	e1:SetTarget(c36630403.target)
	e1:SetOperation(c36630403.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断墓地中的不死族怪兽是否满足条件（不是调整、等级大于0、可以除外，并且存在符合条件的同调怪兽）
function c36630403.filter1(c,e,tp,lv)
	local clv=c:GetLevel()
	return clv>0 and not c:IsType(TYPE_TUNER) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemove()
		-- 检查是否存在满足条件的同调怪兽
		and Duel.IsExistingMatchingCard(c36630403.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv+clv)
end
-- 过滤函数，用于判断额外卡组中的同调怪兽是否满足条件（等级等于目标等级、种族为不死、类型为同调、可以特殊召唤，并且场上存在足够的召唤位置）
function c36630403.filter2(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否存在足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置效果的目标选择逻辑，用于选择墓地中的不死族怪兽
function c36630403.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36630403.filter1(chkc,e,tp,e:GetHandler():GetLevel()) end
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		-- 检查是否满足发动条件（自身可以除外，且墓地存在符合条件的不死族怪兽）
		and Duel.IsExistingTarget(c36630403.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler():GetLevel()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c36630403.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetHandler():GetLevel())
	g:AddCard(e:GetHandler())
	-- 设置操作信息，表示将要除外2张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,tp,LOCATION_GRAVE)
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，执行效果的处理逻辑
function c36630403.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local lv=c:GetLevel()+tc:GetLevel()
	local g=Group.FromCards(c,tc)
	-- 将目标怪兽和自身从墓地除外
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的同调怪兽
		local sg=Duel.SelectMatchingCard(tp,c36630403.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
		if sg:GetCount()>0 then
			-- 将选中的同调怪兽特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
