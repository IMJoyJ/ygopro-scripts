--D・クリーナン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：1回合1次，可以把这张卡装备的1张装备卡送去墓地，给与对方基本分500分伤害。
-- ●守备表示：1回合1次，可以把对方场上表侧攻击表示存在的1只怪兽当作装备卡使用只有1只给这张卡装备。
function c48868994.initial_effect(c)
	-- ●攻击表示：1回合1次，可以把这张卡装备的1张装备卡送去墓地，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48868994,0))  --"给与对方500伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c48868994.cona)
	e1:SetCost(c48868994.costa)
	e1:SetTarget(c48868994.tga)
	e1:SetOperation(c48868994.opa)
	c:RegisterEffect(e1)
	-- ●守备表示：1回合1次，可以把对方场上表侧攻击表示存在的1只怪兽当作装备卡使用只有1只给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48868994,1))  --"装备"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c48868994.cond)
	e2:SetTarget(c48868994.tgd)
	e2:SetOperation(c48868994.opd)
	c:RegisterEffect(e2)
end
-- 发动条件：这张卡未被无效化且处于攻击表示。
function c48868994.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 代价处理：从这张卡装备的装备卡中选出1张可作为代价的卡并送去墓地；若无可选则不满足发动条件。
function c48868994.costa(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(Card.IsAbleToGraveAsCost,1,nil) end
	-- 提示玩家选择要送去墓地的装备卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,Card.IsAbleToGraveAsCost,1,1,nil)
	-- 将所选装备卡作为代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时指定目标玩家为对方，伤害数值为500，并登记伤害操作信息。
function c48868994.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的对象参数设为500（伤害值）。
	Duel.SetTargetParam(500)
	-- 登记操作信息：本连锁将给与对方500点伤害，用于相关卡片的判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：按照登记的对象玩家和数值给对方造成效果伤害。
function c48868994.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 发动条件：这张卡未被无效化、处于守备表示，且尚未通过自身效果装备怪兽（没有48868994标记）。
function c48868994.cond(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
		and not e:GetHandler():IsHasEffect(48868994)
end
-- 筛选对象：对方场上表侧攻击表示且控制权可变更的怪兽。
function c48868994.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsAbleToChangeControler()
end
-- 发动时检查：对手场上有符合条件的怪兽，且己方魔陷区有空位；同时验证选择的目标是否合法。
function c48868994.tgd(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c48868994.filter(chkc) end
	-- 合法性检查：自己魔陷区存在空格，用于放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且存在至少1只符合条件的对方怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c48868994.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只符合条件的表侧攻击表示怪兽作为对象。
	local g=Duel.SelectTarget(tp,c48868994.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备限制：该装备卡（原怪兽）只能装备给这张卡，且这张卡未被无效化。
function c48868994.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
-- 效果处理：把目标怪兽作为装备卡装备给这张卡，并追加装备限制和标记效果，防止重复装备。
function c48868994.opd(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackPos() then
		-- 尝试将目标怪兽作为装备卡装备给这张卡（保持原表示形式），失败则结束处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD)
		e:SetLabelObject(tc)
		-- 只有1只给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c48868994.eqlimit)
		tc:RegisterEffect(e1)
		-- 当作装备卡使用。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(48868994)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
