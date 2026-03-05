--烙印の命数
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己用魔法卡的效果只把仪式怪兽1只特殊召唤的场合才能发动。把自己或者对方的额外卡组确认，那之内的1只怪兽送去墓地。
-- ②：自己用魔法卡的效果只把融合怪兽1只特殊召唤的场合，以那1只怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升自身的原本攻击力数值，只能向对方场上的攻击表示怪兽攻击。
function c14220547.initial_effect(c)
	-- ①：自己用魔法卡的效果只把仪式怪兽1只特殊召唤的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 把自己或者对方的额外卡组确认，那之内的1只怪兽送去墓地。
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
	-- ②：自己用魔法卡的效果只把融合怪兽1只特殊召唤的场合，以那1只怪兽为对象才能发动。
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
-- 检索满足条件的仪式怪兽
function c14220547.tcfilter(c,tp,re,rp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_SPELL~=0 and rp==tp
end
-- 判断是否满足①效果的发动条件
function c14220547.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:FilterCount(c14220547.tcfilter,nil,tp,re,rp)==1
end
-- 设置①效果的处理目标
function c14220547.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果的发动条件
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,LOCATION_EXTRA)>0 end
	-- 设置①效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
-- ①效果的处理函数
function c14220547.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己的额外卡组中的所有卡
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	-- 获取对方的额外卡组中的所有卡
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if (#g1~=0 or #g2~=0) then
		local g=nil
		-- 选择确认自己的额外卡组还是对方的额外卡组
		if #g1~=0 and (#g2==0 or Duel.SelectOption(tp,aux.Stringid(14220547,1),aux.Stringid(14220547,2))==0) then  --"确认自己的额外卡组"
			g=g1
		else
			g=g2
			-- 确认对方额外卡组中的卡
			Duel.ConfirmCards(tp,g,true)
		end
		-- 提示选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=g:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
		-- 如果确认的是对方额外卡组，则洗切对方额外卡组
		if g==g2 then Duel.ShuffleExtra(1-tp) end
	end
end
-- 检索满足条件的融合怪兽
function c14220547.acfilter(c,tp,re,rp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_SPELL~=0 and rp==tp
end
-- 判断是否满足②效果的发动条件
function c14220547.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:FilterCount(c14220547.acfilter,nil,tp,re,rp)==1
end
-- 用于筛选目标怪兽的过滤器
function c14220547.tgfilter(c,eg)
	return eg:IsContains(c)
end
-- 设置②效果的处理目标
function c14220547.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足②效果的发动条件
	if chk==0 then return Duel.IsExistingTarget(c14220547.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,eg) end
	-- 设置②效果的目标卡
	Duel.SetTargetCard(eg)
end
-- ②效果的处理函数
function c14220547.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽攻击力上升其原本攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetBaseAttack())
		tc:RegisterEffect(e1)
		-- 使目标怪兽只能攻击对方场上的攻击表示怪兽
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(c14220547.atlimit)
		tc:RegisterEffect(e2)
		-- 使目标怪兽不能直接攻击
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 限制目标怪兽不能被选择为攻击目标
function c14220547.atlimit(e,c)
	return not c:IsAttackPos() or c:IsControler(e:GetHandlerPlayer())
end
