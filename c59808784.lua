--炎帝家臣ベルリネス
-- 效果：
-- 「炎帝家臣 贝利尼斯」的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。这张卡从手卡特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
-- ②：这张卡为上级召唤而被解放的场合才能发动。把对方手卡确认，从那之中选1张卡直到结束阶段除外。
function c59808784.initial_effect(c)
	-- 「炎帝家臣 贝利尼斯」的①的效果：丢弃1张手卡才能发动。这张卡从手卡特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,59808784)
	e1:SetCost(c59808784.spcost)
	e1:SetTarget(c59808784.sptg)
	e1:SetOperation(c59808784.spop)
	c:RegisterEffect(e1)
	-- 「炎帝家臣 贝利尼斯」的②的效果：这张卡为上级召唤而被解放的场合才能发动。把对方手卡确认，从那之中选1张卡直到结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,59808785)
	e2:SetCondition(c59808784.rmcon)
	e2:SetTarget(c59808784.rmtg)
	e2:SetOperation(c59808784.rmop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价（Cost）函数：丢弃手卡
function c59808784.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身以外可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①号效果的发动准备（Target）函数：检查怪兽区域空格及自身是否能特殊召唤
function c59808784.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的效果处理（Operation）函数：注册额外卡组特召限制并特殊召唤自身
function c59808784.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c59808784.splimit)
	-- 注册“不能从额外卡组特殊召唤怪兽”的玩家效果
	Duel.RegisterEffect(e1,tp)
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 限制特殊召唤的怪兽来源为额外卡组
function c59808784.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 检查这张卡是否因上级召唤而被解放
function c59808784.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_SUMMON)
end
-- ②号效果的发动准备（Target）函数：检查对方手卡并设置除外操作信息
function c59808784.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 设置除外对方手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- ②号效果的效果处理（Operation）函数：确认对方手卡并选择1张除外，注册结束阶段归还的效果
function c59808784.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的所有手卡
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 让己方玩家确认对方的所有手卡
	Duel.ConfirmCards(tp,hg)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g=hg:Select(tp,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的卡片除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	-- 洗切对方的手卡
	Duel.ShuffleHand(1-tp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 直到结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(c59808784.retcon)
	e1:SetOperation(c59808784.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在结束阶段将除外卡片送回手卡的延迟效果
	Duel.RegisterEffect(e1,tp)
	tc:RegisterFlagEffect(59808784,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
end
-- 检查被除外的卡片是否仍带有对应的标记
function c59808784.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(59808784)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段将除外的卡片送回手卡
function c59808784.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将被除外的卡片送回持有者的手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
