--DDDD超次元統皇ゼロ・パラドックス
-- 效果：
-- ←10 【灵摆】 10→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以对方的灵摆区域1张卡为对象才能发动。这张卡特殊召唤，作为对象的卡在自己的灵摆区域放置。这个效果放置的卡在下个回合的结束阶段破坏。
-- 【怪兽效果】
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：自己把怪兽灵摆召唤时，若自己的灵摆区域的灵摆刻度合计超过灵摆召唤的怪兽的等级合计则能发动。这张卡从手卡特殊召唤，场上的其他卡全部破坏。那之后，可以把这张卡在自己的灵摆区域放置。
-- ②：1回合1次，自己场上的其他的表侧表示的「DDD」怪兽因魔法卡的效果从场上离开的场合发动。这张卡的攻击力变成6000。
function c97417863.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：以对方的灵摆区域1张卡为对象才能发动。这张卡特殊召唤，作为对象的卡在自己的灵摆区域放置。这个效果放置的卡在下个回合的结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,97417863)
	e1:SetTarget(c97417863.pltg)
	e1:SetOperation(c97417863.plop)
	c:RegisterEffect(e1)
	-- ①：自己把怪兽灵摆召唤时，若自己的灵摆区域的灵摆刻度合计超过灵摆召唤的怪兽的等级合计则能发动。这张卡从手卡特殊召唤，场上的其他卡全部破坏。那之后，可以把这张卡在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97417863,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c97417863.spcon)
	e2:SetTarget(c97417863.sptg)
	e2:SetOperation(c97417863.spop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己场上的其他的表侧表示的「DDD」怪兽因魔法卡的效果从场上离开的场合发动。这张卡的攻击力变成6000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97417863,2))  --"这张卡的攻击力变成6000"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c97417863.atkcon)
	e3:SetTarget(c97417863.atktg)
	e3:SetOperation(c97417863.atkop)
	c:RegisterEffect(e3)
end
-- 灵摆效果的发动准备与合法性检测（检查对象卡、自身特召条件及怪兽区域空格）
function c97417863.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	local c=e:GetHandler()
	-- 判定对方的灵摆区域是否存在可以转移控制权的卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_PZONE,1,nil)
		-- 判定自己场上是否有可用的怪兽区域空格，且自身是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 提示玩家选择要作为效果对象的目标卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方灵摆区域的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_PZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：改变1张卡的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置当前连锁的操作信息为：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果的执行处理（特殊召唤自身，将对象卡放置到自己的灵摆区域，并注册下个回合结束阶段破坏的效果）
function c97417863.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象卡片
	local tc=Duel.GetFirstTarget()
	-- 判定自身是否仍与效果相关，并尝试无视召唤条件特殊召唤自身
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)>0 then
		c:CompleteProcedure()
		if not tc:IsRelateToEffect(e) then return end
		-- 将对象卡移动并放置到自己的灵摆区域，若失败则结束处理
		if not Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then return end
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(97417863,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果放置的卡在下个回合的结束阶段破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetCountLimit(1)
		-- 记录当前卡片的唯一标识ID和当前回合数，用于后续判定“下个回合”
		e1:SetLabel(fid,Duel.GetTurnCount())
		e1:SetLabelObject(tc)
		e1:SetCondition(c97417863.descon)
		e1:SetOperation(c97417863.desop)
		-- 注册全局延迟破坏效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 延迟破坏效果的触发条件判定（必须是下个回合或更晚的回合，且目标卡片仍带有相同的标识ID）
function c97417863.descon(e,tp,eg,ep,ev,re,r,rp)
	local fid,ct=e:GetLabel()
	local tc=e:GetLabelObject()
	-- 判定当前回合数不等于发动效果时的回合数（即至少到了下个回合），且目标卡片上的标记未丢失
	return Duel.GetTurnCount()~=ct and tc:GetFlagEffectLabel(97417863)==fid
end
-- 延迟破坏效果的执行（破坏目标卡片）
function c97417863.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果破坏目标卡片
	Duel.Destroy(tc,REASON_EFFECT)
end
-- 过滤出由自己灵摆召唤成功且表侧表示存在的怪兽
function c97417863.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsFaceup()
end
-- 怪兽效果①的发动条件判定（自己灵摆召唤怪兽时，且自己灵摆区域的刻度合计大于灵摆召唤怪兽的等级合计）
function c97417863.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己灵摆区域的所有卡片
	local pg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #pg==0 then return false end
	local pval=pg:GetSum(Card.GetLeftScale)
	local g=eg:Filter(c97417863.cfilter,nil,tp)
	local lv=g:GetSum(Card.GetLevel)
	return #g>0 and lv>0 and pval>lv
end
-- 怪兽效果①的发动准备与合法性检测（检查自身特召条件、怪兽区域空格及场上是否有其他卡可破坏）
function c97417863.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取场上除自身以外的所有卡片
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 判定自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and #g>0 end
	-- 设置当前连锁的操作信息为：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置当前连锁的操作信息为：破坏场上其他所有卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 怪兽效果①的执行处理（特殊召唤自身，破坏场上其他所有卡，之后可选择将自身放置到灵摆区域）
function c97417863.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试无视召唤条件特殊召唤自身，若失败则结束处理
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)==0 then return end
	c:CompleteProcedure()
	-- 重新获取场上除自身以外的所有卡片（用于执行破坏）
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 破坏场上其他卡片，若成功破坏则询问玩家是否将自身放置到自己的灵摆区域
	if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.SelectYesNo(tp,aux.Stringid(97417863,1)) then  --"是否把这张卡在自己的灵摆区域放置？"
		-- 中断当前效果处理，使后续的放置处理与破坏处理不视为同时进行
		Duel.BreakEffect()
		-- 将自身移动并放置到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
-- 过滤出因魔法卡的效果从自己场上离开的、原本由自己控制的表侧表示「DDD」怪兽
function c97417863.lefilter(c,tp,re)
	return re and re:IsActiveType(TYPE_SPELL) and c:IsReason(REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x10af)
end
-- 怪兽效果②的发动条件判定（自己场上其他的表侧表示「DDD」怪兽因魔法卡效果离场）
function c97417863.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c97417863.lefilter,1,nil,tp,re) and not eg:IsContains(e:GetHandler())
end
-- 怪兽效果②的发动准备与合法性检测（直接返回true）
function c97417863.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 怪兽效果②的执行处理（将自身的攻击力变成6000）
function c97417863.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetAttack()~=6000 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力变成6000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(6000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
