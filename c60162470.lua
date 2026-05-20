--ゼロ・エクストラリンク
-- 效果：
-- 以额外怪兽区域的连接怪兽的所互相连接区1只自己的连接怪兽为对象才能把这张卡发动。
-- ①：作为对象的怪兽的攻击力上升场上的连接怪兽数量×800。
-- ②：作为对象的怪兽作为素材让连接怪兽连接召唤的场合发动。那只连接怪兽的攻击力直到回合结束时上升这张卡的①的效果上升过的数值。
-- ③：作为对象的怪兽攻击的伤害计算后发动。这张卡破坏。
function c60162470.initial_effect(c)
	-- 以额外怪兽区域的连接怪兽的所互相连接区1只自己的连接怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c60162470.target)
	e1:SetOperation(c60162470.tgop)
	c:RegisterEffect(e1)
	-- ①：作为对象的怪兽的攻击力上升场上的连接怪兽数量×800。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(c60162470.atkval1)
	c:RegisterEffect(e3)
	-- ②：作为对象的怪兽作为素材让连接怪兽连接召唤的场合发动。那只连接怪兽的攻击力直到回合结束时上升这张卡的①的效果上升过的数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(60162470,0))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(c60162470.atktg2)
	e4:SetOperation(c60162470.atkop2)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- 作为对象的怪兽作为素材让连接怪兽连接召唤的场合
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetRange(LOCATION_SZONE)
	e5:SetValue(c60162470.valcheck)
	c:RegisterEffect(e5)
	-- ③：作为对象的怪兽攻击的伤害计算后发动。这张卡破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(60162470,1))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_BATTLED)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c60162470.descon)
	e6:SetTarget(c60162470.destg)
	e6:SetOperation(c60162470.desop)
	c:RegisterEffect(e6)
end
-- 过滤额外怪兽区域的表侧表示连接怪兽
function c60162470.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:GetSequence()>4
end
-- 过滤属于指定卡片组且表侧表示的连接怪兽
function c60162470.filter(c,g)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and g:IsContains(c)
end
-- 发动时的效果处理，寻找并选择符合条件的对象怪兽
function c60162470.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Group.CreateGroup()
	-- 获取场上所有额外怪兽区域的表侧表示连接怪兽
	local lg=Duel.GetMatchingGroup(c60162470.lkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历这些额外怪兽区域的连接怪兽
	for tc in aux.Next(lg) do
		tg:Merge(tc:GetMutualLinkedGroup())
	end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c60162470.filter(chkc,tg) end
	-- 在发动阶段，检测是否存在可作为对象的自己场上的连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c60162470.filter,tp,LOCATION_MZONE,0,1,nil,tg) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只符合条件的自己场上的连接怪兽作为对象
	Duel.SelectTarget(tp,c60162470.filter,tp,LOCATION_MZONE,0,1,1,nil,tg)
end
-- 发动时的效果处理，将这张卡与作为对象的怪兽建立连接关系
function c60162470.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 过滤场上表侧表示的连接怪兽
function c60162470.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 计算并记录①效果所提升的攻击力数值
function c60162470.atkval1(e,c)
	-- 计算场上表侧表示的连接怪兽数量乘以800的数值
	local atk=Duel.GetMatchingGroupCount(c60162470.atkfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*800
	e:SetLabel(atk)
	return atk
end
-- 过滤作为这张卡的对象怪兽
function c60162470.matfilter(c,mc)
	return mc:IsHasCardTarget(c)
end
-- 检查连接召唤的素材中是否包含作为对象的怪兽，并给召唤出的怪兽添加标记
function c60162470.valcheck(e,c)
	if c:GetMaterial():IsExists(c60162470.matfilter,1,nil,e:GetHandler()) then
		c:RegisterFlagEffect(60162470,RESET_EVENT+0x4fe0000+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤由自己连接召唤且带有特定标记的怪兽
function c60162470.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(60162470)~=0
end
-- ②效果的发动检测，确认是否有符合条件的连接怪兽被连接召唤
function c60162470.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c60162470.cfilter,1,nil,tp) end
	-- 将召唤出的连接怪兽设为效果处理的对象
	Duel.SetTargetCard(eg)
end
-- ②效果的处理，使连接召唤的怪兽攻击力上升①效果上升过的数值
function c60162470.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=e:GetLabelObject():GetLabel()
		-- 那只连接怪兽的攻击力直到回合结束时上升这张卡的①的效果上升过的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件，检查进行攻击的怪兽是否为这张卡的对象怪兽
function c60162470.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前攻击的怪兽是否是这张卡的对象怪兽
	return e:GetHandler():IsHasCardTarget(Duel.GetAttacker())
end
-- ③效果的发动检测，设置破坏这张卡的操作信息
function c60162470.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- ③效果的处理，破坏这张卡
function c60162470.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果破坏这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
