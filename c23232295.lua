--BK 拘束蛮兵リードブロー
-- 效果：
-- 4星「燃烧拳击手」怪兽×2
-- ①：自己场上的「燃烧拳击手」怪兽被战斗·效果破坏的场合，可以作为那些「燃烧拳击手」怪兽之内的1只的代替而把这张卡1个超量素材取除。
-- ②：这张卡的超量素材被取除的场合发动。这张卡的攻击力上升800。
function c23232295.initial_effect(c)
	-- 设置全局标记，用于监听超量素材被移除的事件
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 为卡片添加XYZ召唤手续，需要2只4星的「燃烧拳击手」怪兽作为素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1084),4,2)
	c:EnableReviveLimit()
	-- ①：自己场上的「燃烧拳击手」怪兽被战斗·效果破坏的场合，可以作为那些「燃烧拳击手」怪兽之内的1只的代替而把这张卡1个超量素材取除。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c23232295.reptg)
	e1:SetValue(c23232295.repval)
	c:RegisterEffect(e1)
	-- ②：这张卡的超量素材被取除的场合发动。这张卡的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23232295,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_DETACH_MATERIAL)
	e2:SetTarget(c23232295.atktg)
	e2:SetOperation(c23232295.atkop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「燃烧拳击手」怪兽，用于判断是否可以代替破坏
function c23232295.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x1084)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 处理代替破坏的效果，检查是否可以移除1个超量素材并选择代替破坏的怪兽
function c23232295.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c23232295.repfilter,1,nil,tp) end
	-- 检查是否可以移除1个超量素材并询问玩家是否发动效果
	if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		local g=eg:Filter(c23232295.repfilter,nil,tp)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			-- 提示玩家选择要代替破坏的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		return true
	else return false end
end
-- 设置代替破坏的判断条件，返回是否为被选择代替破坏的怪兽
function c23232295.repval(e,c)
	return c==e:GetLabelObject()
end
-- 设置攻击力上升效果的目标判定
function c23232295.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
end
-- 发动攻击力上升效果，使该卡攻击力上升800
function c23232295.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使该卡的攻击力上升800
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(800)
		c:RegisterEffect(e1)
	end
end
