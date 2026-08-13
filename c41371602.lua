--スタンドアップ・センチュリオン！
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有「百夫长骑士」怪兽卡存在，这张卡不会被对方的效果破坏。
-- ②：这张卡发动的回合的自己主要阶段，把1张手卡送去墓地才能发动。从卡组把1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ③：怪兽特殊召唤的场合才能发动。用包含「百夫长骑士」怪兽的自己场上的怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 初始化入口：依次创建并注册4个效果——e0为卡的发动（仅记录发动标记的代价），e1为①的破坏免疫，e2为②的从卡组放置百夫长骑士，e3为③的特殊召唤时同调召唤；全部注册给这张卡。
function s.initial_effect(c)
	-- 对应②效果原文中的‘这张卡发动的回合’：e0在发动时通过s.reg给这张卡记录‘本回合已发动’的标记，供②使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCost(s.reg)
	c:RegisterEffect(e0)
	-- ①：只要自己场上有「百夫长骑士」怪兽卡存在，这张卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.con)
	-- 将①的免疫判定值设为aux.indoval：当破坏该卡的效果的控制者为这张卡控制者的对手时返回true，从而实现‘不会被对方的效果破坏’的抗性。
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ②：这张卡发动的回合的自己主要阶段，把1张手卡送去墓地才能发动。从卡组把1只「百夫长骑士」怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：怪兽特殊召唤的场合才能发动。用包含「百夫长骑士」怪兽的自己场上的怪兽为素材进行同调召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"同调召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.sccon)
	e3:SetTarget(s.sctg)
	e3:SetOperation(s.scop)
	c:RegisterEffect(e3)
end
-- 发动时的代价函数：chk阶段直接可行；实际发动时在该卡上注册id标记（持续到结束阶段，带誓约标志），记录‘这张卡已经发动过’，从而限制②只能在发动回合使用。
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①的过滤条件：卡片表侧表示、属于「百夫长骑士」字段、原始类型为怪兽；因此被当作永续陷阱放置在魔陷区的百夫长骑士怪兽卡也能满足‘怪兽卡存在’。
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a2) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- ①的适用条件：以该卡控制者为视角，检查其场上是否存在至少1张满足s.confilter的「百夫长骑士」怪兽卡。
function s.con(e)
	local tp=e:GetHandlerPlayer()
	-- 用Duel.IsExistingMatchingCard在己方场上（怪兽区+魔陷区）检索是否存在至少1张符合条件的「百夫长骑士」怪兽卡，存在则返回true。
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②的发动条件：检查这张卡是否带有s.reg设置的id标记，即确认它是在‘这张卡发动的回合’中。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- ②的代价逻辑：先确认手牌有可送墓的卡；实际发动时从手卡选1张以REASON_COST丢弃去墓地。
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查分支：返回手牌中是否存在至少1张能够作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：让玩家从手牌丢弃1张卡到墓地（代价送去墓地）。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- ②检索/放置的卡片过滤：属于「百夫长骑士」字段、是怪兽卡、且不是禁止卡。
function s.filter(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ②发动目标的合法性检查：卡组存在符合s.filter的「百夫长骑士」怪兽，且己方魔陷区有空格可以放置。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查分支：确认卡组中至少有1张符合条件的「百夫长骑士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		-- 同时确认己方魔法与陷阱区域有空位；两者都满足才可发动。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- ②的处理阶段：确认魔陷区仍有空格；提示选卡，从卡组选1张符合条件的百夫长骑士怪兽；将其表侧放置到己方魔陷区，并立即通过类型变更效果让它成为永续陷阱卡。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次检查魔陷区空格，若已被占满则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 显示‘请选择要放置到场上的卡’的选卡提示（HINTMSG_TOFIELD）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组选择恰好1张满足s.filter的卡片。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡移动到己方魔法与陷阱区域，表侧表示，enable=true表示放置后立即适用于其效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 对应②效果原文中的‘当作永续陷阱卡使用’部分：用EFFECT_CHANGE_TYPE把该卡变为永续陷阱卡，且不能被无效，并在通常离场/重置条件下失效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- ③的诱发事件过滤：检查特殊召唤成功的怪兽是否为表侧表示。
function s.scconfilter(c,tp)
	return c:IsFaceup()
end
-- ③的触发条件：本次特殊召唤成功的一组怪兽eg中，存在至少1只表侧表示怪兽，即满足‘怪兽特殊召唤的场合’。
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.scconfilter,1,nil,tp)
end
-- 同调素材过滤：素材必须表侧表示、属于「百夫长骑士」字段、且是怪兽卡。
function s.mfilter(c)
	return c:IsSetCard(0x1a2) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 选择同调素材组时的合法性判定：该组至少包含1只百夫长骑士怪兽；满足手牌与场上混合同调规则；目标同调怪兽能以这组素材合法同调召唤。
