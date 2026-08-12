--ムーンバリア
-- 效果：
-- ①：怪兽的攻击无效时，可以从以下效果选择1个发动。
-- ●变成这个回合的结束阶段。
-- ●以自己场上1只「希望皇 霍普」超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的2倍。
-- ②：自己场上的「希望皇 霍普」超量怪兽把超量素材1个取除来让效果发动的场合，可以作为取除的超量素材的代替而把墓地的这张卡除外。
function c83880087.initial_effect(c)
	-- ①：怪兽的攻击无效时，可以从以下效果选择1个发动。●变成这个回合的结束阶段。●以自己场上1只「希望皇 霍普」超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_DISABLED)
	e1:SetTarget(c83880087.target)
	e1:SetOperation(c83880087.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上的「希望皇 霍普」超量怪兽把超量素材1个取除来让效果发动的场合，可以作为取除的超量素材的代替而把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83880087,2))  --"使用「弯月罩」的效果代替取除素材"
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c83880087.rcon)
	e2:SetOperation(c83880087.rop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「希望皇 霍普」超量怪兽
function c83880087.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x107f)
end
-- ①号效果的发动准备与分支选择判定
function c83880087.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c83880087.filter(chkc) end
	if chk==0 then return true end
	local op=0
	-- 检查自己场上是否存在可以作为对象的「希望皇 霍普」超量怪兽
	if Duel.IsExistingTarget(c83880087.filter,tp,LOCATION_MZONE,0,1,nil) then
		-- 让玩家从“变成这个回合的结束阶段”和“攻击力变成2倍”中选择一个效果发动
		op=Duel.SelectOption(tp,aux.Stringid(83880087,0),aux.Stringid(83880087,1))  --"变成这个回合的结束阶段/攻击力变成2倍"
	else
		-- 场上没有合法的「希望皇 霍普」超量怪兽时，玩家只能选择“变成这个回合的结束阶段”
		op=Duel.SelectOption(tp,aux.Stringid(83880087,0))  --"变成这个回合的结束阶段"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(0)
		e:SetProperty(0)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择自己场上1只表侧表示的「希望皇 霍普」超量怪兽作为效果的对象
		Duel.SelectTarget(tp,c83880087.filter,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
-- ①号效果的执行分支判定，根据玩家在发动时选择的分支来执行对应的子函数
function c83880087.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		c83880087.endop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		c83880087.atkop(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 执行“变成这个回合的结束阶段”的分支效果，跳过当前回合玩家的各个阶段，并限制其本回合不能再进入战斗阶段
function c83880087.endop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的回合玩家
	local turnp=Duel.GetTurnPlayer()
	-- 跳过当前回合玩家的主要阶段1
	Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
	-- 跳过当前回合玩家的战斗阶段
	Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
	-- 跳过当前回合玩家的主要阶段2
	Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
	-- 那只怪兽的攻击力直到回合结束时变成原本攻击力的2倍。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该限制效果，使当前回合玩家本回合不能再进入战斗阶段
	Duel.RegisterEffect(e1,turnp)
end
-- 执行“攻击力变成2倍”的分支效果，使作为对象的怪兽的攻击力直到回合结束时变成原本攻击力的2倍
function c83880087.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 代替去除素材效果的允许条件判定：必须是作为发动效果的Cost要去除1个超量素材，且该效果是由自己场上的「希望皇 霍普」超量怪兽发动的，同时墓地的这张卡可以被除外
function c83880087.rcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_COST)~=0 and re:IsActivated()
		and re:IsActiveType(TYPE_XYZ) and re:GetHandler():IsSetCard(0x107f)
		and e:GetHandler():IsAbleToRemoveAsCost()
		and ep==e:GetOwnerPlayer() and ev==1
end
-- 代替去除素材效果的执行：将墓地的这张卡除外作为代替
function c83880087.rop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外，作为去除超量素材的代替Cost
	return Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
