--燿ける聖詩の獄神精
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：自己·对方的主要阶段，以自己的中央的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升3星。那之后，可以进行1只「耀圣」同调怪兽或「调狱神 朱诺拉」的同调召唤。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「耀圣」卡加入手卡。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- 为卡片注册关联卡片代码5914858
	aux.AddCodeList(c,5914858)
	-- ①：自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，以自己的中央的主要怪兽区域1只怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升3星。那之后，可以进行1只「耀圣」同调怪兽或「调狱神 朱诺拉」的同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.lvcon)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「耀圣」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 限制特殊召唤效果的判断函数
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 等级上升效果的发动条件函数
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 选择目标怪兽的过滤函数
function s.lvfilter(c,e)
	return c:GetSequence()==2 and c:IsFaceup() and c:IsLevelAbove(1)
		and c:IsCanBeEffectTarget(e)
end
-- 等级上升效果的目标选择函数
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil,e) end
	-- 获取满足条件的怪兽数组
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil,e)
	if g:GetCount()==1 then
		-- 设置当前连锁的目标为指定怪兽
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择目标
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		-- 选择目标怪兽
		Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
	end
end
-- 同调召唤过滤函数
function s.syncfilter(c,tp)
	return (c:IsSetCard(0x1d8) or c:IsCode(5914858)) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil)
end
-- 等级上升效果的处理函数
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 为目标怪兽增加3星等级
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(3)
		tc:RegisterEffect(e1)
		-- 刷新场上状态
		Duel.AdjustAll()
		-- 检查是否存在可同调召唤的怪兽并询问是否发动
		if Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择同调召唤对象
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			-- 选择用于同调召唤的怪兽
			local g=Duel.SelectMatchingCard(tp,s.syncfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			-- 执行同调召唤手续
			Duel.SynchroSummon(tp,g:GetFirst(),nil)
		end
	end
end
-- 检索效果的发动条件函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 检索卡牌的过滤函数
function s.thfilter(c)
	return c:IsSetCard(0x1d8) and c:IsAbleToHand()
end
-- 检索效果的目标选择函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的检索卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为检索卡牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要检索的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择要检索的卡牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡牌加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
