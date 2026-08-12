--雨天気ラズラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从手卡选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：场上的这张卡为让「天气」卡的效果发动而被除外的场合，下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
function c92411493.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。从手卡选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92411493,0))  --"从手卡放置「天气」魔法·陷阱卡"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,92411493)
	e1:SetTarget(c92411493.tftg)
	e1:SetOperation(c92411493.tfop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为让「天气」卡的效果发动而被除外的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c92411493.spreg)
	c:RegisterEffect(e2)
	-- 下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92411493,1))  --"除外的这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCondition(c92411493.spcon)
	e3:SetTarget(c92411493.sptg)
	e3:SetOperation(c92411493.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤手牌中可以表侧表示放置到魔陷区的「天气」魔法·陷阱卡（非场地魔法）
function c92411493.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSetCard(0x109)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果①的发动准备与可行性检查
function c92411493.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手牌中是否存在满足放置条件的「天气」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c92411493.tffilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的效果处理（将手牌中的「天气」魔法·陷阱卡表侧表示放置）
function c92411493.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的魔法与陷阱区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从手牌选择1张满足条件的「天气」魔法·陷阱卡
	local tc=Duel.SelectMatchingCard(tp,c92411493.tffilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选择的卡在自己的魔法与陷阱区域表侧表示放置
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 记录因「天气」卡的效果发动而被除外的状态，并注册下个回合准备阶段特召的标记
function c92411493.spreg(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsReason(REASON_COST) and rc:IsSetCard(0x109) and c:IsPreviousLocation(LOCATION_ONFIELD) and re:IsActivated() then
		-- 将效果的Label值设为下个回合的回合数
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(92411493,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 检查当前回合是否为被除外时的下个回合，且卡片带有特召标记
function c92411493.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合数等于记录的下个回合数，且卡片仍持有特召标记
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(92411493)>0
end
-- 准备阶段特殊召唤效果的发动准备与可行性检查
function c92411493.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示该效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(92411493)
end
-- 准备阶段特殊召唤效果的效果处理（将除外的自身特殊召唤）
function c92411493.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将除外的这张卡在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
