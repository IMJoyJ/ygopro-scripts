--ゴーティスの朧キーフ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：场上有鱼族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：对方场上有怪兽特殊召唤的场合，以那之内的1只怪兽和自己的除外状态的1只6星以下的鱼族怪兽为对象才能发动。作为对象的对方怪兽和这张卡除外，作为对象的自己怪兽特殊召唤。
-- ③：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册手牌特召、响应对方特召双除外并特召自身除外怪兽，以及被除外后下个回合准备阶段特召的效果
function s.initial_effect(c)
	-- ①：场上有鱼族怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上有怪兽特殊召唤的场合，以那之内的1只怪兽和自己的除外状态的1只6星以下的鱼族怪兽为对象才能发动。作为对象的对方怪兽和这张卡除外，作为对象的自己怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外对方怪兽"
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_REMOVE)
	e3:SetOperation(s.spreg)
	c:RegisterEffect(e3)
	-- ③：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"除外对方怪兽"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon1)
	e4:SetTarget(s.sptg1)
	e4:SetOperation(s.spop1)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 过滤场上的表侧表示鱼族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end
-- 效果①的发动条件判定
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的鱼族怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果①的目标判定及操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身从手卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤除外区中等级6以下的表侧表示鱼族怪兽
function s.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(6) and c:IsRace(RACE_FISH)
end
-- 过滤对方场上本次特殊召唤的可除外且可作为对象的怪兽
function s.rmfilter(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
-- 效果②的发动条件判定：对方场上有怪兽特殊召唤
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 效果②的目标判定、取对象及操作信息设置
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.rmfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	local c=e:GetHandler()
	-- 检查对方是否有符合特召怪兽、自身可除外且有可用怪兽格
	if chk==0 then return #g>0 and c:IsAbleToRemove() and Duel.GetMZoneCount(tp,c)>0
		-- 检查除外区是否存在6星以下鱼族怪兽
		and Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	local tg=g:Clone()
	if #g>1 then
		-- 提示选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		tg=g:Select(tp,1,1,nil)
	end
	-- 将选中的对方怪兽和自身设置为除外对象卡
	Duel.SetTargetCard(tg)
	tg:AddCard(c)
	-- 设置操作信息：将对方怪兽和自身除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,#tg,0,0)
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己除外区1只6星以下的鱼族怪兽作为对象
	local g2=Duel.SelectTarget(tp,s.spfilter1,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤选中的自己怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
-- 效果处理：将作为对象的对方怪兽和自身除外，将作为对象的自己怪兽特殊召唤
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取除外操作的目标卡片组
	local res1,tg1=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	-- 获取特殊召唤操作的目标卡片组
	local res2,tg2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local c=e:GetHandler()
	-- 获取除外目标中的对方怪兽
	local rc=tg1:Filter(aux.TRUE,c):GetFirst()
	local sc=tg2:GetFirst()
	if rc:IsRelateToEffect(e) and rc:IsControler(1-tp) and rc:IsAbleToRemove()
		and c:IsRelateToEffect(e) and c:IsAbleToRemove() then
		local rg=Group.FromCards(c,rc)
		-- 若对方怪兽与自身成功除外2张且特召对象仍有效
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==2 and sc:IsRelateToEffect(e) then
			-- 将作为对象的自己怪兽特殊召唤
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 自身被除外时记录当前回合数并注册2回合标记
function s.spreg(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合数
	local ct=Duel.GetTurnCount()
	e:SetLabel(ct)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end
-- 效果③的发动条件判定
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 确认已到达被除外的下个回合且标记有效
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(id)>0
end
-- 效果③的目标判定及操作信息设置
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将除外状态的自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将除外状态的这张卡特殊召唤
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
