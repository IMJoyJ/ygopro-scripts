--鎧黒竜－サイバー・ダーク・ドラゴン
-- 效果：
-- 「电子暗黑魔角」＋「电子暗黑刃翼」＋「电子暗黑龙骨」
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡特殊召唤成功的场合，以自己墓地1只龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值以及自己墓地的怪兽数量×100。
-- ③：这张卡被战斗破坏的场合，作为代替把装备的那只怪兽破坏。
function c40418351.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，指定用「电子暗黑魔角」「电子暗黑刃翼」「电子暗黑龙骨」三只怪兽作为融合素材（允许使用融合素材代用品）。
	aux.AddFusionProcCode3(c,41230939,77625948,3019642,true,true)
	-- ①：这张卡特殊召唤成功的场合，以自己墓地1只龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40418351,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c40418351.eqtg)
	e1:SetOperation(c40418351.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值以及自己墓地的怪兽数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c40418351.atkval)
	c:RegisterEffect(e2)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件效果的判定函数为aux.fuslimit，即仅当召唤类型为融合召唤时才允许特殊召唤此卡。
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
end
-- 定义筛选可装备的龙族怪兽：要求是龙族且未被禁止作为装备卡使用。
function c40418351.filter(c)
	return c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 定义效果①发动时的取对象处理：若指定对象，则检查对象在墓地且属于自己或受『电子暗黑世界』影响可来自对方墓地；发动时若『电子暗黑世界』适用则选择范围扩展到对方墓地，否则仅限自己墓地；显示选择提示，选择1只符合条件的龙族怪兽作为对象，并登记其离开墓地的操作信息。
function c40418351.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检测【电子暗黑世界】(64753988)的效果是否生效中。若在生效中，「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and (chkc:IsControler(tp) or Duel.IsPlayerAffectedByEffect(tp,64753988)) and c40418351.filter(chkc) end
	if chk==0 then return true end
	-- 检测【电子暗黑世界】(64753988)的效果是否生效中。若在生效中，「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 向玩家显示选择要装备的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1张满足筛选条件的龙族怪兽（位置为墓地，具体范围由loc决定）作为此效果的对象。
	local g=Duel.SelectTarget(tp,c40418351.filter,tp,LOCATION_GRAVE,loc,1,1,nil)
	-- 登记操作信息：此效果处理时会令1张卡离开墓地，用于与『王家长眠之谷』等卡效果互动。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 定义效果①的解决处理：取得对象卡，确认其仍然相关且为龙族后，将其装备给此卡；若装备成功，再为该装备卡注册装备限制、攻击力上升及代替破坏三个效果。
function c40418351.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象卡（墓地的那只龙族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 尝试将对象怪兽作为装备卡装备给此卡；若装备失败则中止后续处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只龙族怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c40418351.eqlimit)
		tc:RegisterEffect(e1)
		-- 这张卡的效果装备的怪兽的攻击力数值
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		-- ③：这张卡被战斗破坏的场合，作为代替把装备的那只怪兽破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c40418351.repval)
		tc:RegisterEffect(e3)
	end
end
-- 定义装备限制条件：这张装备卡只能装备给其效果发动者（即铠黑龙）。
function c40418351.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 定义代替破坏的判定条件：仅当破坏原因为战斗破坏时适用。
function c40418351.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 定义攻击力上升值：返回持有者墓地的怪兽卡数量乘以100。
function c40418351.atkval(e,c)
	local tp=e:GetHandlerPlayer()
	-- 统计该玩家墓地的怪兽卡数量并乘以100，作为攻击力上升的数值。
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)*100
end
