--魔界造車－GT19
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，宣言1～9的任意等级才能发动。这张卡的等级直到回合结束时变成宣言的等级。
-- ②：反转过的这张卡表侧表示存在的场合，自己·对方的主要阶段，以这张卡以外的自己·对方场上1只表侧表示怪兽为对象才能发动。只用那只怪兽和这张卡为素材作同调召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①反转时变更等级的诱发选发效果、②反转后标记自身的持续效果、③主要阶段以场上怪兽为对象作同调召唤的诱发即时效果
function s.initial_effect(c)
	-- ①：这张卡反转的场合，宣言1～9的任意等级才能发动。这张卡的等级直到回合结束时变成宣言的等级。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ②：反转过的这张卡表侧表示存在的场合（反转时给自己注册标记，用于②效果的发动条件判定）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_FLIP)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.flipop)
	c:RegisterEffect(e2)
	-- ②：反转过的这张卡表侧表示存在的场合，自己·对方的主要阶段，以这张卡以外的自己·对方场上1只表侧表示怪兽为对象才能发动。只用那只怪兽和这张卡为素材作同调召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(s.syncon)
	e3:SetTarget(s.syntg)
	e3:SetOperation(s.synop)
	c:RegisterEffect(e3)
end
-- ①效果的对象选择阶段：发动时让发动玩家宣言一个1～9的等级（排除当前等级），并记录宣言值
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lv=e:GetHandler():GetLevel()
	-- 提示玩家选择要宣言的等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言1～9的任意等级（不能宣言当前等级），并将宣言的等级保存到效果标签中
	e:SetLabel(Duel.AnnounceLevel(tp,1,9,lv))
end
-- ①效果的处理：若这张卡表侧表示存在且与效果关联，则给自己注册一个持续到回合结束的等级变更效果，把等级变成宣言的等级
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级直到回合结束时变成宣言的等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 反转时处理：给这张卡注册一个持续到离场等重置条件的标记，表示这张卡已经反转过
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- ②效果的发动条件判定：这张卡必须反转过（带有标记）且当前是自己或对方的主要阶段
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return c:GetFlagEffect(id)>0
		and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 对象过滤函数：目标怪兽必须表侧表示且能作为同调素材，并且只用这张卡和目标怪兽为素材能同调召唤出额外卡组的怪兽
function s.filter(tc,c,tp)
	if not tc:IsFaceup() or not tc:IsCanBeSynchroMaterial() then return false end
	local mg=Group.FromCards(c,tc)
	-- 检查自己的额外卡组是否存在能以这张卡和目标怪兽这组素材同调召唤的怪兽
	return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 同调怪兽过滤函数：该同调怪兽能以给定的素材组进行同调召唤
function s.synfilter(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end
-- ②效果的对象选择阶段：确认双方场上存在可作对象的合法怪兽，选择这张卡以外的1只表侧表示怪兽为对象，并设置将从额外卡组特殊召唤的操作信息
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,c,tp) end
	-- 效果能否发动的检测：双方场上是否存在这张卡以外的满足条件的可对象怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 以这张卡以外的自己·对方场上1只表侧表示且能作同调素材的怪兽为对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,c,tp)
	-- 设置操作信息：将从额外卡组特殊召唤1只怪兽，用于其他卡片对特殊召唤效果的连锁检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：若这张卡和对象怪兽都表侧表示存在、与效果关联且对象不受效果影响，则只用那只怪兽和这张卡为素材，从额外卡组选择1只可同调召唤的怪兽进行同调召唤
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local mg=Group.FromCards(c,tc)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的额外卡组选择1只能用这张卡和对象怪兽这组素材同调召唤的怪兽
		local g=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
		local sc=g:GetFirst()
		if sc then
			-- 只用那只怪兽和这张卡为素材，对选择的同调怪兽进行同调召唤
			Duel.SynchroSummon(tp,sc,nil,mg)
		end
	end
end
