--王女の試練
-- 效果：
-- 「白魔导士 绒儿」「黑魔导师 库兰」才能装备。装备怪兽攻击力上升800。装备怪兽因战斗破坏5星以上的怪兽的回合，可以把装备怪兽和这张卡作为祭品，「白魔导士 绒儿」对应「魔法之国的王女-绒儿」，「黑魔导师 库兰」对应「魔法之国的王女-库兰」从手卡·卡组特殊召唤1只。
function c72709014.initial_effect(c)
	-- 注册卡片效果中提及的卡片密码列表（白魔导士 绒儿、黑魔导师 库兰、魔法之国的王女-绒儿、魔法之国的王女-库兰）。
	aux.AddCodeList(c,81383947,46128076,75917088,2316186)
	-- 「白魔导士 绒儿」「黑魔导师 库兰」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c72709014.target)
	e1:SetOperation(c72709014.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 「白魔导士 绒儿」「黑魔导师 库兰」才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c72709014.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽因战斗破坏5星以上的怪兽的回合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c72709014.regop)
	c:RegisterEffect(e4)
	-- 可以把装备怪兽和这张卡作为祭品，「白魔导士 绒儿」对应「魔法之国的王女-绒儿」，「黑魔导师 库兰」对应「魔法之国的王女-库兰」从手卡·卡组特殊召唤1只。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(72709014,0))  --"特殊召唤"
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c72709014.spcon)
	e5:SetCost(c72709014.spcost)
	e5:SetTarget(c72709014.sptg)
	e5:SetOperation(c72709014.spop)
	c:RegisterEffect(e5)
end
-- 装备限制：只能装备给「白魔导士 绒儿」或「黑魔导师 库兰」。
function c72709014.eqlimit(e,c)
	return c:IsCode(81383947,46128076)
end
-- 过滤场上表侧表示的「白魔导士 绒儿」或「黑魔导师 库兰」。
function c72709014.filter(c)
	return c:IsFaceup() and c:IsCode(81383947,46128076)
end
-- 装备魔法卡发动时的效果靶向处理（选择装备对象）。
function c72709014.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c72709014.filter(chkc) end
	-- 检查场上是否存在可以装备的合法怪兽。
	if chk==0 then return Duel.IsExistingTarget(c72709014.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的怪兽作为装备对象并将其设为效果对象。
	Duel.SelectTarget(tp,c72709014.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息：将自身作为装备卡装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动时的效果处理（执行装备）。
function c72709014.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤因战斗破坏5星以上怪兽的装备怪兽。
function c72709014.regfilter(c,ec)
	return c==ec and c:GetBattleTarget():IsLevelAbove(5)
end
-- 装备怪兽战斗破坏5星以上怪兽时，给这张卡注册一个在该回合内有效的标记（Flag）。
function c72709014.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c72709014.regfilter,1,nil,e:GetHandler():GetEquipTarget()) then
		e:GetHandler():RegisterFlagEffect(72709014,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 特殊召唤效果的发动条件：这张卡在本回合内注册了战斗破坏5星以上怪兽的标记。
function c72709014.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(72709014)~=0
end
-- 特殊召唤效果的发动代价：解放装备怪兽（这张卡作为装备卡也会随之送去墓地，相当于把装备怪兽和这张卡作为祭品）。
function c72709014.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec:IsReleasable() end
	e:SetLabel(ec:GetCode())
	-- 解放装备怪兽作为发动的代价。
	Duel.Release(ec,REASON_COST)
end
-- 过滤手卡或卡组中与被解放的装备怪兽相对应的“魔法之国的王女”怪兽。
function c72709014.spfilter(c,e,tp,code)
	return ((code==81383947 and c:IsCode(75917088)) or (code==46128076 and c:IsCode(2316186)))
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果的发动准备（检查怪兽区域空格和手卡·卡组中是否存在可特殊召唤的对应怪兽）。
function c72709014.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空格（因为要解放场上的装备怪兽，所以可用空格数大于-1即可）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在可以特殊召唤的对应“魔法之国的王女”怪兽。
		and Duel.IsExistingMatchingCard(c72709014.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,e:GetHandler():GetEquipTarget():GetCode()) end
	-- 设置连锁处理信息：从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的具体处理（从手卡·卡组特殊召唤对应的“魔法之国的王女”）。
function c72709014.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有可用空格，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只与被解放的装备怪兽相对应的“魔法之国的王女”怪兽。
	local g=Duel.SelectMatchingCard(tp,c72709014.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()~=0 then
		-- 将选择的怪兽无视召唤条件表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
