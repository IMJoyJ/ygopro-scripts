--サイバー・ダーク・キール
-- 效果：
-- ①：这张卡召唤成功的场合，以自己墓地1只3星以下的龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：这张卡战斗破坏对方怪兽的场合发动。给与对方300伤害。
-- ④：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
function c3019642.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以自己墓地1只3星以下的龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3019642,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c3019642.eqtg)
	e1:SetOperation(c3019642.eqop)
	c:RegisterEffect(e1)
	-- ③：这张卡战斗破坏对方怪兽的场合发动。给与对方300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3019642,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置③效果的发动条件：必须是本卡与对方怪兽进行战斗并战斗破坏对方怪兽（aux.bdocon检测本卡与战斗相关且对象为对方怪兽）。
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c3019642.damtg)
	e2:SetOperation(c3019642.damop)
	c:RegisterEffect(e2)
end
-- 定义选择对象时的过滤条件：怪兽必须是3星以下、龙族且不允许使用禁止卡。
function c3019642.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 发动时的目标选择处理：若【电子暗黑世界】生效中，可从对方墓地选择符合条件的龙族怪兽；否则只能从自己墓地选择，同时校验对象合法性。
function c3019642.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检测【电子暗黑世界】(64753988)的效果是否生效中。若在生效中，「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and (chkc:IsControler(tp) or Duel.IsPlayerAffectedByEffect(tp,64753988)) and c3019642.filter(chkc) end
	if chk==0 then return true end
	-- 检测【电子暗黑世界】(64753988)的效果是否生效中。若在生效中，「电子暗黑」怪兽的召唤·特殊召唤成功时发动的自身的效果让自己从自己墓地把怪兽装备的场合，也能作为代替从对方墓地装备。
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 向发动玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己墓地（或【电子暗黑世界】生效时含对方墓地）选择1只3星以下龙族怪兽作为效果对象，并登记为取对象效果。
	local g=Duel.SelectTarget(tp,c3019642.filter,tp,LOCATION_GRAVE,loc,1,1,nil)
	-- 设置操作信息：将对象怪兽登记为“涉及墓地”的卡片处理，用于相关效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 装备效果的实际处理：将对象怪兽装备给本卡，若装备成功则为其注册“只能装备给本卡”“攻击力上升”和“代替破坏”三个效果。
function c3019642.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 调用Duel.Equip将对象怪兽作为装备卡装备给本卡，若装备失败（例如对象不能装备）则终止后续处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- ①：那只龙族怪兽当作装备卡使用给这张卡装备。（使该装备卡只能装备给电子暗黑龙骨）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c3019642.eqlimit)
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
		e3:SetValue(c3019642.repval)
		tc:RegisterEffect(e3)
	end
end
-- 装备限制条件：该装备卡只能装备给效果的所有者（即电子暗黑龙骨），防止转移到其他怪兽身上。
function c3019642.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 代替破坏的判定条件：仅当本卡被战斗破坏时，才允许用装备怪兽代替破坏（bit.band(r,REASON_BATTLE)~=0表示破坏原因为战斗）。
function c3019642.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 伤害效果的发动时处理：无额外条件，将对方玩家设为效果对象，伤害值设为300。
function c3019642.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方（1-tp），即这个连锁的伤害对象为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果参数（伤害数值）为300。
	Duel.SetTargetParam(300)
	-- 设置操作信息：本连锁将对对方玩家造成300点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 伤害处理函数：读取连锁信息中的对象玩家和伤害值，并执行伤害。
function c3019642.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出伤害对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对指定玩家造成伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
