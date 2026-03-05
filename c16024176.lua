--花札衛－松に鶴－
-- 效果：
-- 这张卡不能通常召唤。把「花札卫-松上鹤-」以外的自己场上1只1星「花札卫」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
-- ②：这张卡进行战斗的战斗阶段结束时才能发动。自己从卡组抽1张。
function c16024176.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：把「花札卫-松上鹤-」以外的自己场上1只1星「花札卫」怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c16024176.hspcon)
	e1:SetTarget(c16024176.hsptg)
	e1:SetOperation(c16024176.hspop)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16024176,0))  --"抽1张卡并给双方确认"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c16024176.target)
	e2:SetOperation(c16024176.operation)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：这张卡进行战斗的战斗阶段结束时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c16024176.drcon)
	e3:SetTarget(c16024176.drtg)
	e3:SetOperation(c16024176.drop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：定义了特殊召唤所需的过滤条件，包括卡组为花札卫、等级为1、不是本卡、且有可用怪兽区。
function c16024176.hspfilter(c,tp)
	return c:IsSetCard(0xe6) and c:IsLevel(1) and not c:IsCode(16024176)
		-- 规则层面操作：检查目标怪兽是否在己方场上且有可用怪兽区。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 规则层面操作：检查是否满足特殊召唤条件，即是否有符合条件的怪兽可解放。
function c16024176.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面操作：调用CheckReleaseGroupEx函数检查是否有满足条件的怪兽可解放。
	return Duel.CheckReleaseGroupEx(tp,c16024176.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 规则层面操作：选择并设置要解放的怪兽。
function c16024176.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 规则层面操作：获取可解放的怪兽组并进行过滤。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c16024176.hspfilter,nil,tp)
	-- 规则层面操作：提示玩家选择要解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 规则层面操作：执行怪兽解放操作。
function c16024176.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 规则层面操作：将指定怪兽以特殊召唤原因进行解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 规则层面操作：设置效果的目标玩家和参数。
function c16024176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置效果的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设置效果的目标参数为1。
	Duel.SetTargetParam(1)
	-- 规则层面操作：设置效果操作信息为抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面操作：处理特殊召唤成功后的效果，包括抽卡、确认、判断是否为花札卫怪兽并决定是否特殊召唤或送入墓地。
function c16024176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取连锁中的目标玩家和参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：执行抽卡操作。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 规则层面操作：获取抽卡后操作的卡片。
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 规则层面操作：向对方确认抽到的卡片。
		Duel.ConfirmCards(1-tp,tc)
		-- 规则层面操作：中断当前效果处理。
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 规则层面操作：检查是否有可用怪兽区。
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 规则层面操作：询问玩家是否特殊召唤抽到的卡片。
				and Duel.SelectYesNo(tp,aux.Stringid(16024176,1)) then  --"是否特殊召唤？"
				-- 规则层面操作：将卡片特殊召唤到场上。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 规则层面操作：将卡片送入墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 规则层面操作：洗切玩家手牌。
		Duel.ShuffleHand(tp)
	end
end
-- 规则层面操作：判断是否在战斗阶段结束时发动效果。
function c16024176.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 规则层面操作：设置抽卡效果的目标玩家和参数。
function c16024176.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 规则层面操作：设置效果的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设置效果的目标参数为1。
	Duel.SetTargetParam(1)
	-- 规则层面操作：设置效果操作信息为抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面操作：处理战斗阶段结束时的抽卡效果。
function c16024176.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取连锁中的目标玩家和参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：执行抽卡操作。
	Duel.Draw(p,d,REASON_EFFECT)
end
