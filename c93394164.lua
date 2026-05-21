--パラレル・パンツァー
-- 效果：
-- 连接怪兽才能装备。这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己主要阶段才能发动。装备怪兽的位置向那只怪兽所连接区的主要怪兽区域移动（不能向从那只怪兽来看的对方场上移动）。
-- ②：把装备的这张卡送去墓地才能发动。选和这张卡装备过的场上的怪兽相同纵列1张卡破坏。
function c93394164.initial_effect(c)
	-- 连接怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c93394164.target)
	e1:SetOperation(c93394164.operation)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。装备怪兽的位置向那只怪兽所连接区的主要怪兽区域移动（不能向从那只怪兽来看的对方场上移动）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93394164,0))  --"移动位置"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c93394164.seqtg)
	e2:SetOperation(c93394164.seqop)
	c:RegisterEffect(e2)
	-- ②：把装备的这张卡送去墓地才能发动。选和这张卡装备过的场上的怪兽相同纵列1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93394164,1))  --"卡片破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,93394164)
	e3:SetCost(c93394164.descost)
	e3:SetTarget(c93394164.destg)
	e3:SetOperation(c93394164.desop)
	c:RegisterEffect(e3)
	-- 连接怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetValue(c93394164.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给连接怪兽
function c93394164.eqlimit(e,c)
	return c:IsType(TYPE_LINK)
end
-- 过滤条件：场上表侧表示的连接怪兽
function c93394164.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 放入连锁：装备魔法卡发动时的对象选择与效果处理准备
function c93394164.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c93394164.filter(chkc) end
	-- 检查场上是否存在可以作为装备对象的表侧表示连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c93394164.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的连接怪兽作为装备对象
	Duel.SelectTarget(tp,c93394164.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将这张卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给选择的怪兽
function c93394164.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备魔法卡发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 放入连锁：检查装备怪兽所连接区的主要怪兽区域是否有空位
function c93394164.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	local p=ec:GetControler()
	local zone=bit.band(ec:GetLinkedZone(),0x1f)
	-- 检查装备怪兽控制者的主要怪兽区域中，属于该怪兽连接区的空格数是否大于0
	if chk==0 then return Duel.GetLocationCount(p,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 end
end
-- 效果处理：将装备怪兽移动到其连接区的主要怪兽区域
function c93394164.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec or ec:IsImmuneToEffect(e) then return end
	local p=ec:GetControler()
	local zone=bit.band(ec:GetLinkedZone(),0x1f)
	-- 再次确认该怪兽连接区的主要怪兽区域是否有可用空位
	if Duel.GetLocationCount(p,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 then
		local s=0
		if ec:IsControler(tp) then
			local flag=bit.bxor(zone,0xff)
			-- 提示己方玩家选择要移动到的主要怪兽区域
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让己方玩家在自己场上属于该怪兽连接区的可用主要怪兽区域中选择一个位置
			s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
		else
			local flag=bit.bxor(zone,0xff)*0x10000
			-- 提示己方玩家选择对方场上要移动到的主要怪兽区域
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让己方玩家在对方场上属于该怪兽连接区的可用主要怪兽区域中选择一个位置，并转换区域标记
			s=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,flag)/0x10000
		end
		local nseq=0
		if s==1 then nseq=0
		elseif s==2 then nseq=1
		elseif s==4 then nseq=2
		elseif s==8 then nseq=3
		else nseq=4 end
		-- 将装备怪兽移动到选择的怪兽区域
		Duel.MoveSequence(ec,nseq)
	end
end
-- 发动代价：将装备的这张卡送去墓地，并记录原本装备的怪兽
function c93394164.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	local tc=e:GetHandler():GetEquipTarget()
	-- 将原本装备的怪兽设为当前连锁的广义对象，以便后续获取其纵列信息
	Duel.SetTargetCard(tc)
	-- 将作为装备卡的这张卡送去墓地作为发动的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：属于指定卡片相同纵列的卡片
function c93394164.desfilter(c,g)
	return g:IsContains(c)
end
-- 放入连锁：确认并设置要破坏的相同纵列卡片的操作信息
function c93394164.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then
		if not ec then return false end
		local tg=ec:GetColumnGroup()
		tg:AddCard(ec)
		-- 检查场上是否存在与装备怪兽处于相同纵列的卡片（不含这张卡自身）
		return Duel.IsExistingMatchingCard(c93394164.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,tg)
	end
	-- 获取发动时记录的原本装备的怪兽
	local tc=Duel.GetFirstTarget()
	local tg=tc:GetColumnGroup()
	tg:AddCard(tc)
	-- 获取场上所有与该怪兽处于相同纵列的卡片集合
	local g=Duel.GetMatchingGroup(c93394164.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tg)
	-- 设置操作信息：准备破坏1张相同纵列的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：选择并破坏1张与原本装备怪兽相同纵列的卡片
function c93394164.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取原本装备的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local tg=tc:GetColumnGroup()
	tg:AddCard(tc)
	-- 获取当前场上与该怪兽处于相同纵列的所有卡片
	local g=Duel.GetMatchingGroup(c93394164.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tg)
	if g:GetCount()>0 then
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 给选中的卡片显示被选择的动画效果
		Duel.HintSelection(sg)
		-- 破坏选择的卡片
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
