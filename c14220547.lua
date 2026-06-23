--烙印の命数
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己用魔法卡的效果只把仪式怪兽1只特殊召唤的场合才能发动。把自己或者对方的额外卡组确认，那之内的1只怪兽送去墓地。
-- ②：自己用魔法卡的效果只把融合怪兽1只特殊召唤的场合，以那1只怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升自身的原本攻击力数值，只能向对方场上的攻击表示怪兽攻击。
function c14220547.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己用魔法卡的效果只把仪式怪兽1只特殊召唤的场合才能发动。把自己或者对方的额外卡组确认，那之内的1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14220547,0))  --"额外卡组送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,14220547)
	e2:SetCondition(c14220547.tgcon)
	e2:SetTarget(c14220547.tgtg)
	e2:SetOperation(c14220547.tgop)
	c:RegisterEffect(e2)
	-- ②：自己用魔法卡的效果只把融合怪兽1只特殊召唤的场合，以那1只怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升自身的原本攻击力数值，只能向对方场上的攻击表示怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,14220548)
	e3:SetCondition(c14220547.atkcon)
	e3:SetTarget(c14220547.atktg)
	e3:SetOperation(c14220547.atkop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的仪式怪兽，即该怪兽是仪式怪兽且是由魔法卡特殊召唤的。
function c14220547.tcfilter(c,tp,re,rp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_SPELL~=0 and rp==tp
end
-- 判断是否只特殊召唤了1只仪式怪兽，且该怪兽是由魔法卡特殊召唤的。
function c14220547.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:FilterCount(c14220547.tcfilter,nil,tp,re,rp)==1
end
-- 设置效果目标为对方额外卡组中的任意1只怪兽。
function c14220547.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否对方额外卡组中存在怪兽。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,LOCATION_EXTRA)>0 end
	-- 设置连锁操作信息，表示将从对方额外卡组中选择1只怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
-- 处理效果，选择对方额外卡组中的1只怪兽送去墓地。
function c14220547.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方额外卡组中的所有怪兽。
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	-- 获取对方额外卡组中的所有怪兽。
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if (#g1~=0 or #g2~=0) then
		local g=nil
		-- 如果己方额外卡组不为空，且对方额外卡组为空或玩家选择确认己方额外卡组，则选择己方额外卡组。
		if #g1~=0 and (#g2==0 or Duel.SelectOption(tp,aux.Stringid(14220547,1),aux.Stringid(14220547,2))==0) then  --"确认自己的额外卡组" / "确认对方的额外卡组"
			g=g1
		else
			g=g2
			-- 确认对方额外卡组中的怪兽。
			Duel.ConfirmCards(tp,g,true)
		end
		-- 提示玩家选择要送去墓地的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=g:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
		-- 将选择的怪兽送去墓地。
		Duel.SendtoGrave(tg,REASON_EFFECT)
		-- 如果选择了对方额外卡组，则洗切对方额外卡组。
		if g==g2 then Duel.ShuffleExtra(1-tp) end
	end
end
-- 过滤满足条件的融合怪兽，即该怪兽是融合怪兽且是由魔法卡特殊召唤的。
function c14220547.acfilter(c,tp,re,rp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_SPELL~=0 and rp==tp
end
-- 判断是否只特殊召唤了1只融合怪兽，且该怪兽是由魔法卡特殊召唤的。
function c14220547.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:FilterCount(c14220547.acfilter,nil,tp,re,rp)==1
end
-- 判断目标怪兽是否为特殊召唤的怪兽。
function c14220547.tgfilter(c,eg)
	return eg:IsContains(c)
end
-- 设置效果目标为特殊召唤的怪兽。
function c14220547.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否存在特殊召唤的怪兽作为目标。
	if chk==0 then return Duel.IsExistingTarget(c14220547.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,eg) end
	-- 设置当前效果的目标为特殊召唤的怪兽。
	Duel.SetTargetCard(eg)
end
-- 处理效果，使目标怪兽攻击力提升并只能攻击对方场上的攻击表示怪兽。
function c14220547.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力提升其原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetBaseAttack())
		tc:RegisterEffect(e1)
		-- 使目标怪兽只能攻击对方场上的攻击表示怪兽。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(c14220547.atlimit)
		tc:RegisterEffect(e2)
		-- 使目标怪兽不能直接攻击。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 判断目标怪兽是否为攻击表示或是否为效果持有者控制。
function c14220547.atlimit(e,c)
	return not c:IsAttackPos() or c:IsControler(e:GetHandlerPlayer())
end
