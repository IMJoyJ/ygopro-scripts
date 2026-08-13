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
-- 效果1的发动代价：确认此卡是否可解放，然后将其解放作为发动代价。
function c29981935.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为效果发动的代价，由于REASON_COST，不进入连锁且不受其他效果影响。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：从卡组选择满足「武神」字段、不是「武神-鸟船」自身、可以表侧守备表示特殊召唤的怪兽。
function c29981935.spfilter(c,e,tp)
	return c:IsSetCard(0x88) and not c:IsCode(29981935) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果1的发动条件检查：场上怪兽区至少有两个空位，且不受「青眼精灵龙」等禁止同时特召2只以上怪兽的效果影响，并确认卡组中存在至少2个不同种族的「武神」怪兽可供选择。
function c29981935.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有满足特殊召唤条件的「武神」怪兽集合。
		local g=Duel.GetMatchingGroup(c29981935.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return Duel.GetMZoneCount(tp,e:GetHandler())>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and g:GetClassCount(Card.GetRace)>=2
	end
	-- 向系统设置操作信息：本次效果将从卡组特殊召唤2只怪兽，用于后续的时点与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果1处理过程：再次确认场上空位和「青眼精灵龙」限制，从卡组选择2只种族不同的「武神」怪兽以表侧守备表示特殊召唤。
function c29981935.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时检查我方主要怪兽区是否有至少2个可用空格，不足则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足特殊召唤条件的「武神」怪兽集合。
	local g=Duel.GetMatchingGroup(c29981935.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示当前玩家从卡组选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的卡组怪兽中用aux.drccheck筛选出种族互不相同的2只怪兽作为特殊召唤对象。
	local sg=g:SelectSubGroup(tp,aux.drccheck,false,2,2)
	if sg then
		-- 将选出的2只怪兽以表侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：用于判定刚刚特殊召唤成功的是否为「武神」超量怪兽，且召唤者为当前效果发动者。
function c29981935.eqfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSetCard(0x88) and c:IsType(TYPE_XYZ) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果2的诱发条件：本次特殊召唤成功的怪兽中存在至少1只符合条件的「武神」超量怪兽。
function c29981935.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29981935.eqfilter,1,nil,tp)
end
-- 效果2发动时的合法检查：魔陷区有空位，并选定要装备的「武神」超量怪兽作为对象；若特殊召唤的怪兽只有1只则自动选择，否则由玩家选择。
function c29981935.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时机检查：我方魔陷区是否有空位来装备这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local tg
	if #eg==1 then
		tg=eg:Clone()
	else
		-- 提示玩家选择要装备的「武神」超量怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		tg=eg:FilterSelect(tp,c29981935.eqfilter,1,1,nil,e,tp)
	end
	-- 将选中的超量怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(tg)
	-- 设置操作信息：墓地的这张卡将因为装备而离开墓地，以便相关效果及时点检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果2处理过程：将此卡从墓地装备给对象超量怪兽，并附加装备限制和战斗破坏怪兽除外的效果。
function c29981935.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取效果处理时当前连锁指定的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 装备前合法性检查：魔陷区仍有空位、对象怪兽仍表侧且与效果相关、此卡在场上为同名卡唯一，任一不满足则放弃装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		return
	end
	-- 将这张卡作为装备卡装备到对象超量怪兽上。
	Duel.Equip(tp,c,tc)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c29981935.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 装备怪兽战斗破坏的怪兽不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制条件：这张卡只能装备给效果处理时选定的那只超量怪兽。
function c29981935.eqlimit(e,c)
	return c==e:GetLabelObject()
end