function s.syncheck(g,tp,syncard)
	-- 返回条件：g中存在百夫长骑士素材，且aux.SynMixHandCheck通过，且syncard:IsSynchroSummonable确认可以用g作为素材进行同调召唤。
	return g:IsExists(s.mfilter,1,nil) and aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 从额外卡组筛选可同调召唤的同调怪兽：必须为同调怪兽；临时安装等级和辅助函数后，用mg:CheckSubGroup检查素材池中是否存在至少2张卡组成合法同调素材组，随后清除辅助函数。
function s.scfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 为后续素材子组搜索临时安装一个计算目标同调怪兽c等级条件的辅助函数，以便正确判断同调素材的等级和。
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(s.syncheck,2,#mg,tp,c)
	-- CheckSubGroup结束后立即清除临时辅助函数，防止残留影响后续其他判定。
	aux.GCheckAdditional=nil
	return res
end
-- ③的发动目标阶段：确认玩家能进行特殊召唤；获取可用素材池（场上，若有手牌同调则并入所有手牌）；检查额外卡组是否存在能用该素材池合法同调的同调怪兽；发动时向对方明示选择③效果，并登记操作信息为特殊召唤。
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 若当前玩家被禁止进行特殊召唤（如受到特殊召唤限制效果），则③不能发动。
		if not Duel.IsPlayerCanSpecialSummon(tp) then return false end
		-- 取得当前己方场上可作为同调素材的怪兽集合。
		local mg=Duel.GetSynchroMaterial(tp)
		if mg:IsExists(Card.GetHandSynchro,1,nil) then
			-- 取得己方手牌中的全部卡，作为存在手牌同调能力时的额外素材池。
			local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
			if mg2:GetCount()>0 then mg:Merge(mg2) end
		end
		-- 检查额外卡组中是否存在至少1只同调怪兽，能用素材池mg中的某个合法子组满足③的同调召唤条件。
		return Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
	end
	-- 向对方玩家发送提示，告知己方选择了③的‘同调召唤’效果（显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将当前连锁的操作信息登记为从额外卡组特殊召唤1只怪兽（素材在解决时确定，因此targets为nil），用于相关响应或限制判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③的解决处理：重新获取素材池；筛选全场可同调的额外同调怪兽；玩家选择要同调召唤的怪兽和素材组；最后执行同调召唤。
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时重新取得当前可用的同调素材怪兽组。
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 解决阶段若素材池中存在手牌同调特权怪兽，则把整副手牌并入素材池。
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	-- 从额外卡组中筛出所有能以当前素材池按③规则合法同调召唤的同调怪兽。
	local g=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,tp,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要同调召唤的怪兽（HINTMSG_SPSUMMON，请选择要特殊召唤的卡）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 提示玩家选择用来同调召唤的素材组（HINTMSG_SMATERIAL，请选择要作为同调素材的卡）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
		local tg=mg:SelectSubGroup(tp,s.syncheck,false,2,#mg,tp,sc)
		-- 执行同调召唤：用选中的素材组tg将同调怪兽sc同调召唤；#tg-1指定素材组中除1只调整外其余非调整素材的数量必须恰好为#tg-1，确保同调素材构成合法。
		Duel.SynchroSummon(tp,sc,nil,tg,#tg-1,#tg-1)
	end
end
