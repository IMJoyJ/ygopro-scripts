--ドラグニティアームズ－グラム
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，从自己墓地把2只其他的龙族·鸟兽族怪兽除外才能发动。这张卡特殊召唤。
-- ②：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果无效化，那个攻击力下降自己场上的装备卡数量×1000。
-- ③：对方怪兽被战斗破坏送去墓地时才能发动。那怪兽当作装备魔法卡使用给这张卡装备。
function c53184342.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，从自己墓地把2只其他的龙族·鸟兽族怪兽除外才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53184342,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,53184342)
	e1:SetCost(c53184342.spcost)
	e1:SetTarget(c53184342.sptg)
	e1:SetOperation(c53184342.spop)
	c:RegisterEffect(e1)
	-- ②：以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果无效化，那个攻击力下降自己场上的装备卡数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53184342,1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53184343)
	e2:SetTarget(c53184342.distg)
	e2:SetOperation(c53184342.disop)
	c:RegisterEffect(e2)
	-- ③：对方怪兽被战斗破坏送去墓地时才能发动。那怪兽当作装备魔法卡使用给这张卡装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,53184344)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c53184342.eqcon)
	e3:SetTarget(c53184342.eqtg)
	e3:SetOperation(c53184342.eqop)
	c:RegisterEffect(e3)
end
-- 定义代价过滤函数：筛选自己墓地中可作为除外代价且种族为龙族或鸟兽族的怪兽（用于①效果）。
function c53184342.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_DRAGON+RACE_WINDBEAST)
end
-- ①效果的代价处理：确认墓地存在足够对象，让玩家选择2只其他龙族/鸟兽族怪兽并表侧除外，作为特殊召唤的代价。
function c53184342.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价判定：自己墓地是否存在至少2只其他可除外的龙族·鸟兽族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c53184342.spcostfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 弹出选择提示，让玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2只满足代价条件的龙族/鸟兽族怪兽，自动排除这张卡本身。
	local sg=Duel.SelectMatchingCard(tp,c53184342.spcostfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选择作为代价的怪兽以表侧表示除外。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- ①效果的目标判定：检查我方主怪兽区有空位，并且这张卡能够被特殊召唤。
function c53184342.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用主怪兽区空格用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记特殊召唤的操作信息，宣告本次连锁将特殊召唤这张卡1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果相关，则将其特殊召唤。
function c53184342.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②目标过滤：选择场上表侧表示怪兽；无装备卡时可选择可无效的效果怪兽，有装备卡时也可选择攻击力大于0的怪兽。
function c53184342.disfilter(c,eq)
	-- 返回真当目标为可无效的效果怪兽，或自己场上有装备卡且目标表侧攻击力大于0。
	return aux.NegateMonsterFilter(c) or eq and c:IsFaceup() and c:GetAttack()>0
end
-- ②目标选择处理：检测自己场上是否有装备卡，再从双方场上选择1只满足条件的表侧怪兽作为对象。
function c53184342.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检测自己场上是否存在装备魔法卡，用于决定②是否可以扩展目标选择范围。
	local eq=Duel.IsExistingMatchingCard(c53184342.eqfilter,tp,LOCATION_ONFIELD,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53184342.disfilter(chkc,eq) end
	-- 确认场上存在至少1只符合条件的表侧怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c53184342.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,eq) end
	-- 弹出选择提示，让玩家选择要无效的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从双方场上选择1只符合条件的表侧怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c53184342.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,eq)
end
-- 装备卡过滤：表侧表示或装备中的装备魔法卡，用于统计自己场上的装备卡数量。
function c53184342.eqfilter(c)
	return (c:IsFaceup() or c:GetEquipTarget()) and c:IsType(TYPE_EQUIP)
end
-- ②效果处理：使对象怪兽效果无效化；若自己场上有装备卡，则再使其攻击力下降装备卡数量×1000。
function c53184342.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 统计自己场上的装备魔法卡数量，用于计算攻击力下降值。
		local ct=Duel.GetMatchingGroupCount(c53184342.eqfilter,tp,LOCATION_ONFIELD,0,nil)
		if ct>0 then
			-- 那个攻击力下降自己场上的装备卡数量×1000。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_UPDATE_ATTACK)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetValue(-ct*1000)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 过滤因战斗被破坏并送去墓地的对方怪兽，用于触发③效果。
function c53184342.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(1-tp) and c:IsType(TYPE_MONSTER)
end
-- ③效果发动条件：本次战斗破坏事件中存在对方怪兽被战斗破坏送去墓地。
function c53184342.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53184342.cfilter,1,nil,tp)
end
-- 判断被战斗破坏的对方怪兽能否作为装备魔法卡放置在魔法陷阱区：不因限制被禁止，且不违反同名卡规则。
function c53184342.chkfilter(c,tp)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- ③目标过滤：选择对方怪兽、被战斗破坏送去墓地、原本在怪兽区且可作为装备卡安置的对象。
function c53184342.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(1-tp)
		and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c53184342.chkfilter(c,tp)
end
-- ③目标处理：从本次战斗破坏的怪兽中筛选合法对象，确认魔陷区空位足够，并登记为连锁对象。
function c53184342.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c53184342.filter,nil,tp)
	-- 确认存在至少1只合法怪兽，且我方魔法陷阱区空位数量不少于可装备怪兽数量。
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=#g end
	-- 将筛选出的对方怪兽登记为效果处理对象。
	Duel.SetTargetCard(g)
end
-- ③效果处理：筛选仍相关的对象怪兽，按魔陷区空位数量选择可装备的怪兽，将其作为装备魔法卡装备给本卡，并附加装备限制。
function c53184342.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从连锁对象中筛选仍与效果相关且不受王家长眠之谷影响的怪兽，得到最终可装备目标组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(aux.NecroValleyFilter(c53184342.chkfilter),nil,tp)
	-- 取得自己魔法陷阱区的可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if c:IsFaceup() and c:IsRelateToEffect(e) and #g>0 and ft>0 then
		local sg=nil
		if #g>ft then
			sg=g:Select(tp,ft,ft,nil)
		else
			sg=g
		end
		local tc=sg:GetFirst()
		while tc do
			-- 尝试将目标怪兽作为装备魔法卡装备给这张卡；若成功则继续处理。
			if Duel.Equip(tp,tc,c,true,true) then
				-- 那怪兽当作装备魔法卡使用给这张卡装备。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(c53184342.eqlimit)
				tc:RegisterEffect(e1)
			end
			tc=sg:GetNext()
		end
		-- 完成装备操作，触发装备成功相关时点。
		Duel.EquipComplete()
	end
end
-- 装备限制函数：该怪兽只允许装备给这张卡（效果所有者）。
function c53184342.eqlimit(e,c)
	return e:GetOwner()==c
end
