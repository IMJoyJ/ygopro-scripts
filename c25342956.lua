--ジェムナイトマスター・ダイヤ－ディスパージョン
-- 效果：
-- 「宝石」怪兽×3
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把场上的这张卡送去墓地才能发动。从自己的额外卡组·墓地把最多3只岩石族以外的「宝石」怪兽无视召唤条件特殊召唤（同名卡最多1张）。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己的「宝石骑士」融合怪兽被战斗破坏时才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数：为卡片添加融合召唤条件、苏生限制，并注册①的诱发即时效果和②的墓地诱发效果。
function s.initial_effect(c)
	-- 添加融合召唤手续：将3只满足「宝石」字段的怪兽作为融合素材，允许此卡通过融合召唤出场。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x47),3,true)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段，把场上的这张卡送去墓地才能发动。从自己的额外卡组·墓地把最多3只岩石族以外的「宝石」怪兽无视召唤条件特殊召唤（同名卡最多1张）。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的「宝石骑士」融合怪兽被战斗破坏时才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：仅限自己·对方的主要阶段才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段，以满足①的发动时点要求。
	return Duel.IsMainPhase()
end
-- 效果①的发动代价处理：检查能否将场上的这张卡作为代价送去墓地，并执行送墓。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把这张卡以代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义①可特殊召唤的卡：岩石族以外的「宝石」怪兽，能够无视召唤条件特殊召唤，且按所在位置（墓地/额外）检查区域空格。
function s.spfilter1(c,e,tp,ec)
	return c:IsSetCard(0x47) and not c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 若候选卡在墓地，则需要该卡离开墓地后我方主要怪兽区仍有空位，才能被选择。
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp,c)>0
		-- 若候选卡在额外卡组，则需要考虑这张卡自身离场后，从额外卡组特殊召唤它所需的空格仍足够。
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0)
end
-- 效果①发动时的目标筛选与合法性确认：在召唤之门限制（若有）允许且有合法对象的情况下才能发动，并登记特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取“召唤之门”效果对额外卡组特殊召唤次数的剩余限制；若未生效则为nil。
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	-- 检查发动合法性：若存在召唤之门限制则剩余次数须大于0，且我方墓地/额外卡组存在至少1只符合条件的「宝石」怪兽。
	if chk==0 then return (not ect or ect>0) and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 登记本效果将进行特殊召唤，预计从墓地·额外卡组特殊召唤1只以上怪兽，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 定义效果处理时可选怪兽的基本条件：岩石族以外的「宝石」怪兽且能无视召唤条件特殊召唤。
