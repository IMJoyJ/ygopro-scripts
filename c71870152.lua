--フォーチュンレディ・ファイリー
-- 效果：
-- 这张卡的攻击力·守备力变成这张卡的等级×200的数值。自己的准备阶段时，这张卡的等级上升1星（等级最多12星）。这张卡用名字带有「命运女郎」的卡的效果表侧攻击表示特殊召唤成功时，把对方场上表侧表示存在的1只怪兽破坏，给与对方基本分破坏怪兽的攻击力数值的伤害。
function c71870152.initial_effect(c)
	-- 这张卡的攻击力·守备力变成这张卡的等级×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(c71870152.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	-- 自己的准备阶段时，这张卡的等级上升1星（等级最多12星）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71870152,0))  --"等级上升"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(c71870152.lvcon)
	e3:SetOperation(c71870152.lvop)
	c:RegisterEffect(e3)
	-- 这张卡用名字带有「命运女郎」的卡的效果表侧攻击表示特殊召唤成功时，把对方场上表侧表示存在的1只怪兽破坏，给与对方基本分破坏怪兽的攻击力数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(71870152,1))  --"破坏并伤害"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c71870152.descon)
	e4:SetTarget(c71870152.destg)
	e4:SetOperation(c71870152.desop)
	c:RegisterEffect(e4)
end
-- 计算并返回这张卡的等级×200的数值，用于确定攻击力和守备力
function c71870152.value(e,c)
	return c:GetLevel()*200
end
-- 判断当前回合玩家是否为自己，作为准备阶段等级上升效果的发动条件
function c71870152.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否是自己
	return Duel.GetTurnPlayer()==tp
end
-- 执行等级上升效果，若自身表侧表示存在且等级小于12，则等级上升1星
function c71870152.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	-- 这张卡的等级上升1星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 判断此卡是否表侧攻击表示，且是由名字带有「命运女郎」的卡的效果特殊召唤成功，作为效果发动的条件
function c71870152.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsAttackPos() and c:IsSpecialSummonSetCard(0x31)
end
-- 过滤出场上表侧表示的卡片
function c71870152.filter(c)
	return c:IsFaceup()
end
-- 破坏并伤害效果的靶向与合法性检测，选择对方场上表侧表示的1只怪兽作为对象，并设置破坏与伤害的操作信息
function c71870152.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c71870152.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上表侧表示的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c71870152.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置当前连锁的操作信息为给与对方玩家伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 执行破坏并伤害效果，破坏选中的对象怪兽，并给与对方该怪兽攻击力数值的伤害
function c71870152.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local atk=tc:GetAttack()
	-- 若对象怪兽仍表侧表示存在且与效果相关，则将其因效果破坏，并判断是否破坏成功
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给与对方玩家被破坏怪兽攻击力数值的伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
