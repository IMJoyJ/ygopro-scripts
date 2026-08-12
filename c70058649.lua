--道化の一座『怪演』
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
-- ●从卡组·额外卡组把最多2只「道化一座」怪兽无视召唤条件特殊召唤。
-- ●从卡组把1只「道化一座」怪兽加入手卡。
-- ②：自己·对方的主要阶段，把墓地的这张卡除外才能发动。表侧表示进行1只「道化一座」怪兽的上级召唤。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把墓地的这张卡除外才能发动。表侧表示进行1只「道化一座」怪兽的上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"上级召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(s.sumcon)
	-- 把墓地的这张卡除外作为效果发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
-- 过滤可以特殊召唤的「道化一座」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
		-- 如果怪兽在卡组，检查自己场上的主怪兽区是否有空格
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 如果怪兽在额外卡组，检查能让额外卡组怪兽出场的空格数是否大于0
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 过滤可以从卡组加入手牌的「道化一座」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动检测与效果选择处理
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在可以特殊召唤的「道化一座」怪兽
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
		-- 检查本回合是否尚未选择过特殊召唤效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查卡组是否存在可以加入手牌的「道化一座」怪兽
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查本回合是否尚未选择过检索效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 提供特殊召唤与加入手牌两个选项供玩家选择
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"特殊召唤"
			{b2,aux.Stringid(id,3),2})  --"加入手卡"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 注册本回合已选择特殊召唤效果的玩家标记
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置效果处理时无视条件特殊召唤卡组·额外卡组怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
			-- 注册本回合已选择检索效果的玩家标记
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置效果处理时将卡组怪兽加入手牌的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 过滤额外卡组里里侧表示的融合、同调、超量怪兽
function s.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤额外卡组里连接怪兽或表侧表示的灵摆怪兽
function s.exfilter3(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
-- 进行特殊召唤多个怪兽时的数量与区域空格合法性检查
function s.gcheck(g,ft1,ft2,ft3,ect,ft)
	return #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=ft1
		and g:FilterCount(s.exfilter2,nil)<=ft2
		and g:FilterCount(s.exfilter3,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- 效果①的效果处理（特殊召唤、检索或限制效果注册）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取自己场上可用的主怪兽区空格数
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取额外卡组中融合·同调·超量怪兽的可用空格数
		local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
		-- 获取额外卡组中灵摆·连接怪兽的可用空格数
		local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
		-- 获取自己可用的怪兽区总空格数
		local ft=Duel.GetUsableMZoneCount(tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then
			if ft1>0 then ft1=1 end
			if ft2>0 then ft2=1 end
			if ft3>0 then ft3=1 end
			ft=1
		end
		-- 获取受其他卡片效果限制下的额外怪兽特殊召唤最大可用数
		local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
		local loc=0
		if ft1>0 then loc=loc+LOCATION_DECK end
		if ect>0 and (ft2>0 or ft3>0) then loc=loc+LOCATION_EXTRA end
		if loc==0 then return end
		-- 获取卡组及额外卡组中所有符合特殊召唤条件的怪兽
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,loc,0,nil,e,tp)
		if sg:GetCount()==0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local rg=sg:SelectSubGroup(tp,s.gcheck,false,1,2,ft1,ft2,ft3,ect,ft)
		-- 将选取的怪兽无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(rg,0,tp,tp,true,false,POS_FACEUP)
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择1张符合检索条件的「道化一座」怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽因效果加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。/②：自己·对方的主要阶段，把墓地的这张卡除外才能发动。表侧表示进行1只「道化一座」怪兽的上级召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册不能把从卡组·额外卡组特殊召唤的怪兽的效果发动的限制效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果判定：限制从卡组或额外卡组特殊召唤的场上怪兽的效果发动
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE) and rc:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 判断是否在双方的主要阶段进行上级召唤
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 过滤手牌中可以进行上级召唤的「道化一座」怪兽
function s.sumfilter(c)
	return c:IsSetCard(0x1dc) and c:IsSummonable(true,nil,1)
end
-- 效果②的发动检测与效果目标声明
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否存在可以上级召唤的「道化一座」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果处理时召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的效果处理：在对方/自己回合主要阶段召唤手牌中的「道化一座」怪兽
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择手牌中1只可以进行通常召唤的「道化一座」怪兽
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 以表侧表示进行怪兽的上级召唤
		Duel.Summon(tp,tc,true,nil,1)
	end
end
