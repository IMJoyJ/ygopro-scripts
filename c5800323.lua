--白き森の幻妖
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己墓地2只「白森林」怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
-- ②：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤手续，并注册①②效果
function s.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以自己墓地2只「白森林」怪兽为对象才能发动。那些怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置到魔陷区"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地可以放置到魔陷区的「白森林」怪兽
function s.mvfilter(c,tp)
	return c:IsSetCard(0x1b1) and c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的发动准备与目标选择（检查墓地是否有2只「白森林」怪兽以及魔陷区是否有2个空位，并选择目标）
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.mvfilter(chkc,tp) end
	if chk==0 then
		-- 检查自己墓地是否存在至少2只满足条件的「白森林」怪兽
		if not Duel.IsExistingTarget(s.mvfilter,tp,LOCATION_GRAVE,0,2,nil,tp) then return false end
		-- 检查自己场上的魔法与陷阱区域是否有2个以上的空位
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>1
	end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择自己墓地2只「白森林」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.mvfilter,tp,LOCATION_GRAVE,0,2,2,nil,tp)
	-- 设置效果处理信息为：将选中的卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
end
-- ①效果的处理：将选中的墓地怪兽作为永续魔法卡表侧表示放置到魔陷区
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上魔法与陷阱区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	-- 获取当前连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e):Filter(s.mvfilter,nil,tp)
	if sg:GetCount()>0 then
		if sg:GetCount()>ft then
			-- 若可用空格不足，提示玩家选择要放置到场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local rg=sg:Select(tp,ft,ft,nil)
			sg=rg
		end
		local tc=sg:GetFirst()
		while tc do
			-- 将目标卡片移动到魔法与陷阱区域表侧表示放置
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 那些怪兽当作永续魔法卡使用
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
			tc=sg:GetNext()
		end
	end
end
-- ②效果的发动条件判定
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合的主要阶段
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- ②效果的发动准备（检查是否存在可同调召唤的怪兽，并设置特殊召唤的操作信息）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以用这张卡作为素材进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	-- 设置效果处理信息为：从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：用包含这张卡的自己场上怪兽为素材进行同调召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中可以用这张卡作为素材进行同调召唤的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以这张卡为素材，对选中的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
