--機皇神龍トリスケリア
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把「机皇」怪兽3种类各1只除外的场合可以特殊召唤。
-- ①：1回合1次，这张卡的攻击宣言时才能发动。把对方的额外卡组确认，选那之内的1只怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：有同调怪兽装备的这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
function c4837861.initial_effect(c)
	c:EnableReviveLimit()
	-- 从自己墓地把「机皇」怪兽3种类各1只除外的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c4837861.spcon)
	e2:SetTarget(c4837861.sptg)
	e2:SetOperation(c4837861.spop)
	c:RegisterEffect(e2)
	-- 1回合1次，这张卡的攻击宣言时才能发动。把对方的额外卡组确认，选那之内的1只怪兽当作装备卡使用给这张卡装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4837861,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1)
	e3:SetTarget(c4837861.eqtg)
	e3:SetOperation(c4837861.eqop)
	c:RegisterEffect(e3)
	-- 有同调怪兽装备的这张卡在同1次的战斗阶段中最多3次可以向怪兽攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c4837861.pcon)
	e4:SetValue(2)
	c:RegisterEffect(e4)
end
-- 过滤满足「机皇」字段、怪兽类型且可作为除外费用的卡片。
function c4837861.spfilter(c)
	return c:IsSetCard(0x13) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件：墓地存在至少3种类不同的「机皇」怪兽。
function c4837861.spcon(e,c)
	if c==nil then return true end
	-- 若场上没有空位则不能特殊召唤。
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 获取玩家墓地中所有符合条件的「机皇」怪兽。
	local g=Duel.GetMatchingGroup(c4837861.spfilter,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>=3
end
-- 选择3张不同种类的「机皇」怪兽除外作为特殊召唤条件。
function c4837861.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地中所有符合条件的「机皇」怪兽。
	local g=Duel.GetMatchingGroup(c4837861.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置额外检查条件为卡名各不相同。
	aux.GCheckAdditional=aux.dncheck
	-- 从符合条件的卡片中选择3张不同种类的卡片组成组。
	local rg=g:SelectSubGroup(tp,aux.TRUE,true,3,3)
	-- 取消额外检查条件。
	aux.GCheckAdditional=nil
	if rg then
		rg:KeepAlive()
		e:SetLabelObject(rg)
		return true
	else return false end
end
-- 执行特殊召唤操作，将选中的卡片除外。
function c4837861.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=e:GetLabelObject()
	-- 将选中的卡片从游戏中除外。
	Duel.Remove(rg,POS_FACEUP,REASON_SPSUMMON)
	rg:DeleteGroup()
end
-- 判断卡片是否可装备且未被禁止。
function c4837861.eqfilter(c,tp)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 判断卡片是否为里侧表示或可装备。
function c4837861.filter(c,tp)
	return c:IsFacedown() or c4837861.eqfilter(c,tp)
end
-- 判断是否满足装备效果发动条件：场上存在可装备的额外卡组怪兽。
function c4837861.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方额外卡组的所有怪兽。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 若场上没有空位或额外卡组无怪兽则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and g:GetCount()>0
		and g:IsExists(c4837861.filter,1,nil,tp) end
end
-- 执行装备操作，确认对方额外卡组并选择一张怪兽进行装备。
function c4837861.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若场上无空位、此卡为里侧表示或不与效果相关则无法发动。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 获取对方额外卡组的所有怪兽。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 向玩家展示对方额外卡组的全部怪兽。
	Duel.ConfirmCards(tp,g,true)
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	local sg=g:FilterSelect(tp,c4837861.eqfilter,1,1,nil,tp)
	local tc=sg:GetFirst()
	if tc then
		-- 尝试将选中的怪兽装备给此卡。
		if Duel.Equip(tp,tc,c) then
			local atk=tc:GetTextAttack()
			-- 设置装备限制效果，防止其他卡片装备到此卡。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c4837861.eqlimit)
			tc:RegisterEffect(e1)
			if atk>0 then
				-- 若装备怪兽攻击力大于0，则提升此卡攻击力。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(atk)
				tc:RegisterEffect(e2)
			end
		end
	end
	-- 将对方额外卡组洗牌。
	Duel.ShuffleExtra(1-tp)
end
-- 判断装备的卡片是否为本卡。
function c4837861.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤场上正面表示的同调怪兽。
function c4837861.xatkfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_SYNCHRO~=0
end
-- 判断是否有同调怪兽装备于此卡。
function c4837861.pcon(e)
	return e:GetHandler():GetEquipGroup():IsExists(c4837861.xatkfilter,1,nil)
end
