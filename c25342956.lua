--ジェムナイトマスター・ダイヤ－ディスパージョン
-- 效果：
-- 「宝石」怪兽×3
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把场上的这张卡送去墓地才能发动。从自己的额外卡组·墓地把最多3只岩石族以外的「宝石」怪兽无视召唤条件特殊召唤（同名卡最多1张）。这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的状态，自己的「宝石骑士」融合怪兽被战斗破坏时才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果与融合手续
function s.initial_effect(c)
	-- 设置融合素材为「宝石」怪兽3只
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
-- 效果①的发动条件：自己·对方的主要阶段
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主阶段
	return Duel.IsMainPhase()
end
-- 效果①的发动代价：把场上的自身送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤墓地或额外卡组中岩石族以外且可特殊召唤的「宝石」怪兽
function s.spfilter1(c,e,tp,ec)
	return c:IsSetCard(0x47) and not c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 检查墓地怪兽且主要怪兽区域有空位
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp,c)>0
		-- 检查额外卡组怪兽且额外怪兽区域或连接端有空位
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0)
end
-- 效果①的目标设置：确认额外卡组限制与存在可特殊召唤的怪兽，并声明特殊召唤操作
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取受【召唤之门】影响下的额外卡组剩余特殊召唤次数
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	-- 检查是否可以从额外卡组特殊召唤且墓地或额外卡组存在符合条件的怪兽
	if chk==0 then return (not ect or ect>0) and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置操作信息：从自己的额外卡组·墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 过滤墓地或额外卡组中岩石族以外且可在对应区域特殊召唤的「宝石」怪兽
function s.spfilter2(c,e,tp)
	if not (c:IsSetCard(0x47) and not c:IsRace(RACE_ROCK) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查额外卡组怪兽是否有可出场的空格
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 检查主要怪兽区域是否有可用空格
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
-- 过滤额外卡组里侧表示的融合·同调·超量怪兽
function s.exfilter1(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤额外卡组的连接怪兽或表侧表示灵摆怪兽
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
-- 检查所选怪兽组卡名各不相同且未超出各区域格子与额外卡组特殊召唤限制
function s.gcheck(g,ft1,ft2,ft3,ect,ft)
	-- 检查怪兽组卡名各不相同且数量不超过总可用怪兽区域数
	return aux.dncheck(g) and #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=ft1
		and g:FilterCount(s.exfilter1,nil)<=ft2
		and g:FilterCount(s.exfilter2,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- 效果①的操作处理：从额外卡组·墓地特殊召唤最多3只岩石族以外的「宝石」怪兽，随后施加额外卡组特殊召唤限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身主要怪兽区域空位数
	local eft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取可用于里侧额外怪兽特殊召唤的空格数
	local eft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	-- 获取可用于表侧灵摆或连接怪兽特殊召唤的空格数
	local eft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	-- 获取自身可用怪兽区域总数
	local ft=Duel.GetUsableMZoneCount(tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if eft1>0 then eft1=1 end
		if eft2>0 then eft2=1 end
		if eft3>0 then eft3=1 end
		ft=1
	end
	-- 获取受【召唤之门】影响时的额外卡组特殊召唤次数限制
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local loc=0
	if eft1>0 then loc=loc+LOCATION_GRAVE end
	if ect>0 and (eft2>0 or eft3>0) then loc=loc+LOCATION_EXTRA end
	if loc~=0 then
		-- 获取墓地或额外卡组中不受王家长眠之谷影响且符合条件的「宝石」怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter2),tp,loc,0,nil,e,tp)
		if g:GetCount()>0 then
			-- 提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:SelectSubGroup(tp,s.gcheck,false,1,3,eft1,eft2,eft3,ect,ft)
			if sg then
				local exg1=sg:Filter(s.exfilter2,nil)
				sg:Sub(exg1)
				if exg1:GetCount()>0 then
					-- 遍历所选的表侧灵摆或连接怪兽
					for tc in aux.Next(exg1) do
						-- 单步将怪兽表侧表示无视召唤条件特殊召唤
						Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
					end
				end
				local exg2=sg:Filter(s.exfilter1,nil)
				sg:Sub(exg2)
				if exg2:GetCount()>0 then
					-- 遍历所选的里侧额外怪兽
					for tc in aux.Next(exg2) do
						-- 单步将怪兽表侧表示无视召唤条件特殊召唤
						Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
					end
				end
				if sg:GetCount()>0 then
					-- 遍历所选的墓地怪兽
					for tc in aux.Next(sg) do
						-- 单步将怪兽表侧表示无视召唤条件特殊召唤
						Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
					end
				end
				-- 完成所有怪兽的特殊召唤
				Duel.SpecialSummonComplete()
			end
		end
	end
	-- 这个回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册回合结束前不是融合怪兽不能从额外卡组特殊召唤的限制
	Duel.RegisterEffect(e1,tp)
end
-- 过滤额外卡组非融合怪兽（用于额外特殊召唤限制）
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤自己场上被战斗破坏的「宝石骑士」融合怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsPreviousControler(tp)
		and c:IsPreviousSetCard(0x1047)
		and c:IsSetCard(0x1047)
end
-- 效果②的发动条件：自己的「宝石骑士」融合怪兽被战斗破坏
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
-- 效果②的目标设置：确认怪兽区域有空位并声明自身特殊召唤操作
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查主要怪兽区域是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的操作处理：将墓地的自身特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身与效果有联系且不受王家长眠之谷影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
