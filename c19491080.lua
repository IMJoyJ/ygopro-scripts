--道化の一座 ハット
-- 效果：
-- ←7 【灵摆】 7→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从卡组把灵摆怪兽以外的1张「道化一座」卡送去墓地，这张卡特殊召唤。这个效果的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
-- 【怪兽效果】
-- ①：只要上级召唤的怪兽在自己场上存在，对方场上的怪兽的守备力下降1500。
-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●双方的额外卡组（表侧）·场上的灵摆怪兽全部回到卡组。
-- ●从卡组·额外卡组把灵摆怪兽以外的1只「道化一座」怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 注册这张卡的灵摆效果和全部怪兽效果
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。从卡组把灵摆怪兽以外的1张「道化一座」卡送去墓地，这张卡特殊召唤。这个效果的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ①：只要上级召唤的怪兽在自己场上存在，对方场上的怪兽的守备力下降1500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.adcon)
	e2:SetValue(-1500)
	c:RegisterEffect(e2)
	-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"选择效果"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 过滤器：灵摆怪兽以外的「道化一座」卡，且可以送去墓地
function s.tgfilter(c)
	return not c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1dc) and c:IsAbleToGrave()
end
-- 灵摆效果的发动条件：自己怪兽区有空位、这张卡可以特殊召唤、且卡组存在满足条件的卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可使用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组是否存在至少1张满足条件（灵摆怪兽以外的「道化一座」卡）的卡
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：这张卡将被特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：将从卡组把1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张满足条件的卡送去墓地，成功后把这张卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张灵摆怪兽以外的「道化一座」卡
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=tg:GetFirst()
	-- 把选择的卡送去墓地，确认成功送入墓地且这张卡仍与连锁关联
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToChain() then
		-- 把这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 把这个发动限制效果注册给自己玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制内容：不能发动从卡组·额外卡组特殊召唤的怪兽的效果
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE) and rc:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 过滤器：上级召唤的怪兽
function s.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 降守备力效果的适用条件：自己场上存在上级召唤的怪兽
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1只上级召唤的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤器：表侧的灵摆怪兽，且可以回到卡组
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
-- 过滤器：卡组·额外卡组中灵摆怪兽以外的「道化一座」怪兽，无视召唤条件可以特殊召唤，且有可用空格
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_PENDULUM)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
		-- 若在卡组则需自己怪兽区有可用的空格
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若在额外卡组则需有能让额外卡组怪兽出场的空格
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 解放诱发效果的目标选择：判断两个选项哪个可用，让玩家选择发动哪个效果并设置对应的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 选项1条件：双方的额外卡组（表侧）·场上存在可回到卡组的灵摆怪兽
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,LOCATION_EXTRA+LOCATION_MZONE,1,nil)
		-- 且这个回卡组效果本回合还未被选择过（同名效果1回合1次）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 选项2条件：卡组·额外卡组存在可无视召唤条件特殊召唤的「道化一座」怪兽
	local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
		-- 且这个特殊召唤效果本回合还未被选择过（同名效果1回合1次）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从可用选项中选择要发动的效果
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"回到卡组"
			{b2,aux.Stringid(id,3),2})  --"特殊召唤"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK)
			-- 注册标识效果，标记回卡组效果本回合已被选择
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 取得双方的额外卡组（表侧）·场上全部满足条件的灵摆怪兽
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,LOCATION_EXTRA+LOCATION_MZONE,nil)
		-- 设置操作信息：这些灵摆怪兽将全部回到卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_EXTRA+LOCATION_MZONE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 注册标识效果，标记特殊召唤效果本回合已被选择
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：将从卡组·额外卡组把1只怪兽特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
	end
end
-- 效果处理：根据所选选项，把双方的额外卡组（表侧）·场上的灵摆怪兽全部回到卡组，或从卡组·额外卡组把1只「道化一座」怪兽特殊召唤
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 取得双方的额外卡组（表侧）·场上全部满足条件的灵摆怪兽
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,LOCATION_EXTRA+LOCATION_MZONE,nil)
		-- 把这些灵摆怪兽全部回到卡组并洗切卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组·额外卡组选择1只满足条件的「道化一座」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 把选择的怪兽无视召唤条件以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
