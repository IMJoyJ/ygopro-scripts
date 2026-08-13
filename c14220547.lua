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
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己用魔法卡的效果只把仪式怪兽1只特殊召唤的场合才能发动。把自己或者对方的额外卡组确认，那之内的1只怪兽送去墓地。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己用魔法卡的效果只把融合怪兽1只特殊召唤的场合，以那1只怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升自身的原本攻击力数值，只能向对方场上的攻击表示怪兽攻击。
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
-- ①效果的诱发条件过滤器：候选怪兽必须是表侧表示、仪式怪兽，其特殊召唤信息含TYPE_SPELL（即由魔法卡的效果特殊召唤），且效果发动玩家为本方tp（rp==tp）。
function c14220547.tcfilter(c,tp,re,rp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_SPELL~=0 and rp==tp
end
-- ①效果的发动条件：这次成功特殊召唤的怪兽只有1只，且这1只怪兽满足tcfilter，即符合“自己用魔法卡的效果只把仪式怪兽1只特殊召唤”的场合。
function c14220547.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:FilterCount(c14220547.tcfilter,nil,tp,re,rp)==1
end
-- ①效果的目标处理：先确认双方额外卡组总数大于0才可发动；随后登记本次处理会把1张额外卡组的卡送去墓地。
function c14220547.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：双方额外卡组中的卡合计数量大于0，否则不能发动①效果。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,LOCATION_EXTRA)>0 end
	-- 登记效果操作信息：不取对象，预计将来自任意一方额外卡组的1张卡送去墓地，以便后续连锁判定/发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
-- ①效果处理：分别取得自己和对方额外卡组；只要有一方有卡，就让发动者选择处理自己还是对方额外卡组；若选对方则先展示对方额外卡组；再从所选额外卡组选1张卡，以效果原因送去墓地；若选的是对方额外卡组，最后洗切对方额外卡组。
function c14220547.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己的额外卡组全部卡片，作为可能被确认并送墓的候选组。
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	-- 取得对方的额外卡组全部卡片，作为可能被确认并送墓的候选组。
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if (#g1~=0 or #g2~=0) then
		local g=nil
		-- 选择额外卡组：若自己额外卡组有卡，且（对方额外卡组无卡或玩家选择了“自己的额外卡组”），则处理自己额外卡组；否则选择并处理对方额外卡组。
		if #g1~=0 and (#g2==0 or Duel.SelectOption(tp,aux.Stringid(14220547,1),aux.Stringid(14220547,2))==0) then  --"确认自己的额外卡组/确认对方的额外卡组"
			g=g1
		else
			g=g2
			-- 把对方的额外卡组公开给本方玩家确认。
			Duel.ConfirmCards(tp,g,true)
		end
		-- 弹出“请选择要送去墓地的卡”的选择提示，用于后续选卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local tg=g:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
		-- 将选中的卡以『效果』的原因送去墓地。
		Duel.SendtoGrave(tg,REASON_EFFECT)
		-- 若刚才处理的是对方额外卡组，则选卡送墓后洗切对方额外卡组，防止顺序被公开。
		if g==g2 then Duel.ShuffleExtra(1-tp) end
	end
end
-- ②效果的诱发条件过滤器：候选怪兽必须是表侧表示、融合怪兽，其特殊召唤信息含TYPE_SPELL（即由魔法卡的效果特殊召唤），且效果发动玩家为本方tp（rp==tp）。
function c14220547.acfilter(c,tp,re,rp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_SPELL~=0 and rp==tp
end
-- ②效果的发动条件：这次特殊召唤的怪兽只有1只，且这1只怪兽满足acfilter，即符合“自己用魔法卡的效果只把融合怪兽1只特殊召唤”的场合。
function c14220547.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:FilterCount(c14220547.acfilter,nil,tp,re,rp)==1
end
-- 对象选择过滤函数：候选卡必须是本次特殊召唤成功的那只融合怪兽（在eg组内）。
function c14220547.tgfilter(c,eg)
	return eg:IsContains(c)
end
-- ②效果的取对象处理：发动时若场上存在可成为对象的、刚刚特殊召唤成功的那只融合怪兽，则通过Duel.SetTargetCard将其设为当前连锁的对象；chkc时直接不通过，避免二段选择。
function c14220547.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检测：在自己的主要怪兽区或对方的怪兽区存在刚刚特殊召唤成功的那只融合怪兽，可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c14220547.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,eg) end
	-- 将刚刚特殊召唤成功的那只融合怪兽（eg）登记为当前连锁的对象。
	Duel.SetTargetCard(eg)
end
-- ②效果处理：若对象怪兽仍在场上、表侧表示且与本效果仍关联，则给它适用三个直至回合结束的效果：攻击力上升其原本攻击力、只能选择对方攻击表示怪兽作为攻击对象、不能直接攻击。
function c14220547.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从当前连锁取得对象怪兽，即刚特殊召唤成功的那只融合怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽直到回合结束时攻击力上升自身的原本攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetBaseAttack())
		tc:RegisterEffect(e1)
		-- 只能向对方场上的攻击表示怪兽攻击
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(c14220547.atlimit)
		tc:RegisterEffect(e2)
		-- 只能向对方场上的攻击表示怪兽攻击
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 攻击对象限制判定：若候选攻击对象不是攻击表示，或与效果拥有者为同一控制者，则不能选择为攻击对象；由此实现“只能向对方场上的攻击表示怪兽攻击”。
function c14220547.atlimit(e,c)
	return not c:IsAttackPos() or c:IsControler(e:GetHandlerPlayer())
end
