--巳剣之皇子 小碓
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把手卡1只其他的爬虫类族怪兽和对方场上1只怪兽解放，从手卡特殊召唤。这个方法特殊召唤过的回合自己不是爬虫类族怪兽不能特殊召唤，不能把爬虫类族以外的怪兽的效果发动。
-- ②：这张卡被解放的场合才能发动。选自己1张手卡丢弃，这张卡加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- ①：这张卡可以把手卡1只其他的爬虫类族怪兽和对方场上1只怪兽解放，从手卡特殊召唤。这个卡名的①的方法的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放的场合才能发动。选自己1张手卡丢弃，这张卡加入手卡。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中的爬虫类族怪兽
function s.spfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsLocation(LOCATION_HAND)
end
-- 过滤可以被解放的怪兽
function s.spfilter2(c)
	return c:IsReleasable(REASON_SPSUMMON)
end
-- 特殊召唤规则的条件判断
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有空余的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在除自身以外可解放的爬虫类族怪兽
		and Duel.CheckReleaseGroupEx(tp,s.spfilter,1,REASON_SPSUMMON,true,c)
		-- 检查对方场上是否存在可解放的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 特殊召唤规则的解放目标选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中可解放的爬虫类族怪兽（排除自身）
	local g=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON):Filter(s.spfilter,e:GetHandler())
	-- 提示选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if not tc then return false end
	-- 获取对方场上可解放的怪兽
	local g2=Duel.GetMatchingGroup(s.spfilter2,tp,0,LOCATION_MZONE,nil)
	-- 提示选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc2=g2:SelectUnselect(nil,tp,false,true,1,1)
	if tc2 then
		local sg=Group.FromCards(tc,tc2)
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数，解放怪兽并注册限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的手卡和对方场上的怪兽
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
	-- 这个方法特殊召唤过的回合自己不是爬虫类族怪兽不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤爬虫类族以外怪兽的限制
	Duel.RegisterEffect(e1,c:GetControler())
	-- 不能把爬虫类族以外的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.aclimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能发动爬虫类族以外怪兽效果的限制
	Duel.RegisterEffect(e2,c:GetControler())
end
-- 限制不能特殊召唤爬虫类族以外的怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_REPTILE)
end
-- 限制不能发动爬虫类族以外怪兽的效果
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsRace(RACE_REPTILE)
end
-- 效果②的发动准备与目标确认
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在可丢弃的卡，且此卡是否能加入手卡
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT)>0
		and c:IsAbleToHand() end
	-- 设置将此卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 效果②的处理函数，丢弃手卡并将此卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取手卡中可丢弃的卡片组
	local sg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT+REASON_DISCARD)
	-- 提示选择要丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local g=sg:Select(tp,1,1,nil)
	-- 若成功丢弃手卡且此卡仍存在于墓地（不受王家之谷影响）
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)>0 and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,c)
	end
end
