--No.6 先史遺産アトランタル
-- 效果：
-- 6星怪兽×2
-- ①：这张卡超量召唤成功时，以自己墓地1只「No.」怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力一半数值。
-- ③：1回合1次，把这张卡1个超量素材取除，把这张卡的效果装备的自己的魔法与陷阱区域1张卡送去墓地才能发动。对方基本分变成一半。这个效果发动的回合，自己不能进行战斗阶段。
function c9161357.initial_effect(c)
	-- 添加XYZ召唤手续：需要2只6星怪兽
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时，以自己墓地1只「No.」怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9161357,0))  --"装备"
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c9161357.eqcon)
	e1:SetTarget(c9161357.eqtg)
	e1:SetOperation(c9161357.eqop)
	c:RegisterEffect(e1)
	-- ③：1回合1次，把这张卡1个超量素材取除，把这张卡的效果装备的自己的魔法与陷阱区域1张卡送去墓地才能发动。对方基本分变成一半。这个效果发动的回合，自己不能进行战斗阶段。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9161357,1))  --"LP减半"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c9161357.lpcost)
	e2:SetOperation(c9161357.lpop)
	c:RegisterEffect(e2)
end
-- 设定该卡的No.数值为6
aux.xyz_number[9161357]=6
-- 判断此卡是否通过XYZ召唤成功
function c9161357.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤自己墓地中可以被装备的「No.」怪兽
function c9161357.filter(c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 装备效果的发动准备：检查魔陷区空位及墓地是否存在可装备的「No.」怪兽，并选择该怪兽作为对象
function c9161357.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c9161357.filter(chkc) end
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在可以作为对象的「No.」怪兽
		and Duel.IsExistingTarget(c9161357.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只「No.」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c9161357.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：涉及卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 装备效果的执行：将选择的墓地怪兽作为装备卡装备给这张卡，并使其攻击力上升该怪兽攻击力一半的数值，同时为装备卡添加代号标记
function c9161357.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c9161357.eqlimit)
		tc:RegisterEffect(e1)
		local atk=math.ceil(tc:GetBaseAttack()/2)
		if atk>0 then
			-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力一半数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
		tc:RegisterFlagEffect(9161357,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 限制装备卡只能装备给这张卡
function c9161357.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤由这张卡的效果装备在自己魔陷区且能作为Cost送去墓地的卡
function c9161357.lpfilter(c,tp)
	return c:GetFlagEffect(9161357)~=0 and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:IsAbleToGraveAsCost()
end
-- 减半LP效果的Cost与发动条件：只能在主要阶段1发动，检查是否有可送墓的装备卡以及可取除的超量素材，并执行取除素材、送墓装备卡和限制本回合不能进行战斗阶段的操作
function c9161357.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup()
	-- 检查当前是否为主要阶段1，以及是否存在由这张卡的效果装备的自己的魔陷区卡片
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 and eqg:IsExists(c9161357.lpfilter,1,nil,tp)
		and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	local ec=eqg:FilterSelect(tp,c9161357.lpfilter,1,1,nil,tp)
	-- 将选中的装备卡作为Cost送去墓地
	Duel.SendtoGrave(ec,REASON_COST)
	-- 对方基本分变成一半。这个效果发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制玩家本回合不能进行战斗阶段
	Duel.RegisterEffect(e1,tp)
end
-- 减半LP效果的执行：将对方的生命值变成一半（向上取整）
function c9161357.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方玩家的生命值设定为当前生命值的一半（向上取整）
	Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
end
