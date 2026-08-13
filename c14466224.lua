--The アトモスフィア
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的2只怪兽和自己墓地存在的1只怪兽从游戏中除外的场合可以特殊召唤。1回合1次，可以把对方场上表侧表示存在的怪兽当作装备卡使用只有1只给这张卡装备。这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值。
function c14466224.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己场上存在的2只怪兽和自己墓地存在的1只怪兽从游戏中除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14466224.spcon)
	e1:SetTarget(c14466224.sptg)
	e1:SetOperation(c14466224.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把对方场上表侧表示存在的怪兽当作装备卡使用只有1只给这张卡装备。这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14466224,0))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c14466224.eqcon)
	e2:SetTarget(c14466224.eqtg)
	e2:SetOperation(c14466224.eqop)
	c:RegisterEffect(e2)
end
-- 筛选可作为特殊召唤除外素材的卡：必须是怪兽且可以作为COST除外。
function c14466224.gfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 判断在候选素材组g中，怪兽c位于墓地，并且组里还存在至少2只位于主要怪兽区的怪兽（即素材组合必须包含1张墓地怪兽和2张场上怪兽）。
function c14466224.fcheck(c,g)
	return c:IsLocation(LOCATION_GRAVE) and g:IsExists(Card.IsLocation,2,c,LOCATION_MZONE)
end
-- 判定选择的3张素材是否合法：除外这些卡后己方场上仍有怪兽区空位，且素材组合满足至少1张墓地怪兽和2张场上怪兽。
function c14466224.fselect(g,tp)
	-- 具体合法性判定：素材组g通过场上空位检查，且组内存在1张墓地怪兽并同时有2张位于怪兽区的怪兽。
	return aux.mzctcheck(g,tp) and g:IsExists(c14466224.fcheck,1,nil,g)
end
-- 特殊召唤规则效果的发动条件：在手牌中的这张卡进行特殊召唤时，检查自己和场上·墓地是否存在一组符合条件的素材（2只场上怪兽+1只墓地怪兽）且除外后场上仍有空位。
function c14466224.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取所有可以作为特殊召唤除外素材的候选卡：己方场上与墓地的、可作为COST除外的怪兽。
	local g=Duel.GetMatchingGroup(c14466224.gfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return g:CheckSubGroup(c14466224.fselect,3,3,tp)
end
-- 特殊召唤规则的选择阶段：让玩家从候选素材中选择3张（2只场上怪兽+1只墓地怪兽），若选择成功则保存该组素材并允许进行特殊召唤。
function c14466224.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有可作为特殊召唤除外素材的候选卡：己方场上与墓地的、可作为COST除外的怪兽。
	local g=Duel.GetMatchingGroup(c14466224.gfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 显示“请选择要除外的卡”提示信息，提示玩家选择作为特殊召唤代价的素材。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c14466224.fselect,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的效果处理：将之前选择保存的素材组从游戏中除外，完成特殊召唤手续。
function c14466224.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的素材卡以表侧表示从游戏中除外，作为特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 装备效果的发动条件：这张卡当前没有装备对象，或者已装备的怪兽已经不是装备状态（即没有这张卡装备效果的flag），以保证每次最多装备1只。
function c14466224.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	return ec==nil or ec:GetFlagEffect(14466224)==0
end
-- 筛选可作为装备对象的对方怪兽：必须是表侧表示，且控制权可以变更（能够被装备）。
function c14466224.filter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 装备效果的发动条件与目标选择：检查己方魔陷区有空位、对方场上有满足条件的表侧怪兽；选择1只作为装备对象，并在连锁处理时校验目标合法性。
function c14466224.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c14466224.filter(chkc) end
	-- 效果发动时检查己方魔陷区是否有空位，若无空位则不能发动装备效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 同时确认对方场上有至少1只满足条件的表侧表示怪兽可以作为装备目标。
		and Duel.IsExistingTarget(c14466224.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示“请选择要装备的卡”提示信息，引导玩家选择要装备的对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只对方场上的表侧且可变更控制权的怪兽，并将其登记为本效果的取对象目标。
	local g=Duel.SelectTarget(tp,c14466224.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制判定函数：该装备卡只能装备给效果持有者（大气圈神鸟），防止其被错误装备到其他怪兽身上。
function c14466224.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果的处理流程：以对方怪兽为对象进行装备，装备成功后赋予其flag标记和攻击力/守备力上升效果；若目标不再合法则终止处理。
function c14466224.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetTextAttack()
		local def=tc:GetTextDefense()
		if atk<0 then atk=0 end
		if def<0 then def=0 end
		-- 尝试将目标怪兽作为装备卡装备给大气圈神鸟；若装备失败（如魔陷区已无空位或不符合装备条件）则立即终止后续处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(14466224,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- 把对方场上表侧表示存在的怪兽当作装备卡使用只有1只给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c14466224.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- 这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
		if def>0 then
			-- 这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_EQUIP)
			e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e3:SetCode(EFFECT_UPDATE_DEFENSE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(def)
			tc:RegisterEffect(e3)
		end
	end
end
