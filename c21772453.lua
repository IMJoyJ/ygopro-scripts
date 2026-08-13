--花札衛－紅葉に鹿－
-- 效果：
-- 这张卡不能通常召唤。把「花札卫-枫间鹿-」以外的自己场上1只「花札卫」怪兽解放的场合可以特殊召唤。
-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以选对方场上1张魔法·陷阱卡破坏。不是的场合，那张卡送去墓地。
function c21772453.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把「花札卫-枫间鹿-」以外的自己场上1只「花札卫」怪兽解放的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c21772453.hspcon)
	e1:SetTarget(c21772453.hsptg)
	e1:SetOperation(c21772453.hspop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以选对方场上1张魔法·陷阱卡破坏。不是的场合，那张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21772453,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c21772453.target)
	e2:SetOperation(c21772453.operation)
	c:RegisterEffect(e2)
end
-- 筛选可作为解放素材的「花札卫」怪兽：必须是「花札卫」卡、卡名不是「花札卫-枫间鹿-」本身，且解放后自己场上有可用怪兽区，同时该卡是自己控制或是表侧表示。
function c21772453.hspfilter(c,tp)
	return c:IsSetCard(0xe6) and not c:IsCode(21772453)
		-- 要求解放该卡后己方场上有空余怪兽区，并且该卡为自己控制或表侧表示，以合法完成解放特殊召唤手续。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的发动条件：判断当前玩家场上是否存在至少1只符合条件的「花札卫」怪兽（非自身）可作为解放素材；若无具体怪兽c，则用于规则查询是否存在可能。
function c21772453.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1只满足hspfilter条件的可解放「花札卫」怪兽（不含自身），用于该卡的特殊召唤。
	return Duel.CheckReleaseGroupEx(tp,c21772453.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的选择处理：从可解放的「花札卫」怪兽中选1只作为解放素材，将其记录到效果标签中，并向玩家发出解放选择提示。
function c21772453.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家可解放的怪兽组（非上级召唤用），再筛出满足hspfilter条件的「花札卫」怪兽作为候选（不含自身）。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c21772453.hspfilter,nil,tp)
	-- 向玩家显示“请选择要解放的卡”的选择提示，消息类型为解放选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的操作：取出效果标签中选定的解放素材，并执行解放操作，完成特殊召唤的召唤手续。
function c21772453.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为理由解放之前选定的「花札卫」怪兽，作为该卡的这次特殊召唤所需cost。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ①效果的发动条件设定：在特殊召唤成功时发动，登记目标玩家为自己、抽卡数量为1，并设置操作为抽卡类别。
function c21772453.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为效果发动者自己，表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1，即抽取的卡数为1张。
	Duel.SetTargetParam(1)
	-- 登记本次连锁将进行抽卡操作，category为CATEGORY_DRAW，玩家为自己，预计抽卡数量为1，用于效果发动后的时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤函数，判断卡片是否为魔法·陷阱卡，用于后续选择要破坏的对方场上卡片。
function c21772453.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的处理：按设定抽取1张卡并向对方确认，若抽到的是「花札卫」怪兽则询问是否破坏对方场上1张魔法·陷阱卡；若是其他卡则将其送去墓地；最后洗切手卡。
function c21772453.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前登记的目标玩家和参数，即抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定的抽卡玩家抽取对应数量的卡，若实际抽卡成功（返回非0）则继续后续处理。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 获取刚才抽卡操作实际操作的卡片组，并取其中第一张，即抽到的那张卡。
		local tc=Duel.GetOperatedGroup():GetFirst()
		-- 将抽到的卡展示给对方玩家确认，实现“给双方确认”的效果。
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
			-- 获取对方场上的所有魔法·陷阱卡，作为可能被破坏的对象集合。
			local g=Duel.GetMatchingGroup(c21772453.desfilter,tp,0,LOCATION_ONFIELD,nil)
			-- 当对方场上有魔法·陷阱卡时，询问玩家是否选择破坏其中1张，只有选择“是”才继续执行破坏。
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(21772453,1)) then  --"是否选对方场上1张魔法·陷阱卡破坏？"
				-- 中断当前效果处理，使后续的破坏操作作为独立效果处理，避免因连续操作导致错过时点。
				Duel.BreakEffect()
				local sg=g:Select(tp,1,1,nil)
				-- 手动展示被选定为破坏对象的卡，并记录该卡被选为对象（广义）。
				Duel.HintSelection(sg)
				-- 以效果原因破坏选定的那张魔法·陷阱卡。
				Duel.Destroy(sg,REASON_EFFECT)
			end
		else
			-- 中断当前效果处理，使后续送墓操作独立处理，避免时点错乱。
			Duel.BreakEffect()
			-- 将抽到的不是「花札卫」怪兽的卡以效果原因送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
		-- 抽卡并确认后洗切手卡，使手卡顺序重新随机（以符合规则要求）。
		Duel.ShuffleHand(tp)
	end
end
