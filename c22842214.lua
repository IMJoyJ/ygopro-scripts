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
	-- 此外，场上的这张卡被破坏的场合，可以作为代替把这张卡的效果装备的1只怪兽破坏。
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
-- 过滤可选的除外区怪兽：必须表侧表示、种族为鱼族/海龙族/水族，且没有被禁止作为装备卡的限制。
function c22842214.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and not c:IsForbidden()
end
-- 处理阶段再过滤：对象必须与当前效果仍有关联并继续满足装备条件。
function c22842214.opfilter(c,e)
	return c:IsRelateToEffect(e) and c22842214.filter(c)
end
-- 发动时的目标选择：从自己除外区的符合条件的怪兽中任意选择，数量不能超过魔陷区可用空格，并登记为取对象。
function c22842214.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c22842214.filter(chkc) end
	-- 发动条件：自己魔陷区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件：除外区存在至少1只符合条件的表侧怪兽可选择。
		and Duel.IsExistingTarget(c22842214.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 获取自己魔陷区当前可用空格数，作为最多可选数量。
	local fc=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 弹出提示，让玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从除外区选择1至fc张符合条件的怪兽，并设置为效果对象。
	local g=Duel.SelectTarget(tp,c22842214.filter,tp,LOCATION_REMOVED,0,1,fc,nil)
	-- 登记操作信息：将所选怪兽作为装备卡装备，数量为所选数量。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,g:GetCount(),0,0)
end
-- 装备限制：该装备卡只能装备给效果所有者（即海洋枪兵），不能转移给其他怪兽。
function c22842214.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：取得仍有效的对象，若魔陷区空位足够则全部装备，不足则让玩家选择可装备的部分，其余送去墓地；对每张装备成功的怪兽打上标记并赋予装备限制，最后完成装备。
function c22842214.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从连锁对象中取出本次效果选择的目标，并过滤掉已不关联或不符合条件的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c22842214.opfilter,nil,e)
	-- 处理时重新获取魔陷区可用空格数，用于判断能否全部装备。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local tg=Group.CreateGroup()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		if ft>=g:GetCount() then
			tg:Merge(g)
		else
			-- 当可用区域不足时，提示玩家选择实际要装备的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			tg:Merge(g:Select(tp,ft,ft,nil))
		end
	end
	g:Sub(tg)
	local tc=tg:GetFirst()
	while tc do
		-- 将选中的怪兽作为装备卡装备给海洋枪兵，使用分步装备模式。
		Duel.Equip(tp,tc,c,false,true)
		tc:RegisterFlagEffect(22842214,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c22842214.eqlimit)
		tc:RegisterEffect(e1)
		tc=tg:GetNext()
	end
	-- 完成分步装备，触发装备成功的时点。
	Duel.EquipComplete()
	if g:GetCount()>0 then
		-- 将因区域不足而未能装备的剩余对象以规则原因送去墓地。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
-- 判断某卡是否为这张卡的效果装备的怪兽：带有标记且装备对象是海洋枪兵。
function c22842214.eqfilter(c,ec)
	return c:GetFlagEffect(22842214)~=0 and c:IsHasCardTarget(ec)
end
-- 代替破坏候选条件：是由本卡效果装备的怪兽、可被效果破坏，且未被预定破坏。
function c22842214.repfilter(c,e,ec)
	return c22842214.eqfilter(c,ec) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的发动处理：当海洋枪兵将要被破坏时，选择1只符合条件的装备怪兽作为代破对象。
function c22842214.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件：本次破坏不是由代替破坏引起，且场上存在至少1只可代替破坏的装备怪兽。
	if chk==0 then return not c:IsReason(REASON_REPLACE) and Duel.IsExistingMatchingCard(c22842214.repfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e,c) end
	-- 询问玩家是否发动代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要代替破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从符合条件的装备怪兽中选择1只，作为代替破坏的对象。
		local tc=Duel.SelectMatchingCard(tp,c22842214.repfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e,c):GetFirst()
		e:SetLabelObject(tc)
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏处理：清除预定破坏标记，并将选择的装备怪兽破坏，代替海洋枪兵被破坏。
function c22842214.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	g:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 把选择的装备怪兽以效果破坏（作为代替破坏）。
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
-- 攻击力上升条件：场上存在由这张卡的效果装备的怪兽。
function c22842214.atcon(e)
	-- 检查场上是否存在至少1只由这张卡效果装备的怪兽，以决定攻击力是否上升。
	return Duel.IsExistingMatchingCard(c22842214.eqfilter,e:GetHandlerPlayer(),LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler())
end
