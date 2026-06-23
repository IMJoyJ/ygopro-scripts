--武神－トリフネ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。除「武神-鸟船」外的2只种族不同的「武神」怪兽从卡组守备表示特殊召唤。
-- ②：这张卡在墓地存在，自己对「武神」超量怪兽的超量召唤成功时才能发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽战斗破坏的怪兽不去墓地而除外。
function c29981935.initial_effect(c)
	-- ①：把这张卡解放才能发动。除「武神-鸟船」外的2只种族不同的「武神」怪兽从卡组守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29981935,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,29981935)
	e1:SetCost(c29981935.spcost)
	e1:SetTarget(c29981935.sptg)
	e1:SetOperation(c29981935.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己对「武神」超量怪兽的超量召唤成功时才能发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽战斗破坏的怪兽不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29981935,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,29981936)
	e2:SetCondition(c29981935.eqcon)
	e2:SetTarget(c29981935.eqtg)
	e2:SetOperation(c29981935.eqop)
	c:RegisterEffect(e2)
end
-- 支付效果代价，解放自身
function c29981935.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从场上解放作为效果的发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选满足条件的「武神」怪兽，排除自身，用于特殊召唤
function c29981935.spfilter(c,e,tp)
	return c:IsSetCard(0x88) and not c:IsCode(29981935) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否满足特殊召唤的条件，包括怪兽区数量、青眼精灵龙效果影响、种族数量
function c29981935.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足特殊召唤条件的卡组中的「武神」怪兽
		local g=Duel.GetMatchingGroup(c29981935.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return Duel.GetMZoneCount(tp,e:GetHandler())>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and g:GetClassCount(Card.GetRace)>=2
	end
	-- 设置效果处理信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果，选择并特殊召唤2只符合条件的怪兽
function c29981935.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取满足特殊召唤条件的卡组中的「武神」怪兽
	local g=Duel.GetMatchingGroup(c29981935.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的怪兽中选择2只满足种族不同的条件
	local sg=g:SelectSubGroup(tp,aux.drccheck,false,2,2)
	if sg then
		-- 将选中的2只怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 筛选满足条件的「武神」超量怪兽，用于装备效果
function c29981935.eqfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSetCard(0x88) and c:IsType(TYPE_XYZ) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 判断是否有「武神」超量怪兽被成功特殊召唤
function c29981935.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29981935.eqfilter,1,nil,tp)
end
-- 设置装备效果的目标和处理信息
function c29981935.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的魔法陷阱区域进行装备
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local tg
	if #eg==1 then
		tg=eg:Clone()
	else
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		tg=eg:FilterSelect(tp,c29981935.eqfilter,1,1,nil,e,tp)
	end
	-- 设置当前效果的目标卡
	Duel.SetTargetCard(tg)
	-- 设置效果处理信息，表示将装备卡移除
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 处理装备效果，将装备卡装备给目标怪兽并设置效果
function c29981935.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 检查装备条件是否满足，包括魔法陷阱区域、目标卡是否为表侧表示、是否与效果相关、是否唯一
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		return
	end
	-- 将装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 设置装备卡的装备限制效果，只能装备给特定怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c29981935.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 设置装备卡的战斗破坏效果，使被破坏的怪兽不进入墓地而除外
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制效果的判断函数，确保只能装备给特定怪兽
function c29981935.eqlimit(e,c)
	return c==e:GetLabelObject()
end