function s.spfilter2(c,e,tp)
	if not (c:IsSetCard(0x47) and not c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 对于在额外卡组的候选卡，确认有可用的额外怪兽区/连接区空格可供其特殊召唤。
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 对于在墓地的候选卡，确认我方主要怪兽区有空位可特殊召唤。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
-- 筛选额外卡组中里侧表示的融合·同调·超量怪兽（这类怪兽通常需要额外的额外怪兽区才能出场）。
function s.exfilter1(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 筛选额外卡组中的连接怪兽或表侧表示的灵摆怪兽（这类怪兽可特殊召唤到主要怪兽区）。
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
-- 验证所选怪兽组：卡名互不相同、总数量不超过可用怪兽区总数，并按墓地、需额外区的融合·同调·超量、可进主区的连接/灵摆分类分别检查空格。
function s.gcheck(g,ft1,ft2,ft3,ect,ft)
	-- 确认所选怪兽卡名互不相同，且总数不超过当前可用怪兽区总数。
	return aux.dncheck(g) and #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=ft1
		and g:FilterCount(s.exfilter1,nil)<=ft2
		and g:FilterCount(s.exfilter2,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- 效果①处理流程：根据可用格子确定可选卡片来源，选择最多3只满足条件且卡名不同的「宝石」怪兽，分步特殊召唤，最后附加额外卡组只能特殊召唤融合怪兽的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方主要怪兽区可用空格数，用于限制从墓地特殊召唤的数量。
	local eft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取可容纳融合·同调·超量怪兽的额外怪兽区空格数，限制从额外卡组特殊召唤这类怪兽的数量。
	local eft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	-- 获取可容纳连接/灵摆怪兽的区域空格数，限制从额外卡组特殊召唤这类怪兽的数量。
	local eft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	-- 获取我方场上所有怪兽区域可用总格数，作为特殊召唤总数上限。
	local ft=Duel.GetUsableMZoneCount(tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if eft1>0 then eft1=1 end
		if eft2>0 then eft2=1 end
		if eft3>0 then eft3=1 end
		ft=1
	end
	-- 若召唤之门效果适用，则用其记录的额外卡组特殊召唤剩余次数作为额外怪兽数量上限；否则以可用怪兽区总格数ft代替。
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local loc=0
	if eft1>0 then loc=loc+LOCATION_GRAVE end
	if ect>0 and (eft2>0 or eft3>0) then loc=loc+LOCATION_EXTRA end
	if loc~=0 then
		-- 从可选区域中取得所有满足条件且不受王家长眠之谷影响的「宝石」怪兽集合。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter2),tp,loc,0,nil,e,tp)
		if g:GetCount()>0 then
			-- 提示玩家进入选择要特殊召唤的卡片界面。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:SelectSubGroup(tp,s.gcheck,false,1,3,eft1,eft2,eft3,ect,ft)
			if sg then
				local exg1=sg:Filter(s.exfilter2,nil)
				sg:Sub(exg1)
				if exg1:GetCount()>0 then
					-- 遍历选中的可进主要怪兽区的额外怪兽（连接/表侧灵摆），准备逐步特殊召唤。
					for tc in aux.Next(exg1) do
						-- 将当前连接/表侧灵摆怪兽以表侧攻击表示特殊召唤，无视召唤条件与苏生限制。
						Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
					end
				end
				local exg2=sg:Filter(s.exfilter1,nil)
				sg:Sub(exg2)
				if exg2:GetCount()>0 then
					-- 遍历选中的里侧表示融合·同调·超量怪兽，准备逐步特殊召唤。
					for tc in aux.Next(exg2) do
						-- 将当前融合·同调·超量怪兽以表侧攻击表示特殊召唤，无视召唤条件与苏生限制。
						Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
					end
				end
				if sg:GetCount()>0 then
					-- 遍历剩余选中的墓地怪兽，准备逐步特殊召唤。
					for tc in aux.Next(sg) do
						-- 将当前墓地怪兽以表侧攻击表示特殊召唤，无视召唤条件与苏生限制。
						Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
					end
				end
				-- 完成所有特殊召唤步骤，批量特殊召唤成功。
				Duel.SpecialSummonComplete()
			end
		end
	end
	-- ①的自肃：这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。②：这张卡在墓地存在的状态，自己的「宝石骑士」融合怪兽被战斗破坏时才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“自己不是融合怪兽不能从额外卡组特殊召唤”的永续效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃限制的判定：从额外卡组特殊召唤的怪兽若不为融合怪兽，则不能特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 定义被战斗破坏怪兽的筛选条件：是「宝石骑士」融合怪兽，破坏前由我方控制，且拥有「宝石骑士」字段。
function s.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsPreviousControler(tp)
		and c:IsPreviousSetCard(0x1047)
		and c:IsSetCard(0x1047)
end
-- ②的发动条件：本次被战斗破坏的怪兽中存在至少1只满足筛选条件的「宝石骑士」融合怪兽（且不是这张卡自身）。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
-- ②发动时的目标检查：确认这张卡在墓地且能被特殊召唤，并且我方有可用怪兽区。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查我方主要怪兽区是否有空位，以确保可以特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本效果将特殊召唤这张卡的对象信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②的效果处理：若这张卡仍与效果关联且不受王家长眠之谷影响，则将其特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡未被移动导致与效果失联，且从墓地特殊召唤不会被王家长眠之谷无效/禁止。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡以表侧攻击表示特殊召唤到我方主要怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
