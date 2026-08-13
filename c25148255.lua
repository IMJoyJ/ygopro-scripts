--ジャンク・アンカー
-- 效果：
-- 这张卡可以作为「同调士」调整的代替而成为同调素材。
-- ①：1回合1次，丢弃1张手卡，以调整以外的自己墓地1只「废品」怪兽为对象才能发动。那只怪兽特殊召唤，只用那只怪兽和这张卡为素材，把以「同调士」调整为素材的1只同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地而除外。
function c25148255.initial_effect(c)
	-- ①：1回合1次，丢弃1张手卡，以调整以外的自己墓地1只「废品」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，只用那只怪兽和这张卡为素材，进行以「同调士」调整为素材的1只同调怪兽的同调召唤。那个时候，同调素材怪兽不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25148255,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c25148255.sccost)
	e1:SetTarget(c25148255.sctg)
	e1:SetOperation(c25148255.scop)
	c:RegisterEffect(e1)
	-- 这张卡可以作为「同调士」调整的代替而成为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(20932152)
	c:RegisterEffect(e2)
end
-- ①的代价处理：检查手牌中是否存在可丢弃的卡，并从手牌丢弃1张作为发动代价。
function c25148255.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动合法性检查（chk==0），则确认自己手牌是否存在至少1张可丢弃的卡，用于判断能否支付丢弃1张手牌的代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 发动时实际执行代价：从手牌选择1张卡丢弃（丢弃作为代价）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST)
end
-- 墓地对象的过滤函数：对象必须是「废品」字段、不是调整、可被特殊召唤，且与这张卡组合后能同调召唤出符合条件的额外怪兽。
function c25148255.mfilter(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsSetCard(0x43) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认额外卡组存在至少1只能以这张卡和对象怪兽为素材进行同调召唤的怪兽。
		and Duel.IsExistingMatchingCard(c25148255.scfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 额外同调怪兽的过滤函数：怪兽的素材要求包含「同调士」字段，能用给定素材组进行同调召唤，并且有足够空格让额外怪兽出场。
function c25148255.scfilter(c,mg,tp)
	-- 同时满足：额外怪兽的素材表含「同调士」字段、能用该素材组进行同调召唤、且有足够的额外怪兽区空格。
	return aux.IsMaterialListSetCard(c,0x1017) and c:IsSynchroSummonable(nil,mg) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- ①的发动条件与取对象处理：确认可以特殊召唤2次且有怪兽区空格，再从自己墓地选择1只符合条件的「废品」非调整怪兽作为对象。
function c25148255.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25148255.mfilter(chkc,e,tp,c) end
	-- 确认玩家本回合还允许进行2次特殊召唤（用于后续特召对象怪兽和同调召唤）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 确认自己场上有空的怪兽区（用于特殊召唤对象怪兽）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在1只满足c25148255.mfilter条件的怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c25148255.mfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c) end
	-- 向玩家显示“请选择要作为同调素材的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
	-- 执行选择：从自己墓地选择1只满足条件的「废品」非调整怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c25148255.mfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c)
	-- 设置操作信息：预告本次效果将进行额外卡组怪兽的特殊召唤，供后续时点和相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①的效果处理：特殊召唤对象怪兽；若成功且这张卡仍在场，则用这张卡和该怪兽为素材，选择额外卡组中符合条件的同调怪兽进行同调召唤，并使这次同调素材不去墓地而除外。
function c25148255.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始前确认自己主要怪兽区有空位，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽（墓地那只「废品」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联且特殊召唤成功；若对象已失效或特殊召唤失败则中止后续同调处理。
	if not tc:IsRelateToEffect(e) or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if not c:IsRelateToEffect(e) then return end
	-- 立即刷新场地信息，确保后续检查使用最新的怪兽位置状态。
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 在额外卡组中检索所有能以这张卡和对象怪兽为素材进行同调召唤的符合条件的同调怪兽。
	local g=Duel.GetMatchingGroup(c25148255.scfilter,tp,LOCATION_EXTRA,0,nil,mg,tp)
	if g:GetCount()>0 then
		-- 向玩家显示“请选择要特殊召唤的卡”的选择提示（选择要同调召唤的额外怪兽）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 那之后，只用那只怪兽和这张卡为素材，进行以「同调士」调整为素材的1只同调怪兽的同调召唤。那个时候，同调素材怪兽不去墓地而除外。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		local e2=e1:Clone()
		tc:RegisterEffect(e2,true)
		-- 使用这张卡和对象怪兽作为素材，将选择的额外怪兽进行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
