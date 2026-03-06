--ジェムナイトマスター・ダイヤ－ディスパージョン
-- 效果：
-- 「宝石」怪兽×3
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把场上的这张卡送去墓地才能发动。从自己的额外卡组·墓地把最多3只岩石族以外的「宝石」怪兽无视召唤条件特殊召唤（同名卡最多1张）。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己的「宝石骑士」融合怪兽被战斗破坏时才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件并注册两个效果
function s.initial_effect(c)
	-- 设置此卡为需要3个「宝石」融合素材的融合怪兽
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
-- 效果①的发动条件：当前为自己的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前为自己的主要阶段
	return Duel.IsMainPhase()
end
-- 效果①的发动费用：将此卡送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为发动费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选可特殊召唤的「宝石」怪兽（满足种族、类型、召唤条件等）
function s.spfilter1(c,e,tp,ec)
	return c:IsSetCard(0x47) and not c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 若此卡在墓地，则检查是否有可用的怪兽区
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp,c)>0
		-- 若此卡在额外卡组，则检查是否有可用的额外卡组召唤区域
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0)
end
-- 效果①的发动目标：检索满足条件的「宝石」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否受到「王家长眠之谷」影响
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	-- 检查是否存在满足条件的「宝石」怪兽
	if chk==0 then return (not ect or ect>0) and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁操作信息，提示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 筛选可特殊召唤的「宝石」怪兽（满足种族、类型、召唤条件等）
function s.spfilter2(c,e,tp)
	if not (c:IsSetCard(0x47) and not c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 若此卡在额外卡组，则检查是否有可用的额外卡组召唤区域
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 若此卡在墓地，则检查是否有可用的怪兽区
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
-- 筛选额外卡组中需要特殊召唤的融合/同步/XYZ怪兽
function s.exfilter1(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 筛选额外卡组中需要特殊召唤的链接/命阶怪兽
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
-- 筛选满足条件的怪兽组（包括卡名不同、区域限制等）
function s.gcheck(g,ft1,ft2,ft3,ect,ft)
	-- 检查所选怪兽组中是否所有卡名都不同
	return aux.dncheck(g) and #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=ft1
		and g:FilterCount(s.exfilter1,nil)<=ft2
		and g:FilterCount(s.exfilter2,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- 效果①的发动处理：检索并特殊召唤满足条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区数量
	local eft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取玩家额外卡组中可用于融合/同步/XYZ怪兽召唤的区域数量
	local eft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	-- 获取玩家额外卡组中可用于命阶/链接怪兽召唤的区域数量
	local eft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	-- 获取玩家当前可用的怪兽区数量
	local ft=Duel.GetUsableMZoneCount(tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if eft1>0 then eft1=1 end
		if eft2>0 then eft2=1 end
		if eft3>0 then eft3=1 end
		ft=1
	end
	-- 计算实际可用的怪兽区数量（考虑「王家长眠之谷」影响）
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local loc=0
	if eft1>0 then loc=loc+LOCATION_GRAVE end
	if ect>0 and (eft2>0 or eft3>0) then loc=loc+LOCATION_EXTRA end
	if loc~=0 then
		-- 获取满足条件的「宝石」怪兽组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter2),tp,loc,0,nil,e,tp)
		if g:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:SelectSubGroup(tp,s.gcheck,false,1,3,eft1,eft2,eft3,ect,ft)
			if sg:GetCount()>0 then
				local exg1=sg:Filter(s.exfilter2,nil)
				sg:Sub(exg1)
				if exg1:GetCount()>0 then
					-- 遍历并特殊召唤命阶/链接怪兽
					for tc in aux.Next(exg1) do
						-- 特殊召唤命阶/链接怪兽
						Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
					end
				end
				local exg2=sg:Filter(s.exfilter1,nil)
				sg:Sub(exg2)
				if exg2:GetCount()>0 then
					-- 遍历并特殊召唤融合/同步/XYZ怪兽
					for tc in aux.Next(exg2) do
						-- 特殊召唤融合/同步/XYZ怪兽
						Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
					end
				end
				if sg:GetCount()>0 then
					-- 遍历并特殊召唤其他怪兽
					for tc in aux.Next(sg) do
						-- 特殊召唤其他怪兽
						Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
					end
				end
				-- 完成所有特殊召唤步骤
				Duel.SpecialSummonComplete()
			end
		end
	end
	-- 设置效果①发动后，本回合不能从额外卡组特殊召唤非融合怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能从额外卡组特殊召唤非融合怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能从额外卡组特殊召唤非融合怪兽的过滤条件
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 筛选被战斗破坏的「宝石骑士」融合怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsPreviousControler(tp)
		and c:IsPreviousSetCard(0x1047)
		and c:IsSetCard(0x1047)
end
-- 效果②的发动条件：自己的「宝石骑士」融合怪兽被战斗破坏时
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
-- 效果②的发动目标：特殊召唤此卡
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有可用的怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，提示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的发动处理：特殊召唤此卡
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否有效且未受「王家长眠之谷」影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 特殊召唤此卡
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
