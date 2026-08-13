--花札衛－芒に月－
-- 效果：
-- 这张卡不能通常召唤。把「花札卫-芒上月-」以外的自己场上1只8星「花札卫」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
-- ②：1回合1次，这张卡战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
function c43413875.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文：这张卡不能通常召唤。把「花札卫-芒上月-」以外的自己场上1只8星「花札卫」怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c43413875.hspcon)
	e1:SetTarget(c43413875.hsptg)
	e1:SetOperation(c43413875.hspop)
	c:RegisterEffect(e1)
	-- 对应效果原文：①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43413875,0))  --"抽1张卡并给双方确认"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c43413875.target)
	e2:SetOperation(c43413875.operation)
	c:RegisterEffect(e2)
	-- 对应效果原文：②：1回合1次，这张卡战斗破坏对方怪兽时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1)
	-- 设置②效果发动条件：此卡与对方怪兽战斗并将其破坏时才能发动。
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c43413875.drtg)
	e3:SetOperation(c43413875.drop)
	c:RegisterEffect(e3)
end
-- 定义可作为解放候选的怪兽：是「花札卫」8星怪兽、不是本卡自身、解放后我方怪兽区仍有空位，且该怪兽为我方控制或为表侧表示。
function c43413875.hspfilter(c,tp)
	return c:IsSetCard(0xe6) and c:IsLevel(8) and not c:IsCode(43413875)
		-- 额外要求解放该候选怪兽后我方怪兽区仍有空位，且该怪兽能被解放（我方控制或表侧表示）。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤手续的发动条件判断：只要存在满足解放条件的怪兽，该规则特殊召唤就可以进行。
function c43413875.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方场上或手卡是否存在至少1只满足hspfilter条件的可解放怪兽（非上级召唤用）。
	return Duel.CheckReleaseGroupEx(tp,c43413875.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤手续的目标选择：从可解放的怪兽中选出1只，并存入效果标签作为解放对象。
function c43413875.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取我方当前可解放（非上级召唤用）的怪兽组，再过滤出符合“花札卫8星非自身”等条件的候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c43413875.hspfilter,nil,tp)
	-- 向发动玩家显示“请选择要解放的卡”的提示，用于选择解放怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的执行处理：取出之前选定的怪兽并解放。
function c43413875.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为理由解放选定怪兽，作为特殊召唤的代价。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ①效果的发动条件与对象登记：效果发动时无条件合法，并登记抽卡玩家和抽1张卡的操作信息。
function c43413875.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的抽卡玩家为发动效果的我方玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记“效果抽1张卡”的操作信息，供相关卡牌效果检测连锁内容。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果的处理：抽1张卡并向对方确认；若为「花札卫」怪兽且可特殊召唤则询问玩家并特殊召唤，否则送去墓地；最后洗切手卡。
function c43413875.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁读取已登记的抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，若实际抽到卡（抽卡成功）才继续后续处理。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 取得刚抽到的那张卡（实际操作组中的第一张卡）。
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 将抽到的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果处理，使后续的特殊召唤或送墓作为另外的效果处理，避免造成错误时点。
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 额外确认我方怪兽区有空位，满足特殊召唤所需条件。
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 询问我方玩家是否将抽到的「花札卫」怪兽特殊召唤，玩家选择“是”才执行召唤。
				and Duel.SelectYesNo(tp,aux.Stringid(43413875,1)) then  --"是否特殊召唤？"
				-- 将抽到的那只怪兽以表侧表示特殊召唤到我方场上。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 若抽到的不是「花札卫」怪兽，则将该卡以效果原因送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 洗切我方手卡，使从卡组抽卡后的手卡顺序随机化。
		Duel.ShuffleHand(tp)
	end
end
-- ②效果的发动条件与对象登记：检查玩家可以抽1张卡，并登记抽卡玩家和数量。
function c43413875.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：若我方不能抽卡则②效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的抽卡玩家为发动效果的我方玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记“效果抽1张卡”的操作信息，供相关卡牌效果检测连锁内容。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理：读取抽卡玩家和数量后执行抽卡。
function c43413875.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁读取已登记的抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让我方玩家从卡组抽1张卡（效果抽卡）。
	Duel.Draw(p,d,REASON_EFFECT)
end
