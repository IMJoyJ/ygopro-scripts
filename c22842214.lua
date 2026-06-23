--シー・ランサー
-- 效果：
-- 可以选择从游戏中除外的自己的鱼族·海龙族·水族怪兽任意数量当作装备卡使用给这张卡装备。这个效果只在这张卡在场上表侧表示存在能使用1次。这个效果把怪兽装备的场合，这张卡的攻击力上升1000。此外，场上的这张卡被破坏的场合，可以作为代替把这张卡的效果装备的1只怪兽破坏。
function c22842214.initial_effect(c)
	-- 可以选择从游戏中除外的自己的鱼族·海龙族·水族怪兽任意数量当作装备卡使用给这张卡装备。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22842214,0))  --"装备怪兽"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c22842214.eqtg)
	e1:SetOperation(c22842214.eqop)
	c:RegisterEffect(e1)
	-- 场上的这张卡被破坏的场合，可以作为代替把这张卡的效果装备的1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c22842214.desreptg)
	e2:SetOperation(c22842214.desrepop)
	c:RegisterEffect(e2)
	-- 这个效果把怪兽装备的场合，这张卡的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c22842214.atcon)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查以玩家来看的除外区是否存在满足条件的鱼族·海龙族·水族怪兽
function c22842214.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and not c:IsForbidden()
end
-- 过滤函数，检查以玩家来看的指定位置是否存在满足条件的怪兽
function c22842214.opfilter(c,e)
	return c:IsRelateToEffect(e) and c22842214.filter(c)
end
-- 设置效果目标函数，用于选择从游戏中除外的自己的鱼族·海龙族·水族怪兽
function c22842214.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c22842214.filter(chkc) end
	-- 检查玩家场上魔法陷阱区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家除外区是否存在至少1张满足条件的怪兽
		and Duel.IsExistingTarget(c22842214.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 获取玩家场上魔法陷阱区的可用空位数
	local fc=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c22842214.filter,tp,LOCATION_REMOVED,0,1,fc,nil)
	-- 设置效果操作信息，记录装备的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,g:GetCount(),0,0)
end
-- 装备限制函数，确保装备卡只能装备给拥有者
function c22842214.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备怪兽效果的处理函数
function c22842214.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中目标怪兽组，并过滤出与效果相关的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c22842214.opfilter,nil,e)
	-- 获取玩家场上魔法陷阱区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local tg=Group.CreateGroup()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		if ft>=g:GetCount() then
			tg:Merge(g)
		else
			-- 提示玩家选择要装备的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			tg:Merge(g:Select(tp,ft,ft,nil))
		end
	end
	g:Sub(tg)
	local tc=tg:GetFirst()
	while tc do
		-- 将怪兽作为装备卡装备给此卡
		Duel.Equip(tp,tc,c,false,true)
		tc:RegisterFlagEffect(22842214,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 设置装备限制效果，防止其他卡装备此装备卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c22842214.eqlimit)
		tc:RegisterEffect(e1)
		tc=tg:GetNext()
	end
	-- 完成装备过程的处理
	Duel.EquipComplete()
	if g:GetCount()>0 then
		-- 将未被装备的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
-- 判断怪兽是否被此卡装备且未被破坏
function c22842214.eqfilter(c,ec)
	return c:GetFlagEffect(22842214)~=0 and c:IsHasCardTarget(ec)
end
-- 判断怪兽是否可以被代替破坏
function c22842214.repfilter(c,e,ec)
	return c22842214.eqfilter(c,ec) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 设置代替破坏效果的目标函数
function c22842214.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以发动代替破坏效果
	if chk==0 then return not c:IsReason(REASON_REPLACE) and Duel.IsExistingMatchingCard(c22842214.repfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,c) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择满足条件的怪兽作为代替破坏对象
		local tc=Duel.SelectMatchingCard(tp,c22842214.repfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,c):GetFirst()
		e:SetLabelObject(tc)
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的处理函数
function c22842214.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	g:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果和代替破坏原因破坏怪兽
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
-- 判断场上是否存在被此卡装备的怪兽
function c22842214.atcon(e)
	-- 检查场上是否存在被此卡装备的怪兽
	return Duel.IsExistingMatchingCard(c22842214.eqfilter,e:GetHandlerPlayer(),LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler())
end
