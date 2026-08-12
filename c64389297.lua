--迷宮変化
-- 效果：
-- 给「迷宫壁」装备。把「迷宫壁」和装备的这张卡作为祭品，从卡组把「墙壁之影」特殊召唤。
function c64389297.initial_effect(c)
	-- 给「迷宫壁」装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c64389297.target)
	e1:SetOperation(c64389297.operation)
	c:RegisterEffect(e1)
	-- 给「迷宫壁」装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c64389297.eqfilter)
	c:RegisterEffect(e2)
	-- 把「迷宫壁」和装备的这张卡作为祭品，从卡组把「墙壁之影」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64389297,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c64389297.spcost)
	e3:SetTarget(c64389297.sptg)
	e3:SetOperation(c64389297.spop)
	c:RegisterEffect(e3)
end
-- 装备限制过滤：判断卡片是否为「迷宫壁」
function c64389297.eqfilter(e,c)
	return c:IsCode(67284908)
end
-- 过滤条件：场上表侧表示的「迷宫壁」
function c64389297.filter(c)
	return c:IsFaceup() and c:IsCode(67284908)
end
-- 装备效果的发动准备：选择场上1只表侧表示的「迷宫壁」作为对象
function c64389297.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c64389297.filter(chkc) end
	-- 检查场上是否存在可以装备的「迷宫壁」
	if chk==0 then return Duel.IsExistingTarget(c64389297.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置提示信息为选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的「迷宫壁」作为效果对象
	Duel.SelectTarget(tp,c64389297.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：此效果包含装备操作，对象为这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的执行：将这张卡装备给目标怪兽
function c64389297.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽（即被装备的怪兽）
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 特殊召唤的代价：检查自身与装备的怪兽是否可以解放，并将装备的「迷宫壁」解放
function c64389297.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if chk==0 then return c:IsReleasable() and tc:IsReleasable()
		and (tc:IsControler(tp) or tc:IsHasEffect(EFFECT_EXTRA_RELEASE)) end
	-- 解放装备的「迷宫壁」作为发动代价
	Duel.Release(tc,REASON_COST)
end
-- 过滤条件：卡组中的「墙壁之影」且满足特殊召唤条件
function c64389297.spfilter(c,e,tp)
	return c:IsCode(63162310) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位以及卡组中是否存在「墙壁之影」
function c64389297.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空位（因为要解放场上的怪兽，所以空位限制为>-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在可以特殊召唤的「墙壁之影」
		and Duel.IsExistingMatchingCard(c64389297.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的执行：从卡组将「墙壁之影」特殊召唤
function c64389297.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有可用空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 设置提示信息为选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足特殊召唤条件的「墙壁之影」
	local g=Duel.SelectMatchingCard(tp,c64389297.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的「墙壁之影」无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
