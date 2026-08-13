--サイバー・ダーク・ホーン
-- 效果：
-- ①：这张卡召唤成功的场合，以自己墓地1只3星以下的龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ④：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
function c41230939.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以自己墓地1只3星以下的龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41230939,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c41230939.eqtg)
	e1:SetOperation(c41230939.eqop)
	c:RegisterEffect(e1)
	-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 定义可选对象的条件：3星以下、龙族、且不是禁止卡；用于筛选墓地中满足条件的怪兽。
function c41230939.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 发动时选择自己墓地（若「电子暗黑世界」效果适用中则也可选择对方墓地）1只3星以下龙族且非禁止的怪兽为对象；同时设置操作信息为涉及从墓地离开的效果。
function c41230939.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检测【电子暗黑世界】(64753988)的效果是否生效中。若在生效中，「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and (chkc:IsControler(tp) or Duel.IsPlayerAffectedByEffect(tp,64753988)) and c41230939.filter(chkc) end
	if chk==0 then return true end
	-- 检测【电子暗黑世界】(64753988)的效果是否生效中。若在生效中，「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 向操作玩家显示选择提示消息（请选择要装备的卡），并缓存用于卡片选择界面的提示文案。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己墓地（若电子暗黑世界效果适用中则也可从对方墓地）选择1只符合条件的龙族怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c41230939.filter,tp,LOCATION_GRAVE,loc,1,1,nil)
	-- 设置操作信息：将选择的对象登记为“离开墓地”的相关操作（CATEGORY_LEAVE_GRAVE），以便其他卡片（如王家长眠之谷）进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：取得对象并确认仍适用后，取其攻击力（若为?则按0），将其装备给电子暗黑魔角；随后给该装备卡注册效果：只能装备给这张卡、使这张卡攻击力上升该怪兽攻击力数值、这张卡被战斗破坏时由该怪兽代替破坏。
function c41230939.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中该效果选择的对象卡（那只墓地龙族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 将对象龙族怪兽作为装备卡装备给电子暗黑魔角；若装备失败（如没有可用魔法陷阱区或受特殊规则限制）则终止效果处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- ①：那只龙族怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c41230939.eqlimit)
		tc:RegisterEffect(e1)
		-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		-- ④：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c41230939.repval)
		tc:RegisterEffect(e3)
	end
end
-- 装备限制判定：仅允许该装备卡装备给效果的所有者（即电子暗黑魔角），防止装备到其他怪兽上。
function c41230939.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 代替破坏判定：当破坏原因为战斗破坏（REASON_BATTLE）时返回 true，使装备怪兽代替电子暗黑魔角被破坏。
function c41230939.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
