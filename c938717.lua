--起動兵長コマンドリボルバー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己的场上·墓地最多2只机械族「零件」怪兽为对象才能发动（同名卡最多1张）。这张卡从手卡特殊召唤。那之后，作为对象的自己的「零件」怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽数量×1000。
function c938717.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：以自己的场上·墓地最多2只机械族「零件」怪兽为对象才能发动（同名卡最多1张）。这张卡从手卡特殊召唤。那之后，作为对象的自己的「零件」怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(938717,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,938717)
	e1:SetTarget(c938717.sptg)
	e1:SetOperation(c938717.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c938717.atkval)
	c:RegisterEffect(e2)
end
-- 过滤自己场上或墓地的机械族「零件」怪兽，且该卡可以成为效果对象，并且在场上唯一存在
function c938717.eqfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x51) and c:IsRace(RACE_MACHINE) and c:IsCanBeEffectTarget(e) and c:CheckUniqueOnField(tp)
end
-- ①的效果的发动准备，检查是否满足特殊召唤及选择装备对象的条件
function c938717.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上·墓地所有满足条件的机械族「零件」怪兽
	local g=Duel.GetMatchingGroup(c938717.eqfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,e,tp)
	-- 计算自己魔陷区可用空格数与2的较小值，决定最多可以装备的数量
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_SZONE)),2)
	-- 检查可行性：自己主要怪兽区有空位、魔陷区有空位、存在可选对象，且手卡的这张卡可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ft>0
		and g:GetCount()>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择最多2张卡名不同的对象怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	-- 将选择的怪兽群组设置为效果的对象
	Duel.SetTargetCard(sg)
	local tg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	if tg:GetCount()>0 then
		-- 若对象中包含墓地的卡，设置卡片离开墓地的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tg,tg:GetCount(),0,0)
	end
end
-- 过滤仍存在于场上或墓地且仍与效果关联的对象怪兽
function c938717.tgfilter(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsRelateToEffect(e)
end
-- ①的效果的处理，执行特殊召唤和装备操作
function c938717.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 尝试将这张卡从手卡表侧表示特殊召唤，若特殊召唤成功则继续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前自己魔法与陷阱区域的可用空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		-- 获取当前连锁中仍合法的对象怪兽
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c938717.tgfilter,nil,e)
		if ft<g:GetCount() then return end
		-- 中断效果处理，使后续的装备处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		local tc=g:GetFirst()
		while tc do
			-- 将对象怪兽作为装备卡装备给这张卡
			Duel.Equip(tp,tc,c,false,true)
			-- 当作装备卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(c938717.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(938717,RESET_EVENT+RESETS_STANDARD,0,1)
			tc=g:GetNext()
		end
		-- 完成装备流程，触发装备成功的时点
		Duel.EquipComplete()
	end
end
-- 装备限制函数，规定该装备卡只能装备给此卡
function c938717.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤由这张卡自身效果装备的怪兽
function c938717.atkfilter(c)
	return c:GetFlagEffect(938717)~=0
end
-- 计算攻击力上升值，数量为由自身效果装备的怪兽数乘以1000
function c938717.atkval(e,c)
	return c:GetEquipGroup():FilterCount(c938717.atkfilter,nil)*1000
end
