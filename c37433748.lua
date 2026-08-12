--SPYRAL GEAR－ラスト・リゾート
-- 效果：
-- ①：自己主要阶段以自己场上1只「秘旋谍」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。装备怪兽不会被战斗·效果破坏，不会成为对方的效果的对象。
-- ②：1回合1次，这张卡的效果让这张卡装备中的场合，把这张卡以外的自己场上1张卡送去墓地才能发动。这个回合，装备怪兽可以直接攻击。
function c37433748.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「秘旋谍」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37433748,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c37433748.eqtg)
	e1:SetOperation(c37433748.eqop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为场上正面表示的「秘旋谍」怪兽
function c37433748.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xee)
end
-- 效果处理的条件判断，检查是否有满足条件的怪兽可作为装备对象
function c37433748.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37433748.eqfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家场上是否存在满足条件的「秘旋谍」怪兽
		and Duel.IsExistingTarget(c37433748.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上满足条件的「秘旋谍」怪兽作为装备对象
	Duel.SelectTarget(tp,c37433748.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 装备效果的处理函数，执行装备操作并设置相关效果
function c37433748.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取当前连锁中选择的装备对象
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足，包括装备区域是否足够、目标怪兽是否合法等
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若装备条件不满足，则将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 装备对象限制效果，确保只有指定的怪兽能装备此卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c37433748.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 装备怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果值，使装备怪兽不会成为对方的效果对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ②：1回合1次，这张卡的效果让这张卡装备中的场合，把这张卡以外的自己场上1张卡送去墓地才能发动。这个回合，装备怪兽可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(37433748,1))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c37433748.dircon)
	e5:SetCost(c37433748.dircost)
	e5:SetOperation(c37433748.dirop)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e5)
end
-- 装备对象限制的过滤函数，确保只有装备目标怪兽能装备此卡
function c37433748.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断是否能进入战斗阶段
function c37433748.dircon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤函数，用于判断是否为可作为墓地代价的卡
function c37433748.cfilter(c,ec)
	return c:IsAbleToGraveAsCost() and c~=ec
end
-- 效果处理的条件判断，检查是否有满足条件的卡可作为墓地代价
function c37433748.dircost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 检查是否有满足条件的卡可作为墓地代价
	if chk==0 then return ec and Duel.IsExistingMatchingCard(c37433748.cfilter,tp,LOCATION_ONFIELD,0,1,c,ec) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡送去墓地
	local g=Duel.SelectMatchingCard(tp,c37433748.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,ec)
	-- 将选择的卡送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 装备怪兽可以直接攻击效果的处理函数
function c37433748.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 装备怪兽可以直接攻击效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
