--道化の一座『極芸』
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组·额外卡组把最多2只「道化一座」怪兽无视召唤条件特殊召唤。这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，把自己的手卡·场上1只怪兽解放，以场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（从卡组·额外卡组无视条件特殊召唤「道化一座」怪兽并增加不能发动特殊召唤怪兽效果的誓约）以及②效果（在自己主要阶段从墓地除外，解放手卡·场上1只怪兽使场上1张卡回到手卡）
function s.initial_effect(c)
	-- ①：从卡组·额外卡组把最多2只「道化一座」怪兽无视召唤条件特殊召唤。这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段，把这个回合没有送去墓地的这张卡从墓地除外，把自己的手卡·场上1只怪兽解放，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 限制发动条件：送去墓地的回合不能发动该效果
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：属于「道化一座」的怪兽，且能被无视召唤条件特殊召唤到主要怪兽区，或在满足额外卡组怪兽出场位置的空位下特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
		-- 如果是在卡组，判断自己场上是否有空余的怪兽区域
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 或者如果是在额外卡组，判断是否有可让其出场的额外怪兽区域或连接端区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ①效果的发动准备：确认卡组或额外卡组中存在可以特殊召唤的符合条件的怪兽，并设置特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组或额外卡组中是否存在至少1只可特殊召唤的符合条件的「道化一座」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：包含从卡组或额外卡组特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤条件：额外卡组里里侧表示的融合、同调或超量怪兽
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤条件：额外卡组中的连接怪兽或表侧表示的灵摆怪兽
function s.exfilter3(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
-- 特殊召唤数量与区域的组合校验函数：确保特殊召唤的怪兽数量不超过空闲怪兽区及额外区位置的限制
function s.gcheck(g,ft1,ft2,ft3,ect,ft)
	return #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=ft1
		and g:FilterCount(s.exfilter2,nil)<=ft2
		and g:FilterCount(s.exfilter3,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- ①效果的执行：检查怪兽区空位（含考虑青眼精灵龙的影响），从卡组·额外卡组选择最多2只「道化一座」怪兽无视召唤条件特殊召唤，之后注册直到下个回合结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上空余的怪兽区数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取可召唤融合/同调/超量怪兽的额外区空位数量
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	-- 获取可召唤灵摆/连接怪兽的额外区空位数量
	local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	-- 获取可用的怪兽区域空格总数
	local ft=Duel.GetUsableMZoneCount(tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft3>0 then ft3=1 end
		ft=1
	end
	-- 根据可能受到的特定效果影响调整额外卡组可召唤数量上限
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local loc=0
	if ft1>0 then loc=loc+LOCATION_DECK end
	if ect>0 and (ft2>0 or ft3>0) then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	-- 获取卡组·额外卡组中符合条件的全部「道化一座」怪兽
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,loc,0,nil,e,tp)
	if sg:GetCount()==0 then return end
	-- 给玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local rg=sg:SelectSubGroup(tp,s.gcheck,false,1,2,ft1,ft2,ft3,ect,ft)
	-- 将选择的怪兽以表侧表示无视召唤条件特殊召唤
	Duel.SpecialSummon(rg,0,tp,tp,true,false,POS_FACEUP)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 在全局注册限制玩家发动特殊召唤怪兽效果的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 不能发动的效果范围校验函数：限制从卡组·额外卡组特殊召唤的怪兽在场上发动效果
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE) and rc:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤条件：非装备此卡的对象、非除外卡自身且能回到手卡的场上的卡
function s.thfilter(c,rc)
	return c:GetEquipTarget()~=rc and c~=rc and c:IsAbleToHand()
end
-- 解放代价过滤条件：除该怪兽自身外，场上还必须存在至少1张能被回到手卡的卡片作为效果的目标对象
function s.cfilter(c,tp)
	-- 检查场上是否存在除该解放怪兽以外的至少1张能被回到手卡的卡片
	return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,c)
end
-- ②效果的发动代价：把墓地的这张卡除外，解放自己手卡·场上的1只怪兽
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价校验：检查自身是否能被除外且自己手卡·场上是否存在能作为代价解放的怪兽
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,nil,tp) end
	-- 将墓地的这张卡除外
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 选择手卡·场上的1只怪兽作为代价解放
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,nil,tp)
	-- 解放所选择的作为代价的怪兽
	Duel.Release(g,REASON_COST)
end
-- ②效果的发动准备：以场上1张卡为对象才能发动，并设置回到手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 判断场上是否存在可以作为对象的能回到手卡的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张能被回到手卡的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：包含将选择的对象卡片送回手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的执行：如果作为对象的卡片仍在场，则将其送回手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将对象卡片送回手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
