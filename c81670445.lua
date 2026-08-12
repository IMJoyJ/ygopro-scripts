--クロノダイバー・ハック
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的超量怪兽在特殊召唤的回合不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：以自己场上1只超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那些超量素材数量×300。并且那只怪兽有原本持有者是对方的卡在作为超量素材的场合，更在这个回合让那只怪兽可以直接攻击。
function c81670445.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的超量怪兽在特殊召唤的回合不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c81670445.xyztarget)
	e2:SetValue(c81670445.indesval)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的超量怪兽在特殊召唤的回合不会成为对方的效果的对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c81670445.xyztarget)
	-- 设置不能成为对方卡的效果的对象（使用系统内置的过滤函数aux.tgoval判定是否为对方的效果）
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：以自己场上1只超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那些超量素材数量×300。并且那只怪兽有原本持有者是对方的卡在作为超量素材的场合，更在这个回合让那只怪兽可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(81670445,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,81670445)
	e4:SetTarget(c81670445.atktg)
	e4:SetOperation(c81670445.atkop)
	c:RegisterEffect(e4)
end
-- 判定效果来源是否为对方玩家（用于不会被对方的效果破坏的判定）
function c81670445.indesval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
-- 过滤出自己场上在特殊召唤的回合的超量怪兽
function c81670445.xyztarget(e,c)
	return c:IsType(TYPE_XYZ) and c:IsStatus(STATUS_SPSUMMON_TURN)
end
-- 过滤出自己场上表侧表示且拥有超量素材的超量怪兽
function c81670445.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
-- 效果②的对象选择阶段，确认场上是否存在符合条件的超量怪兽并将其设为效果对象
function c81670445.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c81670445.filter(chkc) end
	-- 判定自己场上是否存在至少1只表侧表示且拥有超量素材的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c81670445.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示且拥有超量素材的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c81670445.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤出原本持有者是对方的卡
function c81670445.matfil(c,e)
	return c:GetOwner()~=e:GetHandlerPlayer()
end
-- 效果②的执行阶段，使目标怪兽攻击力上升其超量素材数量×300，若其拥有原本持有者为对方的超量素材，则该怪兽本回合可以直接攻击
function c81670445.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升那些超量素材数量×300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetOverlayCount()*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if tc:GetOverlayGroup():IsExists(c81670445.matfil,1,nil,e) then
			-- 并且那只怪兽有原本持有者是对方的卡在作为超量素材的场合，更在这个回合让那只怪兽可以直接攻击。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DIRECT_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
