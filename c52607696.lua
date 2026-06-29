--幻惑のバリア －ミラージュフォース－
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤，那只攻击怪兽回到手卡。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的幻想魔族怪兽因对方的效果从场上离开的场合，把这张卡除外才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤。
local s,id,o=GetID()
-- 注册攻击宣言时特召手卡/墓地幻想魔族并弹回攻击怪兽、以及幻想魔族因对方效果离场时除外墓地自身特召幻想魔族的效果
function s.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤，那只攻击怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的幻想魔族怪兽因对方的效果从场上离开的场合，把这张卡除外才能发动。从自己的手卡·墓地把1只幻想魔族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	-- 将墓地的此卡除外作为效果②发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 确认此次攻击确实是由对方控制的怪兽发起的
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前发起攻击宣言的怪兽对象
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end
-- 手卡或墓地中属于幻想魔族且可特殊召唤的怪兽 the 过滤条件
function s.filter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前的发动条件来源攻击怪兽
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsRelateToBattle() and at:IsAbleToHand()
		-- 检查自己场上是否有空闲的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在可以特殊召唤的幻想魔族怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息为将攻击怪兽返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,at,1,0,0)
	-- 设置操作信息为从手卡/墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤幻想魔族并将攻击怪兽返回手牌效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 确认场上是否有空余的怪兽区域，若无则停止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择需要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地中选择1只符合条件的幻想魔族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选择的幻想魔族怪兽特殊召唤，若特召成功则处理后续的弹回
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取当前正在进行战斗的对方攻击怪兽
		local at=Duel.GetAttacker()
		if at:IsRelateToBattle() then
			-- 将该对方攻击怪兽送回持有者的手牌
			Duel.SendtoHand(at,nil,REASON_EFFECT)
		end
	end
end
-- 自己场上原本表侧表示存在的幻想魔族怪兽，因对方效果移动离开场上时的过滤条件
function s.spcfilter(c,tp)
	return bit.band(c:GetPreviousRaceOnField(),RACE_ILLUSION)~=0 and c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 判断当前是否触发了自己场上表侧幻想魔族因对方效果离场的时间时点
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil,tp)
end
-- 效果②的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 尝试在效果②中获取攻击怪兽，若无可忽略
	local at=Duel.GetAttacker()
	-- 检查自己场上是否有空闲的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在可以特殊召唤的幻想魔族怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤幻想魔族怪兽效果的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认场上是否有空闲怪兽格，若无则停止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示，请选择需要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地中选择1只符合条件的幻想魔族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
