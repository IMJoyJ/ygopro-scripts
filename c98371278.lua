--DMZドラゴン
-- 效果：
-- ①：1回合1次，以自己墓地1只4星以下的龙族怪兽和自己场上1只龙族怪兽为对象才能发动。作为对象的墓地的怪兽当作攻击力上升500的装备卡使用给作为对象的场上的怪兽装备。
-- ②：有装备卡装备的自己怪兽攻击的伤害步骤结束时，把墓地的这张卡除外才能发动。那只自己怪兽的装备卡全部破坏。破坏的场合，那只怪兽只再1次可以继续攻击。
function c98371278.initial_effect(c)
	-- ①：1回合1次，以自己墓地1只4星以下的龙族怪兽和自己场上1只龙族怪兽为对象才能发动。作为对象的墓地的怪兽当作攻击力上升500的装备卡使用给作为对象的场上的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98371278,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c98371278.eqtg)
	e1:SetOperation(c98371278.eqop)
	c:RegisterEffect(e1)
	-- ②：有装备卡装备的自己怪兽攻击的伤害步骤结束时，把墓地的这张卡除外才能发动。那只自己怪兽的装备卡全部破坏。破坏的场合，那只怪兽只再1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98371278,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c98371278.atkcon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c98371278.atktg)
	e2:SetOperation(c98371278.atkop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地4星以下的龙族怪兽
function c98371278.eqfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevelBelow(4)
end
-- 过滤自己场上表侧表示的龙族怪兽
function c98371278.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 效果①的发动条件判定与对象选择
function c98371278.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定自己魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己墓地是否存在满足条件的龙族怪兽
		and Duel.IsExistingTarget(c98371278.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 判定自己场上是否存在满足条件的龙族怪兽
		and Duel.IsExistingTarget(c98371278.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只4星以下的龙族怪兽作为对象
	local g=Duel.SelectTarget(tp,c98371278.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择效果的对象（装备的目标）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只龙族怪兽作为对象
	Duel.SelectTarget(tp,c98371278.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g:GetFirst(),1,0,0)
	-- 设置连锁信息，表示该效果包含卡片离开墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g:GetFirst(),1,0,0)
end
-- 效果①的处理：将墓地的对象怪兽作为装备卡装备给场上的对象怪兽，并使其攻击力上升500
function c98371278.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象的墓地怪兽
	local tc1=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	-- 获取作为对象的场上怪兽
	local tc2=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsLocation,nil,LOCATION_MZONE):GetFirst()
	-- 确认两个对象依然合法，且墓地的对象不受王家长眠之谷影响
	if tc1 and tc2 and tc1:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc1) then
		-- 将墓地的怪兽装备给场上的怪兽，若装备失败则结束处理
		if not Duel.Equip(tp,tc1,tc2) then return end
		-- 当作...装备卡使用给作为对象的场上的怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c98371278.eqlimit)
		e1:SetLabelObject(tc2)
		tc1:RegisterEffect(e1)
		-- 攻击力上升500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc1:RegisterEffect(e2)
	end
end
-- 限制装备卡只能装备给作为对象的场上怪兽
function c98371278.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果②的发动条件判定：有装备卡装备的自己怪兽攻击的伤害步骤结束时
function c98371278.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local at=Duel.GetAttacker()
	return at:IsControler(tp) and at:GetEquipCount()>0 and at:IsChainAttackable()
end
-- 效果②的对象与连锁信息设置
function c98371278.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取该攻击怪兽装备的所有装备卡
	local g=Duel.GetAttacker():GetEquipGroup()
	-- 设置连锁信息，表示该效果会破坏这些装备卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果②的处理：破坏该怪兽的所有装备卡，并使其可以再进行1次攻击
function c98371278.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local at=Duel.GetAttacker()
	local g=at:GetEquipGroup()
	-- 确认攻击怪兽由自己控制，并破坏其所有的装备卡
	if at:IsControler(tp) and Duel.Destroy(g,REASON_EFFECT)>0 then
		-- 使该怪兽可以再进行1次攻击
		Duel.ChainAttack()
	end
end
