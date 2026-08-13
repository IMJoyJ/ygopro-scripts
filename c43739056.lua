--天孔邪鬼
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己不能把这张卡以外的和这张卡相同属性的特殊召唤的怪兽的效果发动。
-- ②：1回合1次，自己·对方的主要阶段才能发动。这张卡的控制权移给对方。那之后，可以把这张卡的属性直到下个回合的结束时变更为任意属性。这个效果不在这张卡的原本持有者的回合不能发动。
function c43739056.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己不能把这张卡以外的和这张卡相同属性的特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c43739056.actlimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己·对方的主要阶段才能发动。这张卡的控制权移给对方。那之后，可以把这张卡的属性直到下个回合的结束时变更为任意属性。这个效果不在这张卡的原本持有者的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43739056,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c43739056.ctcon)
	e2:SetTarget(c43739056.cttg)
	e2:SetOperation(c43739056.ctop)
	c:RegisterEffect(e2)
end
-- 作为效果①的判定函数：检查被发动的效果是否为特殊召唤的怪兽在怪兽区域发动的怪兽效果，且该怪兽属性与此卡相同、不是此卡自身，且发动玩家为此卡控制者；满足时禁止发动该效果。
function c43739056.actlimit(e,re,tp)
	local rc=re:GetHandler()
	local c=e:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and re:GetActivateLocation()==LOCATION_MZONE
		and rc:IsAttribute(c:GetAttribute()) and rc~=c and tp==c:GetControler()
end
-- 效果②的发动条件：当前回合玩家必须为此卡的原本持有者（owner），且当前阶段必须是主要阶段1或主要阶段2。
function c43739056.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	-- 判断当前回合玩家是否为此卡的原本持有者，并且当前阶段为主要阶段1或主要阶段2。
	return p==Duel.GetTurnPlayer() and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果②发动时的目标处理：在发动时检查此卡的控制权是否可以变更，并设置连锁的操作信息为改变控制权。
function c43739056.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsControlerCanBeChanged() end
	-- 设置操作信息：将本次连锁处理标记为‘改变控制权’（CATEGORY_CONTROL），对象为此卡，数量为1，以便其他卡/效果可以对此进行响应和检测。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 效果②的实际处理：若此卡仍与效果关联且成功将控制权转移给对方，则询问原控制者是否变更属性；若同意，则中断当前效果，让玩家宣言一个属性，并为这张卡附加持续到下个回合结束的属性变更效果。
function c43739056.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡仍与本效果关联、控制权已经成功转移给对方，并询问此卡原控制者是否变更属性；只有这些条件都满足时才执行后续属性变更操作。
	if c:IsRelateToEffect(e) and Duel.GetControl(c,1-tp)>0 and Duel.SelectYesNo(tp,aux.Stringid(43739056,0)) then  --"是否改变属性？"
		-- 中断当前效果处理，使后续属性变更处理视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 向玩家发出提示消息，请其选择要宣言的属性（HINTMSG_ATTRIBUTE），用于后续的属性选择界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 让此卡原控制者从除当前属性以外的所有属性中宣言1个属性，返回的aat为要变更成的属性。
		local aat=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
		-- 那之后，可以把这张卡的属性直到下个回合的结束时变更为任意属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(aat)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
