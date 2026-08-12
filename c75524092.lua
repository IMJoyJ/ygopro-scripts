--ヴィシャス・クロー
-- 效果：
-- 装备怪兽的攻击力上升300。装备怪兽被战斗破坏的场合，作为代替让这张卡回到手卡。再把进行战斗的对方怪兽以外的1只怪兽破坏，给与对方基本分600分伤害。那之后，在对方场上把1只「邪心衍生物」（恶魔族·暗·7星·攻/守2500）特殊召唤。这张卡回到手卡的回合「堕恶之爪」不能从手卡使用。
function c75524092.initial_effect(c)
	-- （装备魔法卡的发动与装备对象选择）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c75524092.target)
	e1:SetOperation(c75524092.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- （装备限制）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，作为代替让这张卡回到手卡。再把进行战斗的对方怪兽以外的1只怪兽破坏，给与对方基本分600分伤害。那之后，在对方场上把1只「邪心衍生物」（恶魔族·暗·7星·攻/守2500）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c75524092.desreptg)
	e4:SetOperation(c75524092.desrepop)
	c:RegisterEffect(e4)
	-- 这张卡回到手卡的回合「堕恶之爪」不能从手卡使用。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_TO_HAND)
	e5:SetOperation(c75524092.thop)
	c:RegisterEffect(e5)
end
-- 装备魔法卡发动时的对象选择与效果处理
function c75524092.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的装备效果处理
function c75524092.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 代替破坏效果的触发条件判定，检查装备怪兽是否因战斗被破坏
function c75524092.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=e:GetHandler():GetEquipTarget()
	if chk==0 then return tg and tg:IsReason(REASON_BATTLE) end
	return true
end
-- 代替破坏效果的处理，将此卡回手，破坏另1只怪兽并给与伤害，之后特招衍生物
function c75524092.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local exc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	-- 作为代替将这张卡回到持有者手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择进行战斗的对方怪兽以外的场上1只怪兽
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,exc)
	-- 破坏选择的怪兽，并给与对方600分伤害
	if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.Damage(1-tp,600,REASON_EFFECT)~=0 then
		-- 检查对方场上是否有可用的怪兽区域
		if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
			-- 检查是否可以向对方场上特殊召唤「邪心衍生物」
			and Duel.IsPlayerCanSpecialSummonMonster(tp,75524093,0,TYPES_TOKEN_MONSTER,2500,2500,7,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,1-tp) then
			-- 创建「邪心衍生物」卡片数据
			local token=Duel.CreateToken(tp,75524093)
			-- 将「邪心衍生物」在对方场上特殊召唤
			Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
-- 这张卡加入手卡时的效果处理，注册限制从手卡使用的效果
function c75524092.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsPreviousLocation(LOCATION_DECK) then
		-- 这张卡回到手卡的回合「堕恶之爪」不能从手卡使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetTarget(c75524092.limittg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册在手卡不能发动效果的限制
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SSET)
		-- 注册在手卡不能放置（盖放）的限制
		Duel.RegisterEffect(e2,tp)
	end
end
-- 限制效果的目标过滤，指定为卡名是「堕恶之爪」的卡
function c75524092.limittg(e,c)
	return c:IsCode(75524092)
end
