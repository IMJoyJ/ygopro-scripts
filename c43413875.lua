--花札衛－芒に月－
-- 效果：
-- 这张卡不能通常召唤。把「花札卫-芒上月-」以外的自己场上1只8星「花札卫」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
-- ②：1回合1次，这张卡战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
function c43413875.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：把「花札卫-芒上月-」以外的自己场上1只8星「花札卫」怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c43413875.hspcon)
	e1:SetTarget(c43413875.hsptg)
	e1:SetOperation(c43413875.hspop)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43413875,0))  --"抽1张卡并给双方确认"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c43413875.target)
	e2:SetOperation(c43413875.operation)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：1回合1次，这张卡战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1)
	-- 规则层面作用：检测当前处理的怪兽是否与对方怪兽战斗并被破坏
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c43413875.drtg)
	e3:SetOperation(c43413875.drop)
	c:RegisterEffect(e3)
end
-- 规则层面作用：过滤满足条件的可解放怪兽（花札卫、8星、非芒上月、有可用怪兽区）
function c43413875.hspfilter(c,tp)
	return c:IsSetCard(0xe6) and c:IsLevel(8) and not c:IsCode(43413875)
		-- 规则层面作用：确保该怪兽在场上有可用的怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 规则层面作用：检查是否有满足条件的怪兽可以解放用于特殊召唤
function c43413875.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面作用：检查玩家场上是否存在至少1张满足hspfilter条件的可解放怪兽
	return Duel.CheckReleaseGroupEx(tp,c43413875.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 规则层面作用：选择并设置要解放的怪兽
function c43413875.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 规则层面作用：获取玩家可解放的怪兽组并筛选满足条件的
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c43413875.hspfilter,nil,tp)
	-- 规则层面作用：提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 规则层面作用：执行怪兽解放操作
function c43413875.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 规则层面作用：将指定怪兽以特殊召唤原因进行解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 规则层面作用：设置效果处理的目标玩家和参数
function c43413875.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置效果处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面作用：设置效果处理的目标参数为1
	Duel.SetTargetParam(1)
	-- 规则层面作用：设置效果处理的操作信息为抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面作用：处理特殊召唤成功后的效果（抽卡、确认、判断是否特殊召唤）
function c43413875.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面作用：执行抽卡操作并判断是否成功
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 规则层面作用：获取抽卡后实际操作的卡片
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 规则层面作用：向对方玩家确认抽到的卡片
		Duel.ConfirmCards(1-tp,tc)
		-- 规则层面作用：中断当前效果处理
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 规则层面作用：检查是否有足够的怪兽区用于特殊召唤
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 规则层面作用：询问玩家是否要特殊召唤抽到的怪兽
				and Duel.SelectYesNo(tp,aux.Stringid(43413875,1)) then  --"是否特殊召唤？"
				-- 规则层面作用：将抽到的怪兽特殊召唤到场上
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 规则层面作用：将非花札卫怪兽送入墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 规则层面作用：洗切玩家手牌
		Duel.ShuffleHand(tp)
	end
end
-- 规则层面作用：设置效果处理的目标玩家和参数
function c43413875.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 规则层面作用：设置效果处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面作用：设置效果处理的目标参数为1
	Duel.SetTargetParam(1)
	-- 规则层面作用：设置效果处理的操作信息为抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面作用：处理战斗破坏后抽卡的效果
function c43413875.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面作用：执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
