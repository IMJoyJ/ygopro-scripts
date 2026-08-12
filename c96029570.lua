--漆黒の太陽
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上的表侧表示怪兽被战斗·效果破坏的场合才能发动。自己基本分回复那些怪兽的原本攻击力合计的数值。
-- ②：从自己墓地有怪兽表侧表示特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽的攻击力上升1000。
-- ③：魔法·陷阱卡从自己手卡丢弃去自己墓地的场合，以那之内的1张为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、①效果（破坏回复）、②效果（特召加攻并注册延迟特召事件）、③效果（丢弃魔陷回收并注册延迟丢弃事件）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽被战斗·效果破坏的场合才能发动。自己基本分回复那些怪兽的原本攻击力合计的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"基本分回复"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.reccon)
	e2:SetTarget(s.rectg)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	-- ②：从自己墓地有怪兽表侧表示特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.autg)
	e3:SetOperation(s.auop)
	c:RegisterEffect(e3)
	-- 注册一个合并延迟事件，用于将同一时点内从墓地特殊召唤的多只怪兽合并为单次自定义事件触发，防止重复发动。
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ③：魔法·陷阱卡从自己手卡丢弃去自己墓地的场合，以那之内的1张为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回收魔法·陷阱卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_CUSTOM+id+o)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+o*2)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	-- 注册一个合并延迟事件，用于将同一时点内从手卡丢弃的多张卡合并为单次自定义事件触发，防止重复发动。
	aux.RegisterMergedDelayedEvent(c,id+o,EVENT_DISCARD)
end
-- 过滤出因战斗或效果破坏、且原本由自己控制、从怪兽区送去墓地（或除外等）前是表侧表示的怪兽。
function s.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- ①效果的发动条件：检查被破坏的怪兽中是否存在满足条件的怪兽，并计算这些怪兽的原本攻击力合计，若大于0则可以发动。
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:Filter(s.cfilter,nil,tp)
	local atk=dg:GetSum(Card.GetTextAttack)
	e:SetLabel(atk)
	return atk>0
end
-- ①效果的靶向处理：设置回复基本分的对象玩家和回复数值，并向系统宣告该效果包含回复基本分的操作。
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为之前计算并保存的原本攻击力合计值。
	Duel.SetTargetParam(e:GetLabel())
	-- 设置当前连锁的操作信息，表明此效果会使自己回复等同于原本攻击力合计值的基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
-- ①效果的效果处理：获取目标玩家和回复数值，执行回复基本分的操作。
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和目标参数（回复数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应的基本分数值。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 过滤出从自己墓地表侧表示特殊召唤到怪兽区、且可以成为效果对象的怪兽。
function s.aufilter(c,tp,e)
	return c:IsFaceup() and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE)
		and c:IsLocation(LOCATION_MZONE) and (not e or c:IsCanBeEffectTarget(e))
end
-- ②效果的靶向处理：筛选出从自己墓地表侧表示特殊召唤的怪兽，若有多只则选择其中1只作为对象，并将其设为效果的目标卡片。
function s.autg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.aufilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local tg=g:Clone()
	if #g>1 then
		-- 向玩家发送提示信息，要求选择一只表侧表示的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		tg=g:Select(tp,1,1,nil)
	end
	-- 将选择的怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(tg)
end
-- ②效果的效果处理：使作为效果对象的怪兽攻击力上升1000。
function s.auop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联的第一个对象怪兽。
	local tc=Duel.GetTargetsRelateToChain():GetFirst()
	if tc and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤出从自己手卡被丢弃去自己墓地、且可以成为效果对象并能加入手牌的魔法·陷阱卡。
function s.thfilter(c,e,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_HAND) and c:IsReason(REASON_DISCARD)
		and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- ③效果的靶向处理：筛选出符合条件的魔法·陷阱卡，选择其中1张作为对象，并设置回收手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:FilterCount(s.thfilter,nil,e,tp)>0 end
	-- 向玩家发送提示信息，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local tg
	if #eg==1 then
		tg=eg:Clone()
	else
		-- 向玩家发送提示信息，要求选择效果的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tg=eg:FilterSelect(tp,s.thfilter,1,1,nil,e,tp)
	end
	-- 将选择的魔法·陷阱卡设置为当前连锁的效果对象。
	Duel.SetTargetCard(tg)
	-- 设置当前连锁的操作信息，表明此效果会将选中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,0,0)
end
-- ③效果的效果处理：将作为效果对象的魔法·陷阱卡加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡片送回持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
