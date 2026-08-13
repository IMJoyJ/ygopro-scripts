--花札衛－松に鶴－
-- 效果：
-- 这张卡不能通常召唤。把「花札卫-松上鹤-」以外的自己场上1只1星「花札卫」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
-- ②：这张卡进行战斗的战斗阶段结束时才能发动。自己从卡组抽1张。
function c16024176.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把「花札卫-松上鹤-」以外的自己场上1只1星「花札卫」怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c16024176.hspcon)
	e1:SetTarget(c16024176.hsptg)
	e1:SetOperation(c16024176.hspop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16024176,0))  --"抽1张卡并给双方确认"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c16024176.target)
	e2:SetOperation(c16024176.operation)
	c:RegisterEffect(e2)
	-- ②：这张卡进行战斗的战斗阶段结束时才能发动。自己从卡组抽1张。
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
-- 定义解放素材过滤条件：候选怪兽必须是1星「花札卫」怪兽、卡名不是「花札卫-松上鹤-」，且解放后自己场上仍有可用怪兽区域，同时该怪兽是自己控制或表侧表示。
function c16024176.hspfilter(c,tp)
	return c:IsSetCard(0xe6) and c:IsLevel(1) and not c:IsCode(16024176)
		-- 补充过滤条件：解放该怪兽后自己场上仍有空的怪兽区域，且该怪兽是自己控制或表侧表示。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则效果的条件：先处理未指定卡的情况（c为nil时返回true），否则检查玩家能否提供1只满足解放素材条件且可解放的「花札卫」怪兽。
function c16024176.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1只可解放的满足hspfilter条件的1星「花札卫」怪兽，用于这次规则特殊召唤。
	return Duel.CheckReleaseGroupEx(tp,c16024176.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤手续的选择阶段：从场上可解放的候选中选出1只怪兽，将其记录到效果标签中，供后续解放使用。
function c16024176.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放的怪兽组，并按解放素材过滤条件筛选出候选集合。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c16024176.hspfilter,nil,tp)
	-- 向玩家显示“请选择要解放的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的执行操作：取出之前选定的那只怪兽并执行解放。
function c16024176.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽作为特殊召唤的代价解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ①效果发动时的目标设定：无额外发动条件，设定抽卡对象为自己、抽1张，并登记抽卡操作信息。
function c16024176.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为发动玩家自己（①效果中抽卡者为自己）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记①效果包含抽卡操作：对象玩家为自己，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果处理：自己抽1张卡，向对方展示；若抽到的是「花札卫」怪兽且可以特殊召唤，则询问玩家是否将其特殊召唤；若不是「花札卫」怪兽，则将其送去墓地；最后洗切手牌。
function c16024176.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出①效果设定的抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让指定玩家抽指定数量的卡，若抽卡成功则继续处理。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取刚才实际抽到的那张卡。
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 将抽到的那张卡向对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果，使后续的特殊召唤/送墓作为独立效果处理，避免错过时点。
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 检查自己场上是否有空余的主要怪兽区域，用于决定能否特殊召唤那张「花札卫」怪兽。
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 弹出“是否特殊召唤？”的选择框，只有玩家选择“是”才继续执行特殊召唤。
				and Duel.SelectYesNo(tp,aux.Stringid(16024176,1)) then  --"是否特殊召唤？"
				-- 将抽到的「花札卫」怪兽以表侧表示特殊召唤到自己的怪兽区域。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 抽到的卡不是「花札卫」怪兽时，将那张卡送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 洗切发动玩家的手牌，使手牌顺序重新随机化。
		Duel.ShuffleHand(tp)
	end
end
-- ②效果发动条件：这张卡进行过战斗（战斗阶段中有与之战斗过的怪兽）。
function c16024176.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- ②效果的发动目标设定：先检查自己能否抽1张卡，可以则设定抽卡对象为自己并登记抽卡操作信息。
function c16024176.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，返回自己是否能够通过效果抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为发动玩家自己（②效果中抽卡者为自己）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记②效果包含抽卡操作：对象玩家为自己，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：从当前连锁信息中取出对象玩家和抽卡数量并执行抽卡。
function c16024176.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出②效果设定的抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家以效果原因抽取指定数量的卡，即自己抽1张。
	Duel.Draw(p,d,REASON_EFFECT)
end
