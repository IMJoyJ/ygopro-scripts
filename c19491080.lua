--道化の一座 ハット
local s,id,o=GetID()
-- 初始化效果，为卡片添加灵摆属性并注册三个效果
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性
	aux.EnablePendulumAttribute(c)
	-- ①这张卡在灵摆区域存在，以自己·对方的准备阶段为对象发动。将自己墓地存在的1只「道化」怪兽特殊召唤。此外，从自己的手卡·卡组将1张「道化」魔法·陷阱卡送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②这张卡在场上存在，以自己场上1只名字带有「道化」的怪兽为对象发动。那只怪兽的守备力下降1500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.adcon)
	e2:SetValue(-1500)
	c:RegisterEffect(e2)
	-- ③这张卡被解放的场合才能发动。从以下效果选择1个发动。①将自己额外卡组·场上的1张灵摆卡回到卡组最下面（洗牌）。②从自己卡组·额外卡组选择1只「道化」怪兽特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的卡片组，用于特殊召唤
function s.tgfilter(c)
	return not c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x1dc) and c:IsAbleToGrave()
end
-- 判断是否可以发动效果，检查是否有足够的怪兽区和可送去墓地的卡片
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手牌或卡组中是否存在符合条件的卡片
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，指定将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息，指定将要送去墓地的卡片
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤和送墓地的操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡片组
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=tg:GetFirst()
	-- 检查卡片是否成功送去墓地并处于墓地状态
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToChain() then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 注册一个效果，使对方不能发动魔法·陷阱·怪兽效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否能无效化对方的效果
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE) and rc:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 检查场上是否存在名字带有「.advance」的怪兽
function s.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 判断是否满足条件，检查是否有符合条件的怪兽在场
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在名字带有「advance」的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 检索满足条件的灵摆卡组，用于送回卡组
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeck()
end
-- 检索满足条件的怪兽组，用于特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_PENDULUM)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
		-- 检查是否在卡组且有可用怪兽区
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 检查是否在额外卡组且有可用区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果处理函数，选择操作选项并设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在符合条件的灵摆卡
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,LOCATION_EXTRA+LOCATION_MZONE,1,nil)
		-- 检查是否已使用过该效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查是否存在符合条件的怪兽
	local b2=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
		-- 检查是否已使用过该效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 选择操作选项
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK)
			-- 注册标识效果，防止再次发动
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 获取满足条件的灵摆卡组
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,LOCATION_EXTRA+LOCATION_MZONE,nil)
		-- 设置操作信息，指定将要送回卡组的卡片
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_EXTRA+LOCATION_MZONE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 注册标识效果，防止再次发动
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息，指定将要特殊召唤的卡片
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
	end
end
-- 效果处理函数，根据选择执行相应操作
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 获取满足条件的灵摆卡组
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_EXTRA+LOCATION_MZONE,LOCATION_EXTRA+LOCATION_MZONE,nil)
		-- 将卡片送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽组
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将卡片特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
