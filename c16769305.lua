--魔界造車－GT19
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合，宣言1～9的任意等级才能发动。这张卡的等级直到回合结束时变成宣言的等级。
-- ②：反转过的这张卡表侧表示存在的场合，自己·对方的主要阶段，以这张卡以外的自己·对方场上1只表侧表示怪兽为对象才能发动。只用那只怪兽和这张卡为素材作同调召唤。
local s,id,o=GetID()
-- 创建三个效果：①反转时改变等级效果、②反转标记记录效果、③同调召唤效果
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
	-- 反转过的这张卡表侧表示存在的场合，自己·对方的主要阶段，以这张卡以外的自己·对方场上1只表侧表示怪兽为对象才能发动。只用那只怪兽和这张卡为素材作同调召唤。
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
-- 等级改变效果的发动处理，用于选择宣言等级
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lv=e:GetHandler():GetLevel()
	-- 提示玩家选择等级
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	-- 获取玩家宣言的等级并保存到效果标签中
	e:SetLabel(Duel.AnnounceLevel(tp,1,9,lv))
end
-- 等级改变效果的执行处理，将等级设置为宣言的等级
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 设置等级改变效果，使等级在回合结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 反转效果的处理，为该卡添加反转标记
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 同调召唤效果的发动条件判断，检查是否已反转且处于主要阶段
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return c:GetFlagEffect(id)>0
		and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 筛选可用于同调召唤的怪兽，检查是否存在满足条件的同调怪兽
function s.filter(tc,c,tp)
	if not tc:IsFaceup() or not tc:IsCanBeSynchroMaterial() then return false end
	local mg=Group.FromCards(c,tc)
	-- 检查是否存在满足同调召唤条件的怪兽
	return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 判断怪兽是否可以进行同调召唤
function s.synfilter(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end
-- 同调召唤效果的目标选择处理，选择目标怪兽并设置操作信息
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,c,tp) end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,c,tp)
	-- 设置操作信息，表示将要特殊召唤同调怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 同调召唤效果的执行处理，选择并进行同调召唤
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local mg=Group.FromCards(c,tc)
		-- 提示玩家选择要特殊召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的同调怪兽
		local g=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
		local sc=g:GetFirst()
		if sc then
			-- 执行同调召唤手续
			Duel.SynchroSummon(tp,sc,nil,mg)
		end
	end
end
