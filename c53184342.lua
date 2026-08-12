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
-- 过滤函数：满足条件的卡可以作为除外费用，且种族为龙族或鸟兽族
function c53184342.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsRace(RACE_DRAGON+RACE_WINDBEAST)
end
-- 效果处理：检查是否满足除外2只龙族·鸟兽族怪兽的条件，并选择并除外这些卡作为发动cost
function c53184342.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外2只龙族·鸟兽族怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c53184342.spcostfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张卡
	local sg=Duel.SelectMatchingCard(tp,c53184342.spcostfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将选中的卡从游戏中除外作为费用
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果处理：检查是否可以特殊召唤此卡
function c53184342.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的主怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示即将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：执行特殊召唤操作
function c53184342.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数：判断目标是否可以被无效化
function c53184342.disfilter(c,eq)
	-- 如果目标是表侧表示的怪兽且攻击力大于0，则可被无效化
	return aux.NegateMonsterFilter(c) or eq and c:IsFaceup() and c:GetAttack()>0
end
-- 效果处理：选择要无效化的怪兽对象
function c53184342.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查场上是否存在装备卡
	local eq=Duel.IsExistingMatchingCard(c53184342.eqfilter,tp,LOCATION_ONFIELD,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53184342.disfilter(chkc,eq) end
	-- 检查是否有满足条件的怪兽可以作为对象
	if chk==0 then return Duel.IsExistingTarget(c53184342.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,eq) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择一个满足条件的怪兽作为对象
	Duel.SelectTarget(tp,c53184342.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,eq)
end
-- 过滤函数：判断是否为装备卡
function c53184342.eqfilter(c)
	return (c:IsFaceup() or c:GetEquipTarget()) and c:IsType(TYPE_EQUIP)
end
-- 效果处理：执行无效化和攻击力下降操作
function c53184342.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 计算场上装备卡的数量
		local ct=Duel.GetMatchingGroupCount(c53184342.eqfilter,tp,LOCATION_ONFIELD,0,nil)
		if ct>0 then
			-- 使目标怪兽的攻击力下降其数量×1000
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
-- 过滤函数：判断是否为被战斗破坏送入墓地的对方怪兽
function c53184342.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(1-tp) and c:IsType(TYPE_MONSTER)
end
-- 效果处理：判断是否满足发动条件（对方怪兽被战斗破坏）
function c53184342.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53184342.cfilter,1,nil,tp)
end
-- 过滤函数：判断装备卡是否可以装备到场上
function c53184342.chkfilter(c,tp)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 过滤函数：筛选符合条件的被破坏怪兽作为装备对象
function c53184342.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(1-tp)
		and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c53184342.chkfilter(c,tp)
end
-- 效果处理：选择要装备的怪兽
function c53184342.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c53184342.filter,nil,tp)
	-- 检查是否有满足条件的怪兽可装备且场地有足够空间
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=#g end
	-- 设置操作信息，表示即将装备这些怪兽
	Duel.SetTargetCard(g)
end
-- 效果处理：执行装备操作
function c53184342.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡组，并筛选出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e):Filter(aux.NecroValleyFilter(c53184342.chkfilter),nil,tp)
	-- 计算场上可用的装备区域数量
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
			-- 尝试将卡装备到此卡上
			if Duel.Equip(tp,tc,c,true,true) then
				-- 设置装备限制，确保只能装备给此卡
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
		-- 完成装备过程
		Duel.EquipComplete()
	end
end
-- 装备限制函数：判断是否可以装备给此卡
function c53184342.eqlimit(e,c)
	return e:GetOwner()==c
end
