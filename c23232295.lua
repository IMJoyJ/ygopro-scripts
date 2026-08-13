--BK 拘束蛮兵リードブロー
-- 效果：
-- 4星「燃烧拳击手」怪兽×2
-- ①：自己场上的「燃烧拳击手」怪兽被战斗·效果破坏的场合，可以作为那些「燃烧拳击手」怪兽之内的1只的代替而把这张卡1个超量素材取除。
-- ②：这张卡的超量素材被取除的场合发动。这张卡的攻击力上升800。
function c23232295.initial_effect(c)
	-- 启用全局标记GLOBALFLAG_DETACH_EVENT，使游戏能监测超量素材被取除的事件（EVENT_DETACH_MATERIAL），供②效果触发。
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 为这张卡添加XYZ召唤手续：需要2只等级4的「燃烧拳击手」怪兽作为超量素材叠放。
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
-- 过滤函数：判断被破坏的怪兽是否满足代替破坏条件——须为表侧表示、我方场上、位于主要怪兽区、属于「燃烧拳击手」字段、被战斗或效果破坏，且不是因代替效果导致的破坏。
function c23232295.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x1084)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的发动/适用处理：检查是否存在满足条件的被破坏怪兽；若这张卡可以取除1个超量素材且玩家选择发动，则实际取除1个素材，筛选出可代替的怪兽；若只有1只则直接指定，否则让玩家选择其中1只，并将选中的怪兽记录到LabelObject，返回true表示本次破坏由这张卡代替。
function c23232295.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c23232295.repfilter,1,nil,tp) end
	-- 检查这张卡能否以效果原因取除1个超量素材，并让玩家确认是否发动代替破坏效果。
	if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		local g=eg:Filter(c23232295.repfilter,nil,tp)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			-- 当有多个可代替破坏的「燃烧拳击手」怪兽时，提示玩家选择要代替破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		return true
	else return false end
end
-- 判定实际要被破坏的怪兽是否就是之前记录的LabelObject，是则返回true，使该怪兽的破坏由这张卡代替。
function c23232295.repval(e,c)
	return c==e:GetLabelObject()
end
-- 触发效果的发动条件：这张卡仍与效果相关（未离场或效果未被重置），满足则允许发动。
function c23232295.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
end
-- 攻击力上升效果的处理：若这张卡仍在场上且表侧表示，则给它注册一个攻击力上升800的永续效果。
function c23232295.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- ②：这张卡的攻击力上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(800)
		c:RegisterEffect(e1)
	end
end
