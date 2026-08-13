--花札衛－桐に鳳凰－
-- 效果：
-- 这张卡不能通常召唤。把「花札卫-桐上凤凰-」以外的自己场上1只12星「花札卫」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
-- ②：1回合1次，这张卡给与对方战斗伤害时才能发动。自己从卡组抽1张。
function c16802689.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把「花札卫-桐上凤凰-」以外的自己场上1只12星「花札卫」怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c16802689.hspcon)
	e1:SetTarget(c16802689.hsptg)
	e1:SetOperation(c16802689.hspop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽特殊召唤。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16802689,0))  --"抽1张卡并给双方确认"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c16802689.target)
	e2:SetOperation(c16802689.operation)
	c:RegisterEffect(e2)
	-- ②：1回合1次，这张卡给与对方战斗伤害时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCountLimit(1)
	e3:SetCondition(c16802689.drcon)
	e3:SetTarget(c16802689.drtg)
	e3:SetOperation(c16802689.drop)
	c:RegisterEffect(e3)
end
-- 过滤可解放的怪兽：必须为12星的「花札卫」怪兽且不是「花札卫-桐上凤凰-」自身，解放后我方场上仍有可用怪兽区，且该怪兽是我方控制的怪兽或表侧表示，确保可作为解放素材。
function c16802689.hspfilter(c,tp)
	return c:IsSetCard(0xe6) and c:IsLevel(12) and not c:IsCode(16802689)
		-- 解放该怪兽后我方场上还有空余怪兽区用于特殊召唤，并且该怪兽的控制者为发动者或为表侧表示（确保其位于可解放的己方场上）。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则效果的条件：当c为nil时直接通过；否则检查发动者tp场上是否存在至少1只可解放且满足过滤条件的怪兽。
function c16802689.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家tp是否存在至少1只满足hspfilter条件的可解放怪兽，作为本次特殊召唤的解放素材。
	return Duel.CheckReleaseGroupEx(tp,c16802689.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤手续的目标选择：从可解放的怪兽组中筛选出符合条件的怪兽，提示玩家选择1只，并将选中的怪兽保存在效果e的LabelObject中供后续解放使用。
function c16802689.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得玩家tp可解放（非上级召唤用）的怪兽组，并用hspfilter过滤出满足条件的候选怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c16802689.hspfilter,nil,tp)
	-- 给玩家tp显示“请选择要解放的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的解放处理：取出之前选择保存的怪兽并执行解放。
function c16802689.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤为理由解放（作为特殊召唤手续的代价）。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ①效果的发动条件：特殊召唤成功时触发。在发动时设置抽卡的目标玩家为tp、抽卡张数为1，并登记操作信息为抽卡，用于后续处理与外部检测。
function c16802689.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为tp（即抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽卡数量）。
	Duel.SetTargetParam(1)
	-- 登记操作信息：效果分类为抽卡，抽卡玩家为tp，抽卡数量为1，供相关效果检测（如不能抽卡等）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果的结算：按设置的目标玩家和数量抽1张卡，给双方确认；若抽到的是「花札卫」怪兽且满足特殊召唤条件，则询问玩家是否特殊召唤，是则特殊召唤；否则（非「花札卫」怪兽）送去墓地；最后洗切手牌。
function c16802689.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的目标玩家和目标参数（即抽卡玩家和抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果理由抽d张卡；若实际抽卡成功（抽到了卡）则继续后续处理。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 取得刚刚抽卡操作实际操作的卡组中的第一张卡，即抽到的卡片。
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 将抽到的卡片展示给对方的玩家确认（实现“给双方确认”）。
		Duel.ConfirmCards(1-tp,tc)
		-- 中断当前效果，使后续的特殊召唤/送墓与前面的抽卡确认不在同一时点处理，避免错过时点。
		Duel.BreakEffect()
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 确认我方场上还存在空余的怪兽区，可用于特殊召唤抽到的怪兽。
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 询问我方玩家是否将抽到的「花札卫」怪兽特殊召唤。
				and Duel.SelectYesNo(tp,aux.Stringid(16802689,1)) then  --"是否特殊召唤？"
				-- 将抽到的「花札卫」怪兽以表侧表示特殊召唤到我方场上（不检查召唤条件、不检查苏生限制）。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 将抽到的非「花札卫」怪兽（不属于可特殊召唤对象）以效果理由送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 洗切玩家tp的手牌。
		Duel.ShuffleHand(tp)
	end
end
-- ②效果的发动条件：这张卡给与对方战斗伤害（受到战斗伤害的玩家不是自己）时才可发动。
function c16802689.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- ②效果的发动时处理：在发动检查时确认我方可以抽1张卡，然后设置抽卡目标玩家为tp、抽卡张数为1，并登记抽卡操作信息。
function c16802689.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：当前玩家tp能否抽1张卡（若不能抽则效果不能发动）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为tp（抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽卡数量）。
	Duel.SetTargetParam(1)
	-- 登记操作信息：效果分类为抽卡，抽卡玩家为tp，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的结算：按设定的目标玩家和数量抽1张卡。
function c16802689.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的目标玩家和目标参数（抽卡玩家和抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果理由抽d张卡，完成抽卡处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
