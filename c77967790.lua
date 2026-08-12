--ダイナレスラー・キング・Tレッスル
-- 效果：
-- 「恐龙摔跤手」怪兽2只以上
-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
-- ③：对方战斗阶段开始时，以对方场上1只攻击表示怪兽为对象才能发动。这次战斗阶段中，对方若不用那只怪兽攻击宣言，则不能用其他怪兽攻击宣言。没有攻击宣言的场合，作为对象的怪兽在那次战斗阶段结束时破坏。
function c77967790.initial_effect(c)
	-- 设置连接召唤手续，需要「恐龙摔跤手」怪兽2只以上。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x11a),2)
	c:EnableReviveLimit()
	-- ①：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c77967790.actlimit)
	e1:SetCondition(c77967790.actcon)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c77967790.atklimit)
	c:RegisterEffect(e2)
	-- ③：对方战斗阶段开始时，以对方场上1只攻击表示怪兽为对象才能发动。这次战斗阶段中，对方若不用那只怪兽攻击宣言，则不能用其他怪兽攻击宣言。没有攻击宣言的场合，作为对象的怪兽在那次战斗阶段结束时破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77967790,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c77967790.atkcon)
	e3:SetTarget(c77967790.atktg)
	e3:SetOperation(c77967790.atkop)
	c:RegisterEffect(e3)
end
-- 限制发动的卡片类型为魔法·陷阱卡。
function c77967790.actlimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判定这张卡是否正在进行战斗。
function c77967790.actcon(e)
	-- 返回自身是攻击怪兽或被攻击怪兽的判定结果。
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 限制对方不能选择这张卡以外的怪兽作为攻击对象。
function c77967790.atklimit(e,c)
	return c~=e:GetHandler()
end
-- 判定当前回合是否为对方回合。
function c77967790.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家不是自身控制者的判定结果。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果③的靶向/对象选择处理，选择对方场上1只攻击表示怪兽为对象。
function c77967790.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAttackPos() end
	-- 判定对方场上是否存在可以作为对象的攻击表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择攻击表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)  --"请选择攻击表示的怪兽"
	-- 选择对方场上1只攻击表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsAttackPos,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果③的运行处理，注册攻击限制效果以及战斗阶段结束时的破坏效果。
function c77967790.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local fid=c:GetFieldID()
		-- 给玩家注册一个持续到战斗阶段结束的标识，用于后续逻辑判定。
		Duel.RegisterFlagEffect(tp,77967790,RESET_PHASE+PHASE_BATTLE,0,1)
		tc:RegisterFlagEffect(77967790,RESET_PHASE+PHASE_BATTLE+RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这次战斗阶段中，对方若不用那只怪兽攻击宣言，则不能用其他怪兽攻击宣言。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c77967790.atkcon2)
		e1:SetTarget(c77967790.atktg2)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		-- 将不能攻击的限制效果注册给对方玩家。
		Duel.RegisterEffect(e1,tp)
		-- 这次战斗阶段中，对方若不用那只怪兽攻击宣言，则不能用其他怪兽攻击宣言。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_ATTACK_ANNOUNCE)
		e3:SetOperation(c77967790.atkop2)
		e3:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
		-- 没有攻击宣言的场合，作为对象的怪兽在那次战斗阶段结束时破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(77967790,1))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(tc)
		e2:SetCondition(c77967790.descon)
		e2:SetOperation(c77967790.desop)
		e2:SetReset(RESET_PHASE+PHASE_BATTLE)
		-- 将战斗阶段结束时破坏对象的延迟效果注册给玩家。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判定作为对象的怪兽在此前是否尚未进行过攻击宣言。
function c77967790.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffect(77967791)==0
end
-- 限制不能攻击的对象为目标怪兽以外的其他怪兽。
function c77967790.atktg2(e,c)
	local tc=e:GetLabelObject()
	return c~=tc or c:GetFlagEffectLabel(77967790)~=e:GetLabel()
end
-- 在目标怪兽进行攻击宣言时，为其注册已攻击的标识。
function c77967790.atkop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(77967791,RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 判定目标怪兽在战斗阶段结束时是否未进行过攻击宣言。
function c77967790.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(77967790)==e:GetLabel() and tc:GetAttackAnnouncedCount()==0
end
-- 破坏作为对象的怪兽。
function c77967790.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 提示发动效果的卡片为「恐龙摔跤手·摔跤暴龙王」。
	Duel.Hint(HINT_CARD,0,77967790)
	-- 因效果将作为对象的怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
